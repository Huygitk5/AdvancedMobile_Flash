package com.flash.progress.dto;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.flash.common.enums.Resolution;
import com.flash.progress.entity.UserBookmark;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.util.UUID;

/** Trạng thái bookmark cuối cùng trên server sau LWW (DATA_ARCHITECTURE.md §5.3b). */
@Getter
@Builder
public class BookmarkResult {

    private final UUID flashcardId;
    private final Boolean isBookmarked;
    private final Integer version;
    private final Instant clientUpdatedAt;
    private final Instant deletedAt;
    private final Resolution resolution;

    /** true nếu lần này tạo dòng mới (REST trả 201 thay vì 200). */
    @JsonIgnore
    private final boolean created;

    public static BookmarkResult of(UserBookmark bookmark, Resolution resolution, boolean created) {
        return BookmarkResult.builder()
                .flashcardId(bookmark.getFlashcardId())
                .isBookmarked(bookmark.getDeletedAt() == null)
                .version(bookmark.getVersion())
                .clientUpdatedAt(bookmark.getClientUpdatedAt())
                .deletedAt(bookmark.getDeletedAt())
                .resolution(resolution)
                .created(created)
                .build();
    }
}
