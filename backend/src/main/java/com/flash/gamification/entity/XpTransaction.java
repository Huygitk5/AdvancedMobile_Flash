package com.flash.gamification.entity;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.Type;

import javax.persistence.*;
import java.time.Instant;
import java.util.UUID;

/**
 * Sổ cái XP. users.current_xp / total_lifetime_xp là số dư cache của bảng này.
 * UNIQUE(user_id, source_type, source_id) bảo đảm mỗi sự kiện chỉ cộng XP 1 lần.
 */
@Entity
@Table(name = "xp_transactions")
@Getter
@Setter
@NoArgsConstructor
public class XpTransaction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Type(type = "uuid-char")
    @Column(columnDefinition = "char", nullable = false)
    private UUID userId;

    /** Dương = nhận, âm = tiêu (mua đồ). */
    @Column(nullable = false)
    private Integer amount;

    @Column(nullable = false)
    private Integer balanceAfter;

    @Enumerated(EnumType.STRING)
    @Column(columnDefinition = "enum", nullable = false)
    private XpSourceType sourceType;

    @Column(nullable = false)
    private String sourceId;

    private String note;

    @Column(insertable = false, updatable = false)
    private Instant createdAt;
}
