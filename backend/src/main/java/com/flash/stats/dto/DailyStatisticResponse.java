package com.flash.stats.dto;

import com.flash.stats.entity.DailyStatistic;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDate;
import java.util.UUID;

/** Khớp model DailyStatistic bên Flutter (date = stat_date, dạng YYYY-MM-DD). */
@Getter
@Builder
public class DailyStatisticResponse {

    /** null với ngày không có hoạt động (dòng được điền 0 cho đủ biểu đồ). */
    private final UUID id;
    private final UUID userId;
    private final LocalDate date;
    private final int wordsLearned;
    private final int cardsReviewed;
    private final int xpGained;
    private final int lessonsCompleted;
    private final int quizzesCompleted;
    private final int correctAnswers;
    private final int totalAnswers;
    private final int studySeconds;

    public static DailyStatisticResponse from(DailyStatistic stat) {
        return DailyStatisticResponse.builder()
                .id(stat.getId())
                .userId(stat.getUserId())
                .date(stat.getStatDate())
                .wordsLearned(stat.getWordsLearned())
                .cardsReviewed(stat.getCardsReviewed())
                .xpGained(stat.getXpGained())
                .lessonsCompleted(stat.getLessonsCompleted())
                .quizzesCompleted(stat.getQuizzesCompleted())
                .correctAnswers(stat.getCorrectAnswers())
                .totalAnswers(stat.getTotalAnswers())
                .studySeconds(stat.getStudySeconds())
                .build();
    }

    public static DailyStatisticResponse empty(UUID userId, LocalDate date) {
        return DailyStatisticResponse.builder().userId(userId).date(date).build();
    }
}
