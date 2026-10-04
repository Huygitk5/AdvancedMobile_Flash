package com.flash.stats.dto;

import lombok.Builder;
import lombok.Getter;

import java.util.List;

/** Dữ liệu ProgressScreen (DATA_ARCHITECTURE.md §6.3: /v1/users/me/statistics). */
@Getter
@Builder
public class StatisticsResponse {

    private final StatsRange range;
    private final List<DailyStatisticResponse> daily;

    /** correctAnswers / totalAnswers (câu trả lời quiz) trong khoảng; 0 khi chưa làm câu nào. */
    private final double accuracy;

    private final int xpGained;
    private final int wordsLearned;
    private final int studySeconds;

    /** Streak hiện tại: về 0 nếu đã bỏ lỡ quá 1 ngày. */
    private final int streakDays;
    private final int longestStreak;
    private final int totalWordsLearned;
}
