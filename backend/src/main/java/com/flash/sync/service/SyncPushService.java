package com.flash.sync.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.flash.common.BusinessException;
import com.flash.common.ErrorCode;
import com.flash.sync.dto.SyncOpResult;
import com.flash.sync.dto.SyncOpStatus;
import com.flash.sync.dto.SyncPushRequest;
import com.flash.sync.dto.SyncPushResponse;
import com.flash.sync.entity.SyncOperation;
import com.flash.sync.entity.SyncOperationStatus;
import com.flash.sync.repository.SyncOperationRepository;
import com.flash.user.dto.UserSnapshot;
import com.flash.user.service.UserService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;

import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * POST /v1/sync/push (DATA_ARCHITECTURE.md §6.11).
 * <ul>
 *   <li>clockOffset = serverReceivedAt − clientSentAt được cộng vào mọi timestamp của lô (chặn trò chỉnh giờ máy).</li>
 *   <li>Op chạy đúng thứ tự gửi lên, <b>mỗi op một transaction</b>: op bị từ chối không kéo op khác rollback theo.</li>
 *   <li>sync_operations là sổ idempotency: opId đã có thì trả DUPLICATE kèm kết quả cũ, không chạy lại.</li>
 * </ul>
 */
@Slf4j
@Service
public class SyncPushService {

    static final Duration SUSPICIOUS_CLOCK_OFFSET = Duration.ofHours(24);
    static final String NOT_PROCESSED = "NOT_PROCESSED";

    private final SyncOpDispatcher dispatcher;
    private final SyncOperationRepository operationRepository;
    private final UserService userService;
    private final ObjectMapper objectMapper;
    private final TransactionTemplate transactionTemplate;

    public SyncPushService(SyncOpDispatcher dispatcher, SyncOperationRepository operationRepository,
                           UserService userService, ObjectMapper objectMapper,
                           PlatformTransactionManager transactionManager) {
        this.dispatcher = dispatcher;
        this.operationRepository = operationRepository;
        this.userService = userService;
        this.objectMapper = objectMapper;
        this.transactionTemplate = new TransactionTemplate(transactionManager);
    }

    public SyncPushResponse push(UUID userId, SyncPushRequest request) {
        Duration clockOffset = Duration.between(request.getClientSentAt(), Instant.now());
        if (clockOffset.abs().compareTo(SUSPICIOUS_CLOCK_OFFSET) > 0) {
            log.warn("Lệch đồng hồ bất thường: user={} device={} offset={}", userId, request.getDeviceId(), clockOffset);
        }

        List<SyncOpResult> results = new ArrayList<>();
        boolean halted = false;
        for (SyncPushRequest.Operation op : request.getOperations()) {
            if (halted) {
                // Giữ FIFO: không chạy op sau khi op trước lỗi tạm thời, client gửi lại cả đoạn sau
                results.add(SyncOpResult.error(op.getOpId(), SyncOpStatus.FAILED, NOT_PROCESSED,
                        "Chưa xử lý vì thao tác trước đó lỗi, hãy gửi lại"));
                continue;
            }
            try {
                results.add(process(userId, op, clockOffset));
            } catch (RuntimeException e) {
                log.error("Lỗi xử lý op {} ({}) của user {}", op.getOpId(), op.getOpType(), userId, e);
                results.add(SyncOpResult.error(op.getOpId(), SyncOpStatus.FAILED, ErrorCode.INTERNAL_ERROR.name(),
                        ErrorCode.INTERNAL_ERROR.getDefaultMessage()));
                halted = true;
            }
        }

        UserSnapshot user = UserSnapshot.from(userService.getActiveUser(userId));
        return new SyncPushResponse(Instant.now(), clockOffset.toMillis(), results, user);
    }

    /** @throws RuntimeException lỗi không phải nghiệp vụ (DB, bug): op chưa được ghi nhận, client thử lại sau */
    private SyncOpResult process(UUID userId, SyncPushRequest.Operation op, Duration clockOffset) {
        try {
            return transactionTemplate.execute(status -> {
                // Khoá user trước khi tra sổ: 2 request push song song của cùng user chạy tuần tự,
                // nên cùng một opId không thể lọt qua bước kiểm tra trùng hai lần
                userService.lockActiveUser(userId);
                Optional<SyncOperation> existing = operationRepository.findById(op.getOpId());
                if (existing.isPresent()) {
                    return duplicateOf(userId, existing.get());
                }

                SyncOpType type = SyncOpType.parse(op.getOpType())
                        .orElseThrow(() -> new BusinessException(ErrorCode.BAD_REQUEST,
                                "opType không được hỗ trợ: " + op.getOpType()));
                SyncOpDispatcher.Outcome outcome = dispatcher.dispatch(userId, op.getOpId(), type, op.getPayload(), clockOffset);
                // SHOP_PURCHASE: ShopService đã tự ghi sổ với Idempotency-Key = opId
                if (!operationRepository.existsById(op.getOpId())) {
                    operationRepository.save(record(userId, op, clockOffset, SyncOperationStatus.APPLIED, null,
                            toJson(outcome.getData())));
                }
                return SyncOpResult.of(op.getOpId(), outcome.getStatus(), outcome.getData());
            });
        } catch (BusinessException e) {
            // Transaction của op đã rollback; ghi lại việc từ chối để lần gửi lại nhận DUPLICATE thay vì chạy lại
            if (e.getErrorCode() != ErrorCode.CONFLICT || !isForeignOpId(userId, op.getOpId())) {
                rememberRejection(userId, op, clockOffset, e.getErrorCode());
            }
            return SyncOpResult.error(op.getOpId(), SyncOpStatus.REJECTED, e.getErrorCode().name(), e.getMessage());
        }
    }

    private SyncOpResult duplicateOf(UUID userId, SyncOperation existing) {
        if (!existing.getUserId().equals(userId)) {
            throw new BusinessException(ErrorCode.CONFLICT, "opId đã được sử dụng");
        }
        if (existing.getStatus() == SyncOperationStatus.REJECTED) {
            return SyncOpResult.error(existing.getOpId(), SyncOpStatus.DUPLICATE, existing.getErrorCode(),
                    "Thao tác này đã bị từ chối trước đó");
        }
        return SyncOpResult.of(existing.getOpId(), SyncOpStatus.DUPLICATE, fromJson(existing.getResultJson()));
    }

    private void rememberRejection(UUID userId, SyncPushRequest.Operation op, Duration clockOffset, ErrorCode code) {
        try {
            transactionTemplate.executeWithoutResult(status -> operationRepository.save(
                    record(userId, op, clockOffset, SyncOperationStatus.REJECTED, code.name(), null)));
        } catch (DataAccessException e) {
            // Trùng opId (request song song đã ghi trước) hoặc user không còn: không cần ghi nữa
            log.debug("Bỏ qua ghi REJECTED cho op {}: {}", op.getOpId(), e.getMostSpecificCause().getMessage());
        }
    }

    /** opId đã thuộc về user khác: không được ghi đè sổ của họ. */
    private boolean isForeignOpId(UUID userId, UUID opId) {
        return operationRepository.findById(opId).map(o -> !o.getUserId().equals(userId)).orElse(false);
    }

    private static SyncOperation record(UUID userId, SyncPushRequest.Operation op, Duration clockOffset,
                                        SyncOperationStatus status, String errorCode, String resultJson) {
        SyncOperation operation = new SyncOperation();
        operation.setOpId(op.getOpId());
        operation.setUserId(userId);
        operation.setOpType(op.getOpType());
        operation.setStatus(status);
        operation.setErrorCode(errorCode);
        operation.setResultJson(resultJson);
        operation.setClientCreatedAt(op.getCreatedAt().plus(clockOffset));
        return operation;
    }

    private String toJson(Object data) {
        try {
            return objectMapper.writeValueAsString(data);
        } catch (JsonProcessingException e) {
            throw new IllegalStateException(e);
        }
    }

    private JsonNode fromJson(String json) {
        if (json == null) {
            return null;
        }
        try {
            return objectMapper.readTree(json);
        } catch (JsonProcessingException e) {
            throw new IllegalStateException(e);
        }
    }
}
