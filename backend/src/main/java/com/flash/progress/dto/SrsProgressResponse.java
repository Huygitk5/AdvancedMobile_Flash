package com.flash.progress.dto;

import com.flash.progress.entity.SrsRating;
import com.flash.progress.entity.UserFlashcardProgress;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.util.UUID;

/** Kết quả SRS do server tính; client ghi đè bản tính lạc quan ở local. */
@Getter
@Builder
public class SrsProgressResponse {

    private final UUID flashcardId;
    private final int box;
    private final int repetitions;
    private final int againCount;
    private final int knowCount;
    private final SrsRating lastRating;
    private final Boolean isLearned;
    private final Instant lastReviewedAt;
    private final Instant dueAt;
    private final Integer version;

    public static SrsProgressResponse from(UserFlashcardProgress p) {
        return SrsProgressResponse.builder()
                .flashcardId(p.getFlashcardId())
                .box(p.getBox())
                .repetitions(p.getRepetitions())
                .againCount(p.getAgainCount())
                .knowCount(p.getKnowCount())
                .lastRating(p.getLastRating())
                .isLearned(p.getIsLearned())
                .lastReviewedAt(p.getLastReviewedAt())
                .dueAt(p.getDueAt())
                .version(p.getVersion())
                .build();
    }
}
