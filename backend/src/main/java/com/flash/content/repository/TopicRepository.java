package com.flash.content.repository;

import com.flash.common.enums.ProgressStatus;
import com.flash.content.entity.Topic;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface TopicRepository extends JpaRepository<Topic, UUID> {

    String WITH_PROGRESS = "from Topic t left join UserTopicProgress p on p.topicId = t.id and p.userId = :userId "
            + "where t.deletedAt is null and (t.isPublished = true or :includeUnpublished = true) "
            + "and (:keyword is null or lower(t.title) like lower(concat('%', :keyword, '%'))) "
            + "and (:anyStatus = true or p.status in :statuses or (:includeMissing = true and p.status is null))";

    /** Mỗi phần tử: [Topic, UserTopicProgress hoặc null]. */
    @Query(value = "select t, p " + WITH_PROGRESS + " order by t.sortOrder, t.title",
            countQuery = "select count(t) " + WITH_PROGRESS)
    Page<Object[]> searchWithProgress(@Param("userId") UUID userId,
                                      @Param("keyword") String keyword,
                                      @Param("includeUnpublished") boolean includeUnpublished,
                                      @Param("anyStatus") boolean anyStatus,
                                      @Param("statuses") Collection<ProgressStatus> statuses,
                                      @Param("includeMissing") boolean includeMissing,
                                      Pageable pageable);

    Optional<Topic> findByIdAndDeletedAtIsNull(UUID id);

    List<Topic> findByIsPublishedTrueAndDeletedAtIsNullOrderBySortOrder();

    /** Đếm lại total_words từ dữ liệu gốc thay vì +1/-1, nên không bao giờ lệch. */
    @Modifying(flushAutomatically = true)
    @Query("update Topic t set t.totalWords = "
            + "(select count(f) from Flashcard f where f.topicId = :topicId and f.deletedAt is null) "
            + "where t.id = :topicId")
    int recountTotalWords(@Param("topicId") UUID topicId);
}
