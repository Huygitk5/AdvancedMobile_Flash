package com.flash.user.dto;

import com.flash.user.entity.User;
import lombok.Builder;
import lombok.Getter;

/** Các con số server-authoritative trả kèm sau mỗi thao tác ghi, để client ghi đè bản lạc quan. */
@Getter
@Builder
public class UserSnapshot {

    private final int currentXp;
    private final long totalLifetimeXp;
    private final int streakDays;
    private final int longestStreak;
    private final int totalWordsLearned;
    private final int completedLessons;

    public static UserSnapshot from(User user) {
        return UserSnapshot.builder()
                .currentXp(user.getCurrentXp())
                .totalLifetimeXp(user.getTotalLifetimeXp())
                .streakDays(user.getStreakDays())
                .longestStreak(user.getLongestStreak())
                .totalWordsLearned(user.getTotalWordsLearned())
                .completedLessons(user.getCompletedLessons())
                .build();
    }
}
