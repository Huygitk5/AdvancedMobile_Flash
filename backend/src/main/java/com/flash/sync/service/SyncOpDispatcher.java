package com.flash.sync.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.flash.common.BusinessException;
import com.flash.common.ErrorCode;
import com.flash.common.enums.Resolution;
import com.flash.gamification.dto.EquipResult;
import com.flash.gamification.dto.PurchaseRequest;
import com.flash.gamification.service.QuestService;
import com.flash.gamification.service.ShopService;
import com.flash.progress.dto.BookmarkResult;
import com.flash.progress.dto.LessonCompleteRequest;
import com.flash.progress.dto.LessonCompleteResponse;
import com.flash.progress.dto.NoteResult;
import com.flash.progress.dto.NoteUpsertRequest;
import com.flash.progress.dto.QuizResultResponse;
import com.flash.progress.dto.QuizSubmitRequest;
import com.flash.progress.dto.ReviewRequest;
import com.flash.progress.dto.ReviewResponse;
import com.flash.progress.service.BookmarkService;
import com.flash.progress.service.LessonService;
import com.flash.progress.service.NoteService;
import com.flash.progress.service.QuizAttemptService;
import com.flash.progress.service.SrsService;
import com.flash.sync.dto.SyncOpStatus;
import com.flash.sync.dto.SyncPayloads;
import com.flash.user.dto.ProfileUpdateResult;
import com.flash.user.dto.UpdateProfileRequest;
import com.flash.user.dto.UpdateSettingsRequest;
import com.flash.user.dto.UserSettingsResult;
import com.flash.user.service.UserService;
import com.flash.user.service.UserSettingsService;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import javax.validation.ConstraintViolation;
import javax.validation.Validator;
import java.time.Duration;
import java.time.Instant;
import java.util.Collections;
import java.util.Comparator;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * opType → service của G4. Không viết lại nghiệp vụ: mọi kiểm tra (idempotent theo id, LWW,
 * chống gian lận, XP / streak / quest) nằm ở service; dispatcher chỉ đọc payload, hiệu chỉnh giờ
 * và chuyển kết quả sang trạng thái của §6.11. Chạy bên trong transaction của từng op.
 */
@Component
@RequiredArgsConstructor
public class SyncOpDispatcher {

    private final ObjectMapper objectMapper;
    private final Validator validator;
    private final SrsService srsService;
    private final LessonService lessonService;
    private final QuizAttemptService quizAttemptService;
    private final NoteService noteService;
    private final BookmarkService bookmarkService;
    private final QuestService questService;
    private final UserService userService;
    private final UserSettingsService settingsService;
    private final ShopService shopService;

    /**
     * @param clockOffset serverReceivedAt − clientSentAt, cộng vào mọi timestamp của payload
     * @throws BusinessException khi op bị từ chối (payload sai, sai nghiệp vụ)
     */
    public Outcome dispatch(UUID userId, UUID opId, SyncOpType type, JsonNode payload, Duration clockOffset) {
        Object request = read(payload, type.getPayloadType());
        switch (type) {
            case FLASHCARD_REVIEW: {
                ReviewRequest r = (ReviewRequest) request;
                r.setReviewedAt(shift(r.getReviewedAt(), clockOffset));
                ReviewResponse result = srsService.review(userId, r);
                return Outcome.of(result.isDuplicate() ? SyncOpStatus.DUPLICATE : SyncOpStatus.APPLIED, result);
            }
            case LESSON_COMPLETE: {
                LessonCompleteRequest r = (LessonCompleteRequest) request;
                r.setCompletedAt(shift(r.getCompletedAt(), clockOffset));
                LessonCompleteResponse result = lessonService.complete(userId, r);
                return Outcome.of(result.isDuplicate() ? SyncOpStatus.DUPLICATE : SyncOpStatus.APPLIED, result);
            }
            case QUIZ_SUBMIT: {
                QuizSubmitRequest r = (QuizSubmitRequest) request;
                r.setStartedAt(shift(r.getStartedAt(), clockOffset));
                r.setSubmittedAt(shift(r.getSubmittedAt(), clockOffset));
                QuizResultResponse result = quizAttemptService.submit(userId, r);
                SyncOpStatus status = Boolean.TRUE.equals(result.getDuplicate()) ? SyncOpStatus.DUPLICATE : SyncOpStatus.APPLIED;
                return Outcome.of(status, result);
            }
            case NOTE_UPSERT: {
                NoteUpsertRequest r = (NoteUpsertRequest) request;
                r.setClientUpdatedAt(shift(r.getClientUpdatedAt(), clockOffset));
                NoteResult result = noteService.upsert(userId, r);
                return Outcome.of(statusOf(result.getResolution()), result);
            }
            case NOTE_DELETE: {
                SyncPayloads.NoteDelete r = (SyncPayloads.NoteDelete) request;
                NoteResult result = noteService.delete(userId, r.getFlashcardId(), r.getBaseVersion(),
                        shift(r.getClientUpdatedAt(), clockOffset));
                // Server chưa từng có ghi chú này: xoá coi như đã xong
                return result == null ? Outcome.of(SyncOpStatus.APPLIED, Collections.emptyMap())
                        : Outcome.of(statusOf(result.getResolution()), result);
            }
            case BOOKMARK_SET: {
                SyncPayloads.BookmarkSet r = (SyncPayloads.BookmarkSet) request;
                Instant at = shift(r.getClientUpdatedAt(), clockOffset);
                BookmarkResult result = r.getBookmarked()
                        ? bookmarkService.bookmark(userId, r.getFlashcardId(), at)
                        : bookmarkService.unbookmark(userId, r.getFlashcardId(), at);
                return Outcome.of(statusOf(result.getResolution()), result);
            }
            case QUEST_CLAIM: {
                SyncPayloads.QuestClaim r = (SyncPayloads.QuestClaim) request;
                return Outcome.of(SyncOpStatus.APPLIED, questService.claim(userId, r.getUserQuestId()));
            }
            case PROFILE_UPDATE: {
                UpdateProfileRequest r = (UpdateProfileRequest) request;
                r.setClientUpdatedAt(shift(r.getClientUpdatedAt(), clockOffset));
                ProfileUpdateResult result = userService.updateProfileIfNewer(userId, r);
                return Outcome.of(statusOf(result.getResolution()), result);
            }
            case ITEM_EQUIP: {
                SyncPayloads.ItemEquip r = (SyncPayloads.ItemEquip) request;
                Instant at = shift(r.getClientUpdatedAt(), clockOffset);
                EquipResult result = r.getEquipped()
                        ? shopService.equip(userId, r.getInventoryId(), at)
                        : shopService.unequip(userId, r.getInventoryId(), at);
                return Outcome.of(statusOf(result.getResolution()), result);
            }
            case SHOP_PURCHASE: {
                // opId chính là Idempotency-Key: ShopService tự ghi sync_operations khi mua thành công
                PurchaseRequest r = (PurchaseRequest) request;
                return Outcome.of(SyncOpStatus.APPLIED, shopService.purchase(userId, r.getRewardItemId(), opId));
            }
            case SETTINGS_UPDATE: {
                UpdateSettingsRequest r = (UpdateSettingsRequest) request;
                r.setClientUpdatedAt(shift(r.getClientUpdatedAt(), clockOffset));
                UserSettingsResult result = settingsService.updateIfNewer(userId, r);
                return Outcome.of(statusOf(result.getResolution()), result);
            }
            default:
                throw new BusinessException(ErrorCode.BAD_REQUEST, "opType không được hỗ trợ: " + type);
        }
    }

    /** Đọc payload thành DTO rồi chạy Bean Validation giống @Valid của API REST. */
    private <T> T read(JsonNode payload, Class<T> type) {
        T value;
        try {
            value = objectMapper.treeToValue(payload, type);
        } catch (JsonProcessingException | IllegalArgumentException e) {
            throw new BusinessException(ErrorCode.VALIDATION_ERROR, "payload không đúng định dạng");
        }
        if (value == null) {
            throw new BusinessException(ErrorCode.VALIDATION_ERROR, "Thiếu payload");
        }
        Set<ConstraintViolation<T>> violations = validator.validate(value);
        if (!violations.isEmpty()) {
            String detail = violations.stream()
                    .map(v -> v.getPropertyPath() + ": " + v.getMessage())
                    .sorted(Comparator.naturalOrder())
                    .collect(Collectors.joining("; "));
            throw new BusinessException(ErrorCode.VALIDATION_ERROR, detail);
        }
        return value;
    }

    private static Instant shift(Instant time, Duration clockOffset) {
        return time == null ? null : time.plus(clockOffset);
    }

    private static SyncOpStatus statusOf(Resolution resolution) {
        return resolution == Resolution.CONFLICT_SERVER_WINS ? SyncOpStatus.CONFLICT_SERVER_WINS : SyncOpStatus.APPLIED;
    }

    @Getter
    @AllArgsConstructor(staticName = "of")
    public static class Outcome {
        private final SyncOpStatus status;
        private final Object data;
    }
}
