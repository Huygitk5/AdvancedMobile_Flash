package com.flash.content.entity;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.Type;

import javax.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "quiz_questions")
@Getter
@Setter
@NoArgsConstructor
public class QuizQuestion {

    @Id
    @Type(type = "uuid-char")
    @Column(columnDefinition = "char")
    private UUID id;

    @Type(type = "uuid-char")
    @Column(columnDefinition = "char", nullable = false)
    private UUID quizId;

    /** Câu hỏi sinh từ từ vựng nào (nếu có). */
    @Type(type = "uuid-char")
    @Column(columnDefinition = "char")
    private UUID flashcardId;

    @Column(columnDefinition = "text", nullable = false)
    private String questionText;

    /** 0=A, 1=B, 2=C, 3=D */
    @Column(columnDefinition = "tinyint", nullable = false)
    private Integer correctOptionIndex;

    @Column(columnDefinition = "text")
    private String explanation;

    @Column(nullable = false)
    private Integer sortOrder = 0;

    @Version
    private Integer version;

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
