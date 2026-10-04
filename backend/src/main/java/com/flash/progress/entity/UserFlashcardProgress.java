package com.flash.progress.entity;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.Type;

import javax.persistence.*;
import java.time.Instant;
import java.util.UUID;

/**
 * Trạng thái SRS hiện tại của (user, flashcard).
 * Server tính lại từ flashcard_review_logs, không nhận trực tiếp từ client.
 */
@Entity
@Table(name = "user_flashcard_progress")
@IdClass(UserFlashcardProgressId.class)
@Getter
@Setter
@NoArgsConstructor
public class UserFlashcardProgress {

    @Id
    @Type(type = "uuid-char")
    @Column(columnDefinition = "char")
    private UUID userId;

    @Id
    @Type(type = "uuid-char")
    @Column(columnDefinition = "char")
    private UUID flashcardId;

    /** Leitner box 0..5 */
    @Column(columnDefinition = "tinyint", nullable = false)
    private Integer box = 0;

    @Column(nullable = false)
    private Integer repetitions = 0;

    @Column(nullable = false)
    private Integer againCount = 0;

    @Column(nullable = false)
    private Integer knowCount = 0;

    @Enumerated(EnumType.STRING)
    @Column(columnDefinition = "enum")
    private SrsRating lastRating;

    /** true khi box >= 3 */
    @Column(nullable = false)
    private Boolean isLearned = false;

    private Instant lastReviewedAt;

    private Instant dueAt;

    @Version
    private Integer version;

    @Column(insertable = false, updatable = false)
    private Instant createdAt;

    @Column(insertable = false, updatable = false)
    private Instant updatedAt;
}
