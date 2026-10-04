package com.flash.progress.entity;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.Type;

import javax.persistence.*;
import java.time.Instant;
import java.util.UUID;

/** Tối đa 1 ghi chú / (user, flashcard). Xoá = soft delete để đồng bộ. */
@Entity
@Table(name = "user_flashcard_notes")
@Getter
@Setter
@NoArgsConstructor
public class UserFlashcardNote {

    @Id
    @Type(type = "uuid-char")
    @Column(columnDefinition = "char")
    private UUID id;

    @Type(type = "uuid-char")
    @Column(columnDefinition = "char", nullable = false)
    private UUID userId;

    @Type(type = "uuid-char")
    @Column(columnDefinition = "char", nullable = false)
    private UUID flashcardId;

    @Column(columnDefinition = "text", nullable = false)
    private String content;

    @Version
    private Integer version;

    @Column(nullable = false)
    private Instant clientUpdatedAt;

    @Column(insertable = false, updatable = false)
    private Instant createdAt;

    @Column(insertable = false, updatable = false)
    private Instant updatedAt;

    private Instant deletedAt;

    @PrePersist
    void ensureId() {
        if (id == null) {
            id = UUID.randomUUID();
        }
    }
}
