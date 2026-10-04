package com.flash.gamification.repository;

import com.flash.gamification.entity.RewardItem;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface RewardItemRepository extends JpaRepository<RewardItem, UUID> {

    List<RewardItem> findAllByOrderBySortOrderAscCreatedAtAsc();

    List<RewardItem> findByIsActiveTrueOrderBySortOrderAscCreatedAtAsc();

    boolean existsByCode(String code);

    boolean existsByCodeAndIdNot(String code, UUID id);
}
