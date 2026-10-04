package com.flash.content.repository;

import com.flash.content.entity.GrammarExample;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public interface GrammarExampleRepository extends JpaRepository<GrammarExample, UUID> {

    List<GrammarExample> findByGrammarLessonIdAndDeletedAtIsNullOrderBySortOrder(UUID grammarLessonId);

    /** Xoá mềm để client đồng bộ biết ví dụ cũ đã bị bỏ. */
    @Modifying
    @Query("update GrammarExample e set e.deletedAt = :now "
            + "where e.grammarLessonId = :grammarLessonId and e.deletedAt is null")
    int softDeleteByLesson(@Param("grammarLessonId") UUID grammarLessonId, @Param("now") Instant now);
}
