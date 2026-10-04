package com.flash.progress.repository;

import com.flash.progress.entity.LessonCompletion;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.Instant;
import java.util.UUID;

public interface LessonCompletionRepository extends JpaRepository<LessonCompletion, UUID> {

    long countByUserIdAndCompletedAtGreaterThanEqualAndCompletedAtLessThan(UUID userId, Instant from, Instant to);
}
