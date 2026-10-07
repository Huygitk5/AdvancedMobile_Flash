package com.flash.sync.dto;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import javax.validation.constraints.NotNull;
import java.time.Instant;
import java.util.UUID;

/**
 * Payload của các op không có DTO REST tương ứng (DATA_ARCHITECTURE.md §3.4).
 * Các op còn lại dùng lại DTO của API REST: ReviewRequest, LessonCompleteRequest, QuizSubmitRequest,
 * NoteUpsertRequest, UpdateProfileRequest, UpdateSettingsRequest, PurchaseRequest.
 */
public final class SyncPayloads {

    private SyncPayloads() {
    }

    /** NOTE_DELETE: xoá ghi chú (tombstone), đi qua đúng luật LWW như khi sửa. */
    @Getter
    @Setter
    @NoArgsConstructor
    public static class NoteDelete {
        private UUID noteId;

        @NotNull
        private UUID flashcardId;

        private Integer baseVersion;
        private Instant clientUpdatedAt;
    }

    /** BOOKMARK_SET: bookmarked = false là bỏ bookmark. */
    @Getter
    @Setter
    @NoArgsConstructor
    public static class BookmarkSet {
        @NotNull
        private UUID flashcardId;

        @NotNull
        private Boolean bookmarked;

        private Instant clientUpdatedAt;
    }

    /** QUEST_CLAIM: claimedAt chỉ để tham khảo, server dùng giờ của mình. */
    @Getter
    @Setter
    @NoArgsConstructor
    public static class QuestClaim {
        @NotNull
        private UUID userQuestId;

        private Instant claimedAt;
    }

    /** ITEM_EQUIP: equipped = false là tháo. */
    @Getter
    @Setter
    @NoArgsConstructor
    public static class ItemEquip {
        @NotNull
        private UUID inventoryId;

        @NotNull
        private Boolean equipped;

        private Instant clientUpdatedAt;
    }
}
