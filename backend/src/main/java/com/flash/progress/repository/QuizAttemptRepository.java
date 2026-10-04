package com.flash.progress.repository;

import com.flash.progress.entity.QuizAttempt;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

public interface QuizAttemptRepository extends JpaRepository<QuizAttempt, UUID> {

    Optional<QuizAttempt> findByIdAndUserId(UUID id, UUID userId);

    @Query("select a from QuizAttempt a where a.userId = :userId and (:quizId is null or a.quizId = :quizId) "
            + "order by a.submittedAt desc")
    Page<QuizAttempt> search(@Param("userId") UUID userId, @Param("quizId") UUID quizId, Pageable pageable);

    long countByUserIdAndQuizIdAndSubmittedAtGreaterThanEqualAndSubmittedAtLessThan(UUID userId, UUID quizId,
                                                                                     Instant from, Instant to);
}
