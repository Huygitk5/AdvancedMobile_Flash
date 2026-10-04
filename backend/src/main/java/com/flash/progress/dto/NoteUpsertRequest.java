package com.flash.progress.dto;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;
import java.time.Instant;
import java.util.UUID;

/** Tạo/sửa ghi chú (upsert, LWW). Cũng là payload của op NOTE_UPSERT khi sync. */
@Getter
@Setter
@NoArgsConstructor
public class NoteUpsertRequest {

    /** id do client sinh khi tạo mới offline; bỏ qua nếu (user, flashcard) đã có ghi chú. */
    private UUID noteId;

    @NotNull
    private UUID flashcardId;

    @NotNull
    @Size(max = 5000)
    private String content;

    /** version mà client đang dựa trên; null khi client chưa từng thấy ghi chú này. */
    private Integer baseVersion;

    /** Thời điểm sửa trên thiết bị (sync sẽ cộng clockOffset trước khi gọi service). */
    private Instant clientUpdatedAt;
}
