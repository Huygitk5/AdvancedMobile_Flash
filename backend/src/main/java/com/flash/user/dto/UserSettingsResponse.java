package com.flash.user.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.flash.user.entity.UserSettings;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.time.LocalTime;

@Getter
@Builder
public class UserSettingsResponse {

    private final boolean isNotificationEnabled;
    private final boolean isSoundEnabled;
    private final boolean isVibrationEnabled;
    private final boolean isDarkMode;
    private final String appLanguage;

    @JsonFormat(pattern = "HH:mm")
    private final LocalTime dailyReminderTime;

    private final int dailyGoalLessons;
    private final Integer version;
    private final Instant clientUpdatedAt;

    public static UserSettingsResponse from(UserSettings settings) {
        return UserSettingsResponse.builder()
                .isNotificationEnabled(settings.getIsNotificationEnabled())
                .isSoundEnabled(settings.getIsSoundEnabled())
                .isVibrationEnabled(settings.getIsVibrationEnabled())
                .isDarkMode(settings.getIsDarkMode())
                .appLanguage(settings.getAppLanguage())
                .dailyReminderTime(settings.getDailyReminderTime())
                .dailyGoalLessons(settings.getDailyGoalLessons())
                .version(settings.getVersion())
                .clientUpdatedAt(settings.getClientUpdatedAt())
                .build();
    }

    // Lombok sinh getter "isXxx()" cho boolean "isXxx", Jackson sẽ đặt tên JSON là "xxx".
    // Khai báo tường minh để JSON giữ đúng tên key như SharedPreferences bên Flutter.
    @JsonProperty("isNotificationEnabled")
    public boolean isNotificationEnabled() {
        return isNotificationEnabled;
    }

    @JsonProperty("isSoundEnabled")
    public boolean isSoundEnabled() {
        return isSoundEnabled;
    }

    @JsonProperty("isVibrationEnabled")
    public boolean isVibrationEnabled() {
        return isVibrationEnabled;
    }

    @JsonProperty("isDarkMode")
    public boolean isDarkMode() {
        return isDarkMode;
    }
}
