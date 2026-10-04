package com.flash.user.entity;

import com.flash.common.enums.CefrLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.Type;

import javax.persistence.*;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "users")
@Getter
@Setter
@NoArgsConstructor
public class User {

    @Id
    @Type(type = "uuid-char")
    @Column(columnDefinition = "char")
    private UUID id;

    @Column(nullable = false)
    private String email;

    /** BCrypt; null nếu chỉ đăng nhập bằng Google. */
    private String passwordHash;

    @Column(nullable = false)
    private String fullName;

    private String avatarUrl;

    @Enumerated(EnumType.STRING)
    @Column(columnDefinition = "enum", nullable = false)
    private CefrLevel level = CefrLevel.A1;

    @Column(nullable = false)
    private String slogan = "Học, học nữa, học mãi!";

    // --- Bộ đếm gamification: chỉ XpService / StreakService được ghi ---
    @Column(nullable = false)
    private Integer currentXp = 0;

    @Column(nullable = false)
    private Integer targetXp = 100;

    @Column(nullable = false)
    private Long totalLifetimeXp = 0L;

    @Column(nullable = false)
    private Integer streakDays = 0;

    @Column(nullable = false)
    private Integer longestStreak = 0;

    private LocalDate lastActiveDate;

    // --- Cache có chủ đích (DATA_ARCHITECTURE.md §2.3) ---
    @Column(nullable = false)
    private Integer totalWordsLearned = 0;

    @Column(nullable = false)
    private Integer completedLessons = 0;

    @Column(nullable = false)
    private String timezone = "Asia/Ho_Chi_Minh";

    @Enumerated(EnumType.STRING)
    @Column(columnDefinition = "enum", nullable = false)
    private UserRole role = UserRole.USER;

    @Enumerated(EnumType.STRING)
    @Column(columnDefinition = "enum", nullable = false)
    private UserStatus status = UserStatus.ACTIVE;

    private Instant emailVerifiedAt;

    @Version
    private Integer version;

    private Instant clientUpdatedAt;

    @Column(insertable = false, updatable = false)
    private Instant createdAt;

    @Column(insertable = false, updatable = false)
    private Instant updatedAt;

    private Instant deletedAt;

    @PrePersist
    void ensureId() {
        if (id == null) {
            id = UUID.randomUUID();
        }
    }
}
