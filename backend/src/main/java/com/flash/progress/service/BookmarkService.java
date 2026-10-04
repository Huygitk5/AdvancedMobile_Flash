package com.flash.progress.service;

import com.flash.common.BusinessException;
import com.flash.common.ErrorCode;
import com.flash.common.PageResponse;
import com.flash.common.enums.Resolution;
import com.flash.content.dto.FlashcardResponse;
import com.flash.content.repository.FlashcardRepository;
import com.flash.progress.dto.BookmarkResult;
import com.flash.progress.entity.UserBookmark;
import com.flash.progress.repository.UserBookmarkRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

/**
 * Bookmark: LWW với tombstone (DATA_ARCHITECTURE.md §5.3b). Bỏ bookmark chỉ set deleted_at
 * để thiết bị khác pull về biết từ đó đã bị bỏ; bản có client_updated_at mới hơn thắng.
 */
@Service
@RequiredArgsConstructor
public class BookmarkService {

    private final UserBookmarkRepository repository;
    private final FlashcardRepository flashcardRepository;

    @Transactional(readOnly = true)
    public PageResponse<FlashcardResponse> list(UUID userId, int page, int size) {
        return PageResponse.of(flashcardRepository.findBookmarkedWithUserState(userId, PageRequest.of(page, size))
                .map(FlashcardResponse::fromRow));
    }

    @Transactional
    public BookmarkResult bookmark(UUID userId, UUID flashcardId, Instant clientUpdatedAt) {
        if (flashcardRepository.findByIdAndDeletedAtIsNull(flashcardId).isEmpty()) {
            throw new BusinessException(ErrorCode.NOT_FOUND, "Không tìm thấy từ vựng");
        }
        return apply(userId, flashcardId, true, clientUpdatedAt);
    }

    @Transactional
    public BookmarkResult unbookmark(UUID userId, UUID flashcardId, Instant clientUpdatedAt) {
        return apply(userId, flashcardId, false, clientUpdatedAt);
    }

    private BookmarkResult apply(UUID userId, UUID flashcardId, boolean bookmarked, Instant clientUpdatedAt) {
        Instant at = clientUpdatedAt != null ? clientUpdatedAt : Instant.now();
        Optional<UserBookmark> found = repository.findForUpdate(userId, flashcardId);

        if (found.isEmpty()) {
            if (!bookmarked) {
                // Chưa từng bookmark: không cần tạo tombstone
                return BookmarkResult.builder()
                        .flashcardId(flashcardId)
                        .isBookmarked(false)
                        .resolution(Resolution.APPLIED)
                        .build();
            }
            UserBookmark bookmark = new UserBookmark();
            bookmark.setUserId(userId);
            bookmark.setFlashcardId(flashcardId);
            bookmark.setClientUpdatedAt(at);
            repository.saveAndFlush(bookmark);
            return BookmarkResult.of(bookmark, Resolution.APPLIED, true);
        }

        UserBookmark bookmark = found.get();
        boolean alreadyInState = (bookmark.getDeletedAt() == null) == bookmarked;
        if (alreadyInState) {
            return BookmarkResult.of(bookmark, Resolution.APPLIED, false);
        }
        if (at.isBefore(bookmark.getClientUpdatedAt())) {
            return BookmarkResult.of(bookmark, Resolution.CONFLICT_SERVER_WINS, false);
        }
        bookmark.setDeletedAt(bookmarked ? null : Instant.now());
        bookmark.setClientUpdatedAt(at);
        repository.saveAndFlush(bookmark);
        return BookmarkResult.of(bookmark, Resolution.APPLIED, bookmarked);
    }
}
