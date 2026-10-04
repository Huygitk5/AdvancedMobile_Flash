package com.flash.content.repository;

import com.flash.content.entity.QuizQuestion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.Instant;
import java.util.Collection;
import java.util.List;
import java.util.UUID;

public interface QuizQuestionRepository extends JpaRepository<QuizQuestion, UUID> {

    List<QuizQuestion> findByQuizIdAndDeletedAtIsNullOrderBySortOrder(UUID quizId);

    /** Mỗi phần tử: [quizId, số câu hỏi]. */
    @Query("select q.quizId, count(q) from QuizQuestion q "
            + "where q.quizId in :quizIds and q.deletedAt is null group by q.quizId")
    List<Object[]> countByQuizIds(@Param("quizIds") Collection<UUID> quizIds);

    /** Xoá mềm: quiz_attempt_answers cũ vẫn tham chiếu được câu hỏi để xem lại bài. */
    @Modifying
    @Query("update QuizQuestion q set q.deletedAt = :now where q.quizId = :quizId and q.deletedAt is null")
    int softDeleteByQuiz(@Param("quizId") UUID quizId, @Param("now") Instant now);
}
