package com.flash.progress.repository;

import com.flash.progress.entity.UserBookmark;
import com.flash.progress.entity.UserBookmarkId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import javax.persistence.LockModeType;
import java.util.Optional;
import java.util.UUID;

public interface UserBookmarkRepository extends JpaRepository<UserBookmark, UserBookmarkId> {

    /** Gồm cả tombstone (deletedAt khác null). */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select b from UserBookmark b where b.userId = :userId and b.flashcardId = :flashcardId")
    Optional<UserBookmark> findForUpdate(@Param("userId") UUID userId, @Param("flashcardId") UUID flashcardId);
}
