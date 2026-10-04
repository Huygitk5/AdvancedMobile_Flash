package com.flash.user.service;

import com.flash.user.dto.UpdateSettingsRequest;
import com.flash.user.dto.UserSettingsResponse;
import com.flash.user.entity.UserSettings;
import com.flash.user.repository.UserSettingsRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class UserSettingsService {

    private final UserSettingsRepository settingsRepository;

    @Transactional
    public UserSettingsResponse get(UUID userId) {
        return UserSettingsResponse.from(getOrCreate(userId));
    }

    @Transactional
    public UserSettingsResponse update(UUID userId, UpdateSettingsRequest request) {
        UserSettings settings = getOrCreate(userId);
        if (request.getIsNotificationEnabled() != null) {
            settings.setIsNotificationEnabled(request.getIsNotificationEnabled());
        }
        if (request.getIsSoundEnabled() != null) {
            settings.setIsSoundEnabled(request.getIsSoundEnabled());
        }
        if (request.getIsVibrationEnabled() != null) {
            settings.setIsVibrationEnabled(request.getIsVibrationEnabled());
        }
        if (request.getIsDarkMode() != null) {
            settings.setIsDarkMode(request.getIsDarkMode());
        }
        if (request.getAppLanguage() != null) {
            settings.setAppLanguage(request.getAppLanguage());
        }
        if (request.getDailyReminderTime() != null) {
            settings.setDailyReminderTime(request.getDailyReminderTime());
        }
        if (request.getDailyGoalLessons() != null) {
            settings.setDailyGoalLessons(request.getDailyGoalLessons());
        }
        settings.setClientUpdatedAt(request.getClientUpdatedAt() != null ? request.getClientUpdatedAt() : Instant.now());
        settingsRepository.saveAndFlush(settings);
        return UserSettingsResponse.from(settings);
    }

    /** User tạo trước khi có bảng settings (hoặc tạo tay trong DB) vẫn có cài đặt mặc định. */
    private UserSettings getOrCreate(UUID userId) {
        return settingsRepository.findById(userId).orElseGet(() -> {
            UserSettings settings = new UserSettings();
            settings.setUserId(userId);
            return settingsRepository.save(settings);
        });
    }
}
