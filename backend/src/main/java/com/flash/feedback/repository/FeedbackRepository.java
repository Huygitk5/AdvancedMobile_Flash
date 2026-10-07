package com.flash.feedback.repository;

import com.flash.feedback.entity.Feedback;
import com.flash.feedback.entity.FeedbackType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

/** Lọc + phân trang dùng Specification (FeedbackSpecs) vì mọi tham số lọc đều tuỳ chọn. */
public interface FeedbackRepository extends JpaRepository<Feedback, UUID>, JpaSpecificationExecutor<Feedback> {

    boolean existsByIdAndUserId(UUID id, UUID userId);

    /** Mỗi phần tử: [FeedbackType, Long] - số feedback của user theo loại (loại không có thì không xuất hiện). */
    @Query("select f.feedbackFor, count(f) from Feedback f where f.userId = :userId group by f.feedbackFor")
    List<Object[]> countByType(@Param("userId") UUID userId);

    // ---- Sửa / xoá / đánh dấu đã xem: 1 câu lệnh có điều kiện nên không bị race với admin đánh dấu "đã xem".
    // clearAutomatically: sau đó service đọc lại bản ghi, không được lấy bản cũ từ persistence context.

    @Modifying(flushAutomatically = true, clearAutomatically = true)
    @Query("update Feedback f set f.content = :content, f.updatedAt = :now "
            + "where f.id = :id and f.userId = :userId and f.isViewed = false")
    int updateContentIfNotViewed(@Param("id") UUID id, @Param("userId") UUID userId,
                                 @Param("content") String content, @Param("now") Instant now);

    @Modifying(flushAutomatically = true, clearAutomatically = true)
    @Query("delete from Feedback f where f.id = :id and f.userId = :userId and f.isViewed = false")
    int deleteIfNotViewed(@Param("id") UUID id, @Param("userId") UUID userId);

    @Modifying(flushAutomatically = true, clearAutomatically = true)
    @Query("update Feedback f set f.isViewed = :viewed, f.updatedAt = :now where f.id = :id")
    int updateViewed(@Param("id") UUID id, @Param("viewed") boolean viewed, @Param("now") Instant now);

    // ---- Xoá cứng khi item bị xoá mềm. Không clearAutomatically: các service gọi giữa chừng khi đang giữ
    // entity vừa sửa (setDeletedAt) chưa flush, clear sẽ làm mất thay đổi đó.

    @Modifying(flushAutomatically = true)
    @Query("delete from Feedback f where f.feedbackFor = :type and f.itemId = :itemId")
    int deleteByItem(@Param("type") FeedbackType type, @Param("itemId") UUID itemId);

    /** Feedback quiz của mọi quiz thuộc một chủ điểm ngữ pháp (kể cả quiz đã xoá mềm). */
    @Modifying(flushAutomatically = true)
    @Query("delete from Feedback f where f.feedbackFor = :type "
            + "and f.itemId in (select q.id from Quiz q where q.grammarLessonId = :grammarLessonId)")
    int deleteQuizFeedbackByGrammar(@Param("type") FeedbackType type, @Param("grammarLessonId") UUID grammarLessonId);

    /** Feedback quiz của mọi quiz thuộc một topic. */
    @Modifying(flushAutomatically = true)
    @Query("delete from Feedback f where f.feedbackFor = :type "
            + "and f.itemId in (select q.id from Quiz q where q.topicId = :topicId)")
    int deleteQuizFeedbackByTopic(@Param("type") FeedbackType type, @Param("topicId") UUID topicId);

    /** Feedback flashcard của mọi flashcard thuộc một topic. */
    @Modifying(flushAutomatically = true)
    @Query("delete from Feedback f where f.feedbackFor = :type "
            + "and f.itemId in (select c.id from Flashcard c where c.topicId = :topicId)")
    int deleteFlashcardFeedbackByTopic(@Param("type") FeedbackType type, @Param("topicId") UUID topicId);
}
