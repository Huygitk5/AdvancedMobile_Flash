package com.flash.user.dto;

import com.flash.common.enums.CefrLevel;
import com.flash.user.entity.User;
import lombok.Builder;
import lombok.Getter;

import java.util.UUID;

/** Hồ sơ công khai (khi xem người khác từ bảng xếp hạng): không có email, XP hiện có. */
@Getter
@Builder
public class PublicUserResponse {

    private final UUID id;
    private final String fullName;
    private final String avatarUrl;
    private final CefrLevel level;
    private final String slogan;
    private final long totalLifetimeXp;
    private final int streakDays;
    private final int longestStreak;
    private final int totalWordsLearned;

    public static PublicUserResponse from(User user) {
        return PublicUserResponse.builder()
                .id(user.getId())
                .fullName(user.getFullName())
                .avatarUrl(user.getAvatarUrl())
                .level(user.getLevel())
                .slogan(user.getSlogan())
                .totalLifetimeXp(user.getTotalLifetimeXp())
                .streakDays(user.getStreakDays())
                .longestStreak(user.getLongestStreak())
                .totalWordsLearned(user.getTotalWordsLearned())
                .build();
    }
}
