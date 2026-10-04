package com.flash.content.entity;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.Type;

import javax.persistence.*;
import java.time.Instant;
import java.util.UUID;

/** Thuộc đúng 1 trong 2: topic HOẶC grammar lesson (enforce ở service). */
@Entity
@Table(name = "quizzes")
@Getter
@Setter
@NoArgsConstructor
public class Quiz {

    @Id
    @Type(type = "uuid-char")
    @Column(columnDefinition = "char")
    private UUID id;

    @Column(nullable = false)
    private String title;

    @Enumerated(EnumType.STRING)
    @Column(columnDefinition = "enum", nullable = false)
    private QuizType quizType;

    @Type(type = "uuid-char")
    @Column(columnDefinition = "char")
    private UUID topicId;

    @Type(type = "uuid-char")
    @Column(columnDefinition = "char")
    private UUID grammarLessonId;

    private Integer timeLimitSeconds;

    @Column(columnDefinition = "tinyint", nullable = false)
    private Integer passScorePercent = 70;

    @Column(nullable = false)
    private Boolean isPublished = false;

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
