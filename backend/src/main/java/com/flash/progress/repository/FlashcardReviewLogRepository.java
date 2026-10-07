package com.flash.progress.repository;

import com.flash.progress.entity.FlashcardReviewLog;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public interface FlashcardReviewLogRepository extends JpaRepository<FlashcardReviewLog, UUID> {

    /** Toàn bộ log của một thẻ theo thứ tự thời gian, để phát lại tính SRS. */
    List<FlashcardReviewLog> findByUserIdAndFlashcardIdOrderByReviewedAtAscIdAsc(UUID userId, UUID flashcardId);

    long countByUserIdAndReviewedAtBetween(UUID userId, Instant from, Instant to);
}
