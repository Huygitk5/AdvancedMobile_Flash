package com.flash.content.repository;

import com.flash.content.entity.QuizQuestionOption;
import com.flash.content.entity.QuizQuestionOptionId;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;
import java.util.List;
import java.util.UUID;

public interface QuizQuestionOptionRepository extends JpaRepository<QuizQuestionOption, QuizQuestionOptionId> {

    List<QuizQuestionOption> findByQuestionIdInOrderByQuestionIdAscOptionIndexAsc(Collection<UUID> questionIds);
}
