package com.flash.content.repository;

import com.flash.common.enums.ProgressStatus;
import com.flash.content.entity.GrammarLesson;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface GrammarLessonRepository extends JpaRepository<GrammarLesson, UUID> {

    String WITH_PROGRESS = "from GrammarLesson g left join UserGrammarProgress p "
            + "on p.grammarLessonId = g.id and p.userId = :userId "
            + "where g.deletedAt is null and (g.isPublished = true or :includeUnpublished = true) "
            + "and (:keyword is null or lower(g.title) like lower(concat('%', :keyword, '%'))) "
            + "and (:anyStatus = true or p.status in :statuses or (:includeMissing = true and p.status is null))";

    /** Mỗi phần tử: [GrammarLesson, UserGrammarProgress hoặc null]. */
    @Query(value = "select g, p " + WITH_PROGRESS + " order by g.sortOrder, g.title",
            countQuery = "select count(g) " + WITH_PROGRESS)
    Page<Object[]> searchWithProgress(@Param("userId") UUID userId,
                                      @Param("keyword") String keyword,
                                      @Param("includeUnpublished") boolean includeUnpublished,
                                      @Param("anyStatus") boolean anyStatus,
                                      @Param("statuses") Collection<ProgressStatus> statuses,
                                      @Param("includeMissing") boolean includeMissing,
                                      Pageable pageable);

    Optional<GrammarLesson> findByIdAndDeletedAtIsNull(UUID id);

    List<GrammarLesson> findByIsPublishedTrueAndDeletedAtIsNullOrderBySortOrder();
}
