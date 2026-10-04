package com.flash.content.repository;

import com.flash.content.entity.Quiz;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface QuizRepository extends JpaRepository<Quiz, UUID> {

    @Query("select q from Quiz q where q.deletedAt is null "
            + "and (q.isPublished = true or :includeUnpublished = true) "
            + "and (:topicId is null or q.topicId = :topicId) "
            + "and (:grammarLessonId is null or q.grammarLessonId = :grammarLessonId) "
            + "order by q.createdAt")
    List<Quiz> search(@Param("topicId") UUID topicId, @Param("grammarLessonId") UUID grammarLessonId,
                      @Param("includeUnpublished") boolean includeUnpublished);

    Optional<Quiz> findByIdAndDeletedAtIsNull(UUID id);

    Optional<Quiz> findFirstByGrammarLessonIdAndIsPublishedTrueAndDeletedAtIsNullOrderByCreatedAt(UUID grammarLessonId);
}
