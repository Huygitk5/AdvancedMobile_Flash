package com.flash.gamification.repository;

import com.flash.gamification.entity.QuestDefinition;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface QuestDefinitionRepository extends JpaRepository<QuestDefinition, UUID> {

    List<QuestDefinition> findAllByOrderBySortOrderAscCreatedAtAsc();

    boolean existsByCode(String code);

    boolean existsByCodeAndIdNot(String code, UUID id);
}
