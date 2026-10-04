package com.flash.progress.service;

import com.flash.progress.entity.FlashcardReviewLog;
import com.flash.progress.entity.SrsRating;
import com.flash.progress.entity.UserFlashcardProgress;
import org.junit.jupiter.api.Test;

import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

/** Bảng Leitner §5.2 và phát lại log đến muộn §5.3c. */
class SrsReplayTest {

    private static final Instant T0 = Instant.parse("2026-10-01T08:00:00Z");

    @Test
    void knowMovesUpOneBoxWithIntervalOfNewBox() {
        UserFlashcardProgress progress = new UserFlashcardProgress();
        List<FlashcardReviewLog> logs = List.of(
                log(SrsRating.KNOW, T0),
                log(SrsRating.KNOW, T0.plus(Duration.ofDays(1))),
                log(SrsRating.KNOW, T0.plus(Duration.ofDays(4))));

        SrsService.replay(progress, logs);

        assertThat(progress.getBox()).isEqualTo(3);
        assertThat(progress.getIsLearned()).isTrue();
        assertThat(progress.getDueAt()).isEqualTo(T0.plus(Duration.ofDays(4 + 7)));
        assertThat(progress.getKnowCount()).isEqualTo(3);
        assertThat(progress.getRepetitions()).isEqualTo(3);
        assertThat(logs).extracting(FlashcardReviewLog::getBoxBefore).containsExactly(0, 1, 2);
        assertThat(logs).extracting(FlashcardReviewLog::getBoxAfter).containsExactly(1, 2, 3);
    }

    @Test
    void boxIsCappedAtFiveAndAgainDropsTwoBoxesWithTenMinuteRetry() {
        UserFlashcardProgress progress = new UserFlashcardProgress();
        List<FlashcardReviewLog> logs = new ArrayList<>();
        for (int i = 0; i < 7; i++) {
            logs.add(log(SrsRating.KNOW, T0.plus(Duration.ofDays(i))));
        }
        SrsService.replay(progress, logs);
        assertThat(progress.getBox()).isEqualTo(5);

        Instant againAt = T0.plus(Duration.ofDays(10));
        logs.add(log(SrsRating.AGAIN, againAt));
        SrsService.replay(progress, logs);

        assertThat(progress.getBox()).isEqualTo(3);
        assertThat(progress.getDueAt()).isEqualTo(againAt.plus(Duration.ofMinutes(10)));
        assertThat(progress.getLastRating()).isEqualTo(SrsRating.AGAIN);
        assertThat(progress.getAgainCount()).isEqualTo(1);
    }

    @Test
    void againNeverGoesBelowZero() {
        UserFlashcardProgress progress = new UserFlashcardProgress();
        SrsService.replay(progress, List.of(log(SrsRating.KNOW, T0), log(SrsRating.AGAIN, T0.plusSeconds(60))));
        assertThat(progress.getBox()).isZero();
        assertThat(progress.getIsLearned()).isFalse();
    }

    /** Hai thiết bị offline: log của máy B (giữa hai lần ôn của máy A) đến sau cùng, nhưng được xếp đúng chỗ. */
    @Test
    void lateLogIsReplayedInChronologicalOrder() {
        FlashcardReviewLog a1 = log(SrsRating.KNOW, T0);
        FlashcardReviewLog a2 = log(SrsRating.KNOW, T0.plus(Duration.ofDays(2)));
        UserFlashcardProgress progress = new UserFlashcardProgress();
        SrsService.replay(progress, List.of(a1, a2));
        assertThat(progress.getBox()).isEqualTo(2);

        FlashcardReviewLog lateFromB = log(SrsRating.AGAIN, T0.plus(Duration.ofDays(1)));
        List<FlashcardReviewLog> all = new ArrayList<>(List.of(a1, a2, lateFromB));
        all.sort(Comparator.comparing(FlashcardReviewLog::getReviewedAt));
        SrsService.replay(progress, all);

        // KNOW(0->1), AGAIN(1->0), KNOW(0->1): kết quả khác hẳn việc lấy log đến sau cùng làm chuẩn
        assertThat(progress.getBox()).isEqualTo(1);
        assertThat(a2.getBoxBefore()).isZero();
        assertThat(progress.getLastRating()).isEqualTo(SrsRating.KNOW);
        assertThat(progress.getLastReviewedAt()).isEqualTo(a2.getReviewedAt());
        assertThat(progress.getDueAt()).isEqualTo(a2.getReviewedAt().plus(Duration.ofDays(1)));
    }

    private static FlashcardReviewLog log(SrsRating rating, Instant at) {
        FlashcardReviewLog log = new FlashcardReviewLog();
        log.setId(UUID.randomUUID());
        log.setRating(rating);
        log.setReviewedAt(at);
        return log;
    }
}
