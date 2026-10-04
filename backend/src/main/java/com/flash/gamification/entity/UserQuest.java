package com.flash.gamification.entity;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.Type;

import javax.persistence.*;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

/** Nhiệm vụ giao cho user trong 1 chu kỳ. targetValue / xpReward là snapshot lúc giao. */
@Entity
@Table(name = "user_quests")
@Getter
@Setter
@NoArgsConstructor
public class UserQuest {

    @Id
    @Type(type = "uuid-char")
    @Column(columnDefinition = "char")
    private UUID id;

    @Type(type = "uuid-char")
    @Column(columnDefinition = "char", nullable = false)
    private UUID userId;

    @Type(type = "uuid-char")
    @Column(columnDefinition = "char", nullable = false)
    private UUID questDefinitionId;

    /** Ngày giao (DAILY) hoặc thứ Hai đầu tuần (WEEKLY). */
    @Column(nullable = false)
    private LocalDate periodStart;

    @Column(nullable = false)
    private Integer currentValue = 0;

    @Column(nullable = false)
    private Integer targetValue;

    @Column(nullable = false)
    private Integer xpReward;

    private Instant completedAt;

    @Column(nullable = false)
    private Boolean isClaimed = false;

    private Instant claimedAt;

    @Version
    private Integer version;

    @Column(insertable = false, updatable = false)
    private Instant createdAt;

    @Column(insertable = false, updatable = false)
    private Instant updatedAt;

    @PrePersist
    void ensureId() {
        if (id == null) {
            id = UUID.randomUUID();
        }
    }
}
