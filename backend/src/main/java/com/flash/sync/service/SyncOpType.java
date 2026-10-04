package com.flash.sync.service;

import com.flash.gamification.dto.PurchaseRequest;
import com.flash.progress.dto.LessonCompleteRequest;
import com.flash.progress.dto.NoteUpsertRequest;
import com.flash.progress.dto.QuizSubmitRequest;
import com.flash.progress.dto.ReviewRequest;
import com.flash.sync.dto.SyncPayloads;
import com.flash.user.dto.UpdateProfileRequest;
import com.flash.user.dto.UpdateSettingsRequest;
import lombok.Getter;
import lombok.RequiredArgsConstructor;

import java.util.Arrays;
import java.util.Optional;

/**
 * Các loại thao tác offline (DATA_ARCHITECTURE.md §3.4) và kiểu payload tương ứng.
 * Thêm loại mới: thêm vào đây, vào {@link SyncOpDispatcher} và vào CHECK của sync_queue.op_type phía client.
 */
@Getter
@RequiredArgsConstructor
public enum SyncOpType {
    FLASHCARD_REVIEW(ReviewRequest.class),
    LESSON_COMPLETE(LessonCompleteRequest.class),
    QUIZ_SUBMIT(QuizSubmitRequest.class),
    NOTE_UPSERT(NoteUpsertRequest.class),
    NOTE_DELETE(SyncPayloads.NoteDelete.class),
    BOOKMARK_SET(SyncPayloads.BookmarkSet.class),
    QUEST_CLAIM(SyncPayloads.QuestClaim.class),
    PROFILE_UPDATE(UpdateProfileRequest.class),
    ITEM_EQUIP(SyncPayloads.ItemEquip.class),
    SHOP_PURCHASE(PurchaseRequest.class),
    SETTINGS_UPDATE(UpdateSettingsRequest.class);

    private final Class<?> payloadType;

    public static Optional<SyncOpType> parse(String value) {
        return Arrays.stream(values()).filter(t -> t.name().equals(value)).findFirst();
    }
}
