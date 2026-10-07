package com.flash.progress.repository;

import com.flash.progress.entity.LessonCompletion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.Instant;
import java.util.UUID;

public interface LessonCompletionRepository extends JpaRepository<LessonCompletion, UUID> {

    boolean existsByUserIdAndTopicId(UUID userId, UUID topicId);

    boolean existsByUserIdAndGrammarLessonId(UUID userId, UUID grammarLessonId);

    /** Số chủ đề từ vựng khác nhau đã hoàn thành trong khoảng [from, to): học lại cùng một bài chỉ tính một lần. */
    @Query("select count(distinct c.topicId) from LessonCompletion c "
            + "where c.userId = :userId and c.completedAt >= :from and c.completedAt < :to")
    long countDistinctTopics(@Param("userId") UUID userId, @Param("from") Instant from, @Param("to") Instant to);

    /** Số chủ điểm ngữ pháp khác nhau đã hoàn thành trong khoảng [from, to). */
    @Query("select count(distinct c.grammarLessonId) from LessonCompletion c "
            + "where c.userId = :userId and c.completedAt >= :from and c.completedAt < :to")
    long countDistinctGrammarLessons(@Param("userId") UUID userId, @Param("from") Instant from, @Param("to") Instant to);
}
