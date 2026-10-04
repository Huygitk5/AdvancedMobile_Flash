package com.flash.progress.repository;

import com.flash.progress.entity.UserFlashcardProgress;
import com.flash.progress.entity.UserFlashcardProgressId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;
import java.util.UUID;

public interface UserFlashcardProgressRepository extends JpaRepository<UserFlashcardProgress, UserFlashcardProgressId> {

    Optional<UserFlashcardProgress> findByUserIdAndFlashcardId(UUID userId, UUID flashcardId);

    long countByUserIdAndIsLearnedTrue(UUID userId);

    /** Số từ đã thuộc trong topic (bỏ qua từ đã bị xoá khỏi topic). */
    @Query("select count(p) from UserFlashcardProgress p, Flashcard f where f.id = p.flashcardId "
            + "and p.userId = :userId and p.isLearned = true and f.topicId = :topicId and f.deletedAt is null")
    long countLearnedInTopic(@Param("userId") UUID userId, @Param("topicId") UUID topicId);
}
