package com.flash.content.repository;

import com.flash.content.entity.Flashcard;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface FlashcardRepository extends JpaRepository<Flashcard, UUID> {

    /** Ghép trạng thái của user trong 1 query (tránh N+1): [Flashcard, progress, note, bookmark]. */
    String WITH_USER_STATE = "select f, p, n, b from Flashcard f "
            + "left join UserFlashcardProgress p on p.flashcardId = f.id and p.userId = :userId "
            + "left join UserFlashcardNote n on n.flashcardId = f.id and n.userId = :userId and n.deletedAt is null "
            + "left join UserBookmark b on b.flashcardId = f.id and b.userId = :userId and b.deletedAt is null ";

    @Query(WITH_USER_STATE + "where f.topicId = :topicId and f.deletedAt is null order by f.sortOrder, f.word")
    List<Object[]> findByTopicWithUserState(@Param("topicId") UUID topicId, @Param("userId") UUID userId);

    @Query(WITH_USER_STATE + "where f.id in :ids and f.deletedAt is null")
    List<Object[]> findByIdsWithUserState(@Param("ids") Collection<UUID> ids, @Param("userId") UUID userId);

    Optional<Flashcard> findByIdAndDeletedAtIsNull(UUID id);

    /** Gồm cả bản đã xoá mềm: UNIQUE(topic_id, word) vẫn tính dòng đó, nên tạo lại = khôi phục. */
    Optional<Flashcard> findByTopicIdAndWord(UUID topicId, String word);

    String SEARCH_FROM = "FROM flashcards f JOIN topics t ON t.id = f.topic_id "
            + "WHERE f.deleted_at IS NULL AND t.deleted_at IS NULL AND t.is_published = TRUE "
            + "AND (MATCH(f.word, f.meaning) AGAINST (:terms IN BOOLEAN MODE) OR f.word LIKE :prefix) ";

    /**
     * FULLTEXT trên (word, meaning) + LIKE tiền tố trên word.
     * Xếp hạng: trùng khớp chính xác > khớp tiền tố > điểm FULLTEXT.
     */
    @Query(value = "SELECT f.id " + SEARCH_FROM
            + "ORDER BY (f.word = :keyword) DESC, (f.word LIKE :prefix) DESC, "
            + "MATCH(f.word, f.meaning) AGAINST (:terms IN BOOLEAN MODE) DESC, f.word "
            + "LIMIT :limit OFFSET :offset", nativeQuery = true)
    List<String> searchIds(@Param("terms") String terms, @Param("prefix") String prefix,
                           @Param("keyword") String keyword, @Param("limit") int limit, @Param("offset") long offset);

    @Query(value = "SELECT COUNT(*) " + SEARCH_FROM, nativeQuery = true)
    long countSearch(@Param("terms") String terms, @Param("prefix") String prefix);
}
