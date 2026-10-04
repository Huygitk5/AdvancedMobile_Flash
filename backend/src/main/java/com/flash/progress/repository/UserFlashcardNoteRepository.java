package com.flash.progress.repository;

import com.flash.progress.entity.UserFlashcardNote;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import javax.persistence.LockModeType;
import java.util.Optional;
import java.util.UUID;

public interface UserFlashcardNoteRepository extends JpaRepository<UserFlashcardNote, UUID> {

    /** Gồm cả tombstone: xoá ghi chú cũng tham gia LWW như một lần sửa. */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select n from UserFlashcardNote n where n.userId = :userId and n.flashcardId = :flashcardId")
    Optional<UserFlashcardNote> findForUpdate(@Param("userId") UUID userId, @Param("flashcardId") UUID flashcardId);

    Optional<UserFlashcardNote> findByUserIdAndFlashcardIdAndDeletedAtIsNull(UUID userId, UUID flashcardId);
}
