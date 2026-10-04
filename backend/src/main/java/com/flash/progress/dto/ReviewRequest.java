package com.flash.progress.dto;

import com.flash.progress.entity.SrsRating;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import javax.validation.constraints.Max;
import javax.validation.constraints.Min;
import javax.validation.constraints.NotNull;
import java.time.Instant;
import java.util.UUID;

/** Một lượt Again/Know. Cũng là payload của op FLASHCARD_REVIEW khi sync. */
@Getter
@Setter
@NoArgsConstructor
public class ReviewRequest {

    /** id do client sinh; gửi lại cùng logId không bị tính hai lần. */
    @NotNull
    private UUID logId;

    @NotNull
    private UUID flashcardId;

    @NotNull
    private SrsRating rating;

    @Min(0)
    @Max(3_600_000)
    private Integer responseTimeMs;

    /** Giờ bấm trên thiết bị (sync sẽ cộng clockOffset trước khi gọi service). */
    @NotNull
    private Instant reviewedAt;
}
