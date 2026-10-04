package com.flash.home.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.util.List;

/** Toàn bộ dữ liệu HomeScreen trong 1 lần gọi (DATA_ARCHITECTURE.md §6.4). */
@Getter
@Builder
public class HomeSummaryResponse {

    private final String fullName;
    private final int streakDays;
    private final int currentXp;
    private final int targetXp;

    /** "3/5 bài" hôm nay, tính theo timezone của user. */
    private final TodayLessons todayLessons;

    /** Bài đang học dở gần nhất, null nếu chưa có. */
    private final LessonResponse continueLesson;

    private final List<LessonResponse> recommended;

    /** Nhiệm vụ nổi bật hôm nay; null khi chưa được giao (nhiệm vụ được giao ở G4). */
    private final QuestResponse todayChallenge;

    @Getter
    @AllArgsConstructor
    public static class TodayLessons {
        private final int done;
        private final int goal;
    }
}
