package com.flash.progress.service;

import com.flash.common.BusinessException;
import com.flash.common.ErrorCode;
import com.flash.common.enums.Resolution;
import com.flash.content.repository.FlashcardRepository;
import com.flash.progress.dto.NoteResponse;
import com.flash.progress.dto.NoteResult;
import com.flash.progress.dto.NoteUpsertRequest;
import com.flash.progress.entity.UserFlashcardNote;
import com.flash.progress.repository.UserFlashcardNoteRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.Objects;
import java.util.Optional;
import java.util.UUID;

/**
 * Ghi chú từ vựng: Last-Write-Wins có kiểm tra version (DATA_ARCHITECTURE.md §5.3a).
 * <pre>
 * row = SELECT ... FOR UPDATE
 * row == null                          -> INSERT
 * baseVersion == row.version           -> UPDATE (không xung đột)
 * clientUpdatedAt > row.clientUpdated  -> UPDATE (bản client mới hơn thắng)
 * còn lại                              -> giữ bản server, CONFLICT_SERVER_WINS
 * </pre>
 * Xoá là tombstone (deleted_at) và cũng đi qua đúng luật trên.
 */
@Service
@RequiredArgsConstructor
public class NoteService {

    private final UserFlashcardNoteRepository repository;
    private final FlashcardRepository flashcardRepository;

    @Transactional(readOnly = true)
    public NoteResponse get(UUID userId, UUID flashcardId) {
        return repository.findByUserIdAndFlashcardIdAndDeletedAtIsNull(userId, flashcardId)
                .map(NoteResponse::from)
                .orElseThrow(() -> new BusinessException(ErrorCode.NOT_FOUND, "Chưa có ghi chú cho từ này"));
    }

    @Transactional
    public NoteResult upsert(UUID userId, NoteUpsertRequest request) {
        if (flashcardRepository.findByIdAndDeletedAtIsNull(request.getFlashcardId()).isEmpty()) {
            throw new BusinessException(ErrorCode.NOT_FOUND, "Không tìm thấy từ vựng");
        }
        Instant clientUpdatedAt = request.getClientUpdatedAt() != null ? request.getClientUpdatedAt() : Instant.now();

        Optional<UserFlashcardNote> found = repository.findForUpdate(userId, request.getFlashcardId());
        if (found.isEmpty()) {
            UserFlashcardNote note = new UserFlashcardNote();
            boolean idFree = request.getNoteId() != null && !repository.existsById(request.getNoteId());
            note.setId(idFree ? request.getNoteId() : UUID.randomUUID());
            note.setUserId(userId);
            note.setFlashcardId(request.getFlashcardId());
            note.setContent(request.getContent());
            note.setClientUpdatedAt(clientUpdatedAt);
            repository.saveAndFlush(note);
            return new NoteResult(NoteResponse.from(note), Resolution.APPLIED);
        }

        UserFlashcardNote note = found.get();
        if (!clientWins(note, request.getBaseVersion(), clientUpdatedAt)) {
            return new NoteResult(NoteResponse.from(note), Resolution.CONFLICT_SERVER_WINS);
        }
        note.setContent(request.getContent());
        note.setDeletedAt(null);
        note.setClientUpdatedAt(clientUpdatedAt);
        repository.saveAndFlush(note);
        return new NoteResult(NoteResponse.from(note), Resolution.APPLIED);
    }

    /**
     * @param baseVersion null khi xoá từ REST (không có version), lúc đó chỉ so thời điểm
     * @return null nếu user chưa từng có ghi chú cho từ này
     */
    @Transactional
    public NoteResult delete(UUID userId, UUID flashcardId, Integer baseVersion, Instant clientUpdatedAt) {
        Instant at = clientUpdatedAt != null ? clientUpdatedAt : Instant.now();
        Optional<UserFlashcardNote> found = repository.findForUpdate(userId, flashcardId);
        if (found.isEmpty()) {
            return null;
        }
        UserFlashcardNote note = found.get();
        if (note.getDeletedAt() != null) {
            return new NoteResult(NoteResponse.from(note), Resolution.APPLIED);
        }
        if (!clientWins(note, baseVersion, at)) {
            return new NoteResult(NoteResponse.from(note), Resolution.CONFLICT_SERVER_WINS);
        }
        note.setDeletedAt(Instant.now());
        note.setClientUpdatedAt(at);
        repository.saveAndFlush(note);
        return new NoteResult(NoteResponse.from(note), Resolution.APPLIED);
    }

    private static boolean clientWins(UserFlashcardNote note, Integer baseVersion, Instant clientUpdatedAt) {
        return Objects.equals(baseVersion, note.getVersion()) || clientUpdatedAt.isAfter(note.getClientUpdatedAt());
    }
}
