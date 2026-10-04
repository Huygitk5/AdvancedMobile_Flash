package com.flash.progress.dto;

import com.flash.home.dto.HomeSummaryResponse;
import com.flash.user.dto.UserSnapshot;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class LessonCompleteResponse {

    private final int xpAwarded;

    /** true nếu id đã được ghi nhận trước đó. */
    private final boolean duplicate;

    private final HomeSummaryResponse.TodayLessons todayLessons;
    private final UserSnapshot user;
}
