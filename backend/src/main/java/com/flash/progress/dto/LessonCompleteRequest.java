package com.flash.progress.dto;

import com.flash.progress.entity.LessonType;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import javax.validation.constraints.Max;
import javax.validation.constraints.Min;
import javax.validation.constraints.NotNull;
import java.time.Instant;
import java.util.UUID;

/** Báo hoàn thành 1 bài. Đúng 1 trong topicId / grammarLessonId, khớp với lessonType. */
@Getter
@Setter
@NoArgsConstructor
public class LessonCompleteRequest {

    /** id do client sinh; gửi lại không bị tính hai lần. */
    @NotNull
    private UUID id;

    @NotNull
    private LessonType lessonType;

    private UUID topicId;

    private UUID grammarLessonId;

    @Min(0)
    @Max(10_000)
    private Integer cardsReviewed;

    @Min(0)
    @Max(86_400)
    private Integer durationSeconds;

    @NotNull
    private Instant completedAt;
}
