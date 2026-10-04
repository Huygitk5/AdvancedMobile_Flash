package com.flash.gamification.entity;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.Type;

import javax.persistence.*;
import java.time.Instant;
import java.util.UUID;

/** Có bản ghi = đã sở hữu. "Mỗi loại chỉ trang bị 1 món" được enforce ở ShopService. */
@Entity
@Table(name = "user_inventories")
@Getter
@Setter
@NoArgsConstructor
public class UserInventory {

    @Id
    @Type(type = "uuid-char")
    @Column(columnDefinition = "char")
    private UUID id;

    @Type(type = "uuid-char")
    @Column(columnDefinition = "char", nullable = false)
    private UUID userId;

    @Type(type = "uuid-char")
    @Column(columnDefinition = "char", nullable = false)
    private UUID rewardItemId;

    @Column(nullable = false)
    private Boolean isEquipped = false;

    @Column(insertable = false, updatable = false)
    private Instant unlockedAt;

    @Version
    private Integer version;

    /** LWW cho thao tác equip/unequip. */
    private Instant clientUpdatedAt;

    @Column(insertable = false, updatable = false)
    private Instant updatedAt;

    @PrePersist
    void ensureId() {
        if (id == null) {
            id = UUID.randomUUID();
        }
    }
}
