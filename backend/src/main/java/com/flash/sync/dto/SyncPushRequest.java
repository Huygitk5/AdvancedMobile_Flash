package com.flash.sync.dto;

import com.fasterxml.jackson.databind.JsonNode;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import javax.validation.Valid;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

/** Một lô thao tác offline lấy từ sync_queue của client (DATA_ARCHITECTURE.md §3.4, §6.11). */
@Getter
@Setter
@NoArgsConstructor
public class SyncPushRequest {

    public static final int MAX_OPERATIONS = 50;

    @Size(max = 100)
    private String deviceId;

    /** Giờ thiết bị lúc gửi lô; server dùng để tính clockOffset = serverReceivedAt − clientSentAt. */
    @NotNull
    private Instant clientSentAt;

    @NotNull
    @Size(max = MAX_OPERATIONS)
    @Valid
    private List<Operation> operations;

    @Getter
    @Setter
    @NoArgsConstructor
    @Schema(name = "SyncOperation")
    public static class Operation {

        /** id do client sinh (sync_queue.op_id); gửi lại cùng opId không bị xử lý hai lần. */
        @NotNull
        private UUID opId;

        @NotBlank
        @Size(max = 40)
        @Schema(allowableValues = {"FLASHCARD_REVIEW", "LESSON_COMPLETE", "QUIZ_SUBMIT", "NOTE_UPSERT", "NOTE_DELETE",
                "BOOKMARK_SET", "QUEST_CLAIM", "PROFILE_UPDATE", "ITEM_EQUIP", "SHOP_PURCHASE", "SETTINGS_UPDATE"})
        private String opType;

        /** Giờ thiết bị lúc tạo op. */
        @NotNull
        private Instant createdAt;

        /** Payload theo opType, xem bảng §3.4. Kiểm tra chi tiết khi xử lý từng op. */
        @NotNull
        @Schema(implementation = Object.class, description = "Theo opType: FLASHCARD_REVIEW = body của POST /v1/flashcards/review, "
                + "LESSON_COMPLETE = POST /v1/lessons/complete, QUIZ_SUBMIT = POST /v1/quizzes/submit, "
                + "NOTE_UPSERT = PUT /v1/flashcards/notes/update, NOTE_DELETE = {noteId, flashcardId, baseVersion, clientUpdatedAt}, "
                + "BOOKMARK_SET = {flashcardId, bookmarked, clientUpdatedAt}, QUEST_CLAIM = {userQuestId, claimedAt}, "
                + "PROFILE_UPDATE = PUT /v1/users/update, ITEM_EQUIP = {inventoryId, equipped, clientUpdatedAt}, "
                + "SHOP_PURCHASE = {rewardItemId}, SETTINGS_UPDATE = PUT /v1/users/me/settings")
        private JsonNode payload;
    }
}
