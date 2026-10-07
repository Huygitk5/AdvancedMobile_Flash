package com.flash.gamification.dto;

import com.fasterxml.jackson.annotation.JsonUnwrapped;
import lombok.Builder;
import lombok.Getter;

import java.util.UUID;

/** Vật phẩm kèm trạng thái của user hiện tại (DATA_ARCHITECTURE.md §6.9). */
@Getter
@Builder
public class ShopItemResponse {

    @JsonUnwrapped
    private final RewardItemResponse item;

    private final Boolean isUnlocked;
    private final Boolean isEquipped;

    /** id dòng user_inventories, dùng cho /v1/shop/equip/{inventoryId}; null nếu chưa sở hữu. */
    private final UUID inventoryId;

    private final Boolean canAfford;
    private final Boolean meetsRankRequirement;
}
