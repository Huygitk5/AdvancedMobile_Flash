package com.flash.feedback.entity;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.Type;

import javax.persistence.*;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.UUID;

/**
 * Phản hồi của user về một flashcard / grammar / quiz.
 * itemId đa hình nên không có FK; khi item bị xoá mềm thì feedback bị xoá cứng (xem FeedbackCleanup).
 */
@Entity
@Table(name = "feedbacks")
@Getter
@Setter
@NoArgsConstructor
public class Feedback {

    @Id
    @Type(type = "uuid-char")
    @Column(columnDefinition = "char")
    private UUID id;

    @Type(type = "uuid-char")
    @Column(columnDefinition = "char", nullable = false, updatable = false)
    private UUID userId;

    @Column(columnDefinition = "text", nullable = false)
    private String content;

    @Convert(converter = FeedbackTypeConverter.class)
    @Column(columnDefinition = "tinyint", nullable = false, updatable = false)
    private FeedbackType feedbackFor;

    @Type(type = "uuid-char")
    @Column(columnDefinition = "char", nullable = false, updatable = false)
    private UUID itemId;

    @Column(nullable = false)
    private Boolean isViewed = false;

    /** Gán ở Java (cắt về mili giây như DATETIME(3)) để response tạo mới có ngay createdAt mà không cần đọc lại. */
    @Column(nullable = false, updatable = false)
    private Instant createdAt;

    @Column(nullable = false)
    private Instant updatedAt;

    @PrePersist
    void onCreate() {
        if (id == null) {
            id = UUID.randomUUID();
        }
        Instant now = Instant.now().truncatedTo(ChronoUnit.MILLIS);
        if (createdAt == null) {
            createdAt = now;
        }
        if (updatedAt == null) {
            updatedAt = createdAt;
        }
    }
}
