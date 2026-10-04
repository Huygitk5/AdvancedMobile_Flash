package com.flash.gamification.dto;

import com.flash.gamification.entity.UserInventory;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.util.UUID;

/** Khớp model UserInventory bên Flutter, kèm thông tin vật phẩm. */
@Getter
@Builder
public class InventoryResponse {

    private final UUID id;
    private final UUID userId;
    private final UUID rewardItemId;
    private final Boolean isEquipped;
    private final Instant unlockedAt;
    private final Integer version;
    private final Instant clientUpdatedAt;
    private final RewardItemResponse item;

    public static InventoryResponse of(UserInventory inventory, RewardItemResponse item) {
        return InventoryResponse.builder()
                .id(inventory.getId())
                .userId(inventory.getUserId())
                .rewardItemId(inventory.getRewardItemId())
                .isEquipped(inventory.getIsEquipped())
                .unlockedAt(inventory.getUnlockedAt())
                .version(inventory.getVersion())
                .clientUpdatedAt(inventory.getClientUpdatedAt())
                .item(item)
                .build();
    }
}
