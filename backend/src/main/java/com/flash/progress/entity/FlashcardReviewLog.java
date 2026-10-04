package com.flash.progress.entity;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.Type;

import javax.persistence.*;
import java.time.Instant;
import java.util.UUID;

/** Append-only, mỗi lần bấm Again/Know. id do client sinh nên gửi lại không bị nhân đôi. */
@Entity
@Table(name = "flashcard_review_logs")
@Getter
@Setter
@NoArgsConstructor
public class FlashcardReviewLog {

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

    @Enumerated(EnumType.STRING)
    @Column(columnDefinition = "enum", nullable = false)
    private SrsRating rating;

    @Column(columnDefinition = "tinyint", nullable = false)
    private Integer boxBefore;

    @Column(columnDefinition = "tinyint", nullable = false)
    private Integer boxAfter;

    private Integer responseTimeMs;

    /** Giờ client, đã hiệu chỉnh lệch đồng hồ. */
    @Column(nullable = false)
    private Instant reviewedAt;

    @Column(insertable = false, updatable = false)
    private Instant receivedAt;
}
