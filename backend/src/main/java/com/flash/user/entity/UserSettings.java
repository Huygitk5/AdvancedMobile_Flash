package com.flash.user.entity;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.Type;

import javax.persistence.*;
import java.time.Instant;
import java.time.LocalTime;
import java.util.UUID;

/** Quan hệ 1-1 với users, khoá chính chính là user_id. */
@Entity
@Table(name = "user_settings")
@Getter
@Setter
@NoArgsConstructor
public class UserSettings {

    @Id
    @Type(type = "uuid-char")
    @Column(columnDefinition = "char")
    private UUID userId;

    @Column(nullable = false)
    private Boolean isNotificationEnabled = true;

    @Column(nullable = false)
    private Boolean isSoundEnabled = true;

    @Column(nullable = false)
    private Boolean isVibrationEnabled = true;

    @Column(nullable = false)
    private Boolean isDarkMode = false;

    @Column(nullable = false)
    private String appLanguage = "vi";

    private LocalTime dailyReminderTime;

    /** Mẫu số của "3/5 bài" ở HomeScreen. */
    @Column(columnDefinition = "tinyint", nullable = false)
    private Integer dailyGoalLessons = 5;

    @Version
    private Integer version;

    private Instant clientUpdatedAt;

    @Column(insertable = false, updatable = false)
    private Instant updatedAt;
}
