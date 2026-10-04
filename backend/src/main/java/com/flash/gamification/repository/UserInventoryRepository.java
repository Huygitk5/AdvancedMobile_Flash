package com.flash.gamification.repository;

import com.flash.gamification.entity.RewardItemType;
import com.flash.gamification.entity.UserInventory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface UserInventoryRepository extends JpaRepository<UserInventory, UUID> {

    List<UserInventory> findByUserIdOrderByUnlockedAt(UUID userId);

    Optional<UserInventory> findByIdAndUserId(UUID id, UUID userId);

    boolean existsByUserIdAndRewardItemId(UUID userId, UUID rewardItemId);

    /** Các món cùng loại đang trang bị (để tháo khi trang bị món mới). */
    @Query("select i from UserInventory i, RewardItem r where r.id = i.rewardItemId "
            + "and i.userId = :userId and i.isEquipped = true and r.itemType = :type")
    List<UserInventory> findEquippedByType(@Param("userId") UUID userId, @Param("type") RewardItemType type);

    /** Mỗi phần tử: [userId, border_colors JSON] của viền đang trang bị. */
    @Query("select i.userId, r.borderColors from UserInventory i, RewardItem r where r.id = i.rewardItemId "
            + "and i.userId in :userIds and i.isEquipped = true and r.itemType = com.flash.gamification.entity.RewardItemType.BORDER")
    List<Object[]> findEquippedBorders(@Param("userIds") Collection<UUID> userIds);
}
