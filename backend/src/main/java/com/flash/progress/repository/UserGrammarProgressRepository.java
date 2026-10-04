package com.flash.progress.repository;

import com.flash.common.enums.ProgressStatus;
import com.flash.progress.entity.UserGrammarProgress;
import com.flash.progress.entity.UserGrammarProgressId;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface UserGrammarProgressRepository extends JpaRepository<UserGrammarProgress, UserGrammarProgressId> {

    Optional<UserGrammarProgress> findByUserIdAndGrammarLessonId(UUID userId, UUID grammarLessonId);

    Optional<UserGrammarProgress> findFirstByUserIdAndStatusOrderByLastStudiedAtDesc(UUID userId, ProgressStatus status);

    List<UserGrammarProgress> findByUserId(UUID userId);
}
