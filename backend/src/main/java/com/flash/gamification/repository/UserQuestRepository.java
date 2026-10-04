package com.flash.gamification.repository;

import com.flash.gamification.entity.QuestType;
import com.flash.gamification.entity.UserQuest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface UserQuestRepository extends JpaRepository<UserQuest, UUID> {

    List<UserQuest> findByUserIdAndPeriodStartOrderByCreatedAt(UUID userId, LocalDate periodStart);

    List<UserQuest> findByUserIdAndPeriodStartIn(UUID userId, Collection<LocalDate> periodStarts);

    Optional<UserQuest> findByIdAndUserId(UUID id, UUID userId);

    /** Nhiệm vụ đã giao có loại = type, thuộc một trong các chu kỳ cho trước, chưa nhận thưởng. */
    @Query("select q from UserQuest q, QuestDefinition d where d.id = q.questDefinitionId "
            + "and q.userId = :userId and d.questType = :type and q.periodStart in :periods and q.isClaimed = false")
    List<UserQuest> findOpenByType(@Param("userId") UUID userId, @Param("type") QuestType type,
                                   @Param("periods") Collection<LocalDate> periods);
}
