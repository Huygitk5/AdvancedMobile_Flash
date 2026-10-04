package com.flash.progress.repository;

import com.flash.common.enums.ProgressStatus;
import com.flash.progress.entity.UserTopicProgress;
import com.flash.progress.entity.UserTopicProgressId;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface UserTopicProgressRepository extends JpaRepository<UserTopicProgress, UserTopicProgressId> {

    Optional<UserTopicProgress> findByUserIdAndTopicId(UUID userId, UUID topicId);

    Optional<UserTopicProgress> findFirstByUserIdAndStatusOrderByLastStudiedAtDesc(UUID userId, ProgressStatus status);

    List<UserTopicProgress> findByUserId(UUID userId);
}
