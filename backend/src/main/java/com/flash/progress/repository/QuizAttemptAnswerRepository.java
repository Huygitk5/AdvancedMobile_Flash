package com.flash.progress.repository;

import com.flash.progress.entity.QuizAttemptAnswer;
import com.flash.progress.entity.QuizAttemptAnswerId;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;
import java.util.List;
import java.util.UUID;

public interface QuizAttemptAnswerRepository extends JpaRepository<QuizAttemptAnswer, QuizAttemptAnswerId> {

    List<QuizAttemptAnswer> findByAttemptId(UUID attemptId);

    List<QuizAttemptAnswer> findByAttemptIdIn(Collection<UUID> attemptIds);
}
