package com.flash.user.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import javax.validation.constraints.Max;
import javax.validation.constraints.Min;
import javax.validation.constraints.Pattern;
import java.time.Instant;
import java.time.LocalTime;

/** Cập nhật từng phần: field null = giữ nguyên. */
@Getter
@Setter
@NoArgsConstructor
public class UpdateSettingsRequest {

    private Boolean isNotificationEnabled;
    private Boolean isSoundEnabled;
    private Boolean isVibrationEnabled;
    private Boolean isDarkMode;

    @Pattern(regexp = "vi|en", message = "Chỉ hỗ trợ 'vi' hoặc 'en'")
    private String appLanguage;

    @JsonFormat(pattern = "HH:mm")
    private LocalTime dailyReminderTime;

    @Min(1)
    @Max(20)
    private Integer dailyGoalLessons;

    private Instant clientUpdatedAt;
}
