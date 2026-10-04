package com.flash.gamification.entity;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.Type;

import javax.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "reward_items")
@Getter
@Setter
@NoArgsConstructor
public class RewardItem {

    @Id
    @Type(type = "uuid-char")
    @Column(columnDefinition = "char")
    private UUID id;

    @Column(nullable = false)
    private String code;

    @Column(nullable = false)
    private String name;

    private String description;

    @Enumerated(EnumType.STRING)
    @Column(columnDefinition = "enum", nullable = false)
    private RewardItemType itemType;

    @Column(nullable = false)
    private Integer xpCost = 0;

    /** JSON array số ARGB, VD: [4293059298, 4291548641]. */
    @Column(columnDefinition = "json")
    private String borderColors;

    private String imageUrl;

    /** 0 = không yêu cầu; 3 = phải nằm trong Top 3. */
    @Column(columnDefinition = "smallint", nullable = false)
    private Integer requiredRank = 0;

    @Enumerated(EnumType.STRING)
    @Column(columnDefinition = "enum", nullable = false)
    private RankBoard rankBoard = RankBoard.XP;

    @Column(nullable = false)
    private Boolean isActive = true;

    @Column(nullable = false)
    private Integer sortOrder = 0;

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
