package com.flash.stats.dto;

import lombok.Builder;
import lombok.Getter;

import java.time.LocalDate;
import java.util.List;

/** Dữ liệu ProgressScreen (DATA_ARCHITECTURE.md §6.3: /v1/users/me/statistics). */
@Getter
@Builder
public class StatisticsResponse {

    private final StatsRange range;

    /** Khoảng ngày thực tế của dữ liệu (ALL: từ ngày học đầu tiên đến hôm nay). */
    private final LocalDate from;
    private final LocalDate to;

    /**
     * WEEK/MONTH/CUSTOM: đủ từng ngày trong khoảng (ngày không học = 0).
     * YEAR/ALL: chỉ các ngày có dữ liệu, client gom theo tháng.
     */
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
