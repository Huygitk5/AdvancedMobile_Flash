package com.flash.gamification.dto;

import com.flash.gamification.entity.RankBoard;
import com.flash.gamification.entity.RewardItemType;
import lombok.Builder;
import lombok.Getter;

import java.util.List;
import java.util.UUID;

/** Nội dung vật phẩm (bản admin). Bản có isUnlocked / isEquipped của user là ShopItemResponse. */
@Getter
@Builder
public class RewardItemResponse {

    private final UUID id;
    private final String code;
    private final String name;
    private final String description;
    private final RewardItemType itemType;
    private final Integer xpCost;
    private final List<Long> borderColors;
    private final String imageUrl;
    private final Integer requiredRank;
    private final RankBoard rankBoard;
    private final Boolean isActive;
    private final Integer sortOrder;
}
