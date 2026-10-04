package com.flash.user.dto;

import com.flash.common.enums.CefrLevel;
import com.flash.user.entity.User;
import com.flash.user.entity.UserRole;
import com.flash.user.entity.UserStatus;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.util.UUID;

/** Hồ sơ đầy đủ của chính user, khớp UserModel bên Flutter. */
@Getter
@Builder
public class UserResponse {

    private final UUID id;
    private final String fullName;
    private final String email;
    private final String avatarUrl;
    private final CefrLevel level;
    private final String slogan;
    private final int currentXp;
    private final int targetXp;
    private final long totalLifetimeXp;
    private final int streakDays;
    private final int longestStreak;
    private final int totalWordsLearned;
    private final int completedLessons;
    private final UserRole role;
    private final UserStatus status;
    private final boolean emailVerified;
    private final boolean hasPassword;

    /** Gửi lại làm baseVersion khi PUT /v1/users/update. */
    private final Integer version;

    private final Instant clientUpdatedAt;
    private final Instant createdAt;

    public static UserResponse from(User user) {
        return UserResponse.builder()
                .id(user.getId())
                .fullName(user.getFullName())
                .email(user.getEmail())
                .avatarUrl(user.getAvatarUrl())
                .level(user.getLevel())
                .slogan(user.getSlogan())
                .currentXp(user.getCurrentXp())
                .targetXp(user.getTargetXp())
                .totalLifetimeXp(user.getTotalLifetimeXp())
                .streakDays(user.getStreakDays())
                .longestStreak(user.getLongestStreak())
                .totalWordsLearned(user.getTotalWordsLearned())
                .completedLessons(user.getCompletedLessons())
                .role(user.getRole())
                .status(user.getStatus())
                .emailVerified(user.getEmailVerifiedAt() != null)
                .hasPassword(user.getPasswordHash() != null)
                .version(user.getVersion())
                .clientUpdatedAt(user.getClientUpdatedAt())
                .createdAt(user.getCreatedAt())
                .build();
    }
}
