package com.flash.progress.entity;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.Type;

import javax.persistence.*;
import java.time.Instant;
import java.util.UUID;

/** Một bài học hoàn thành. id do client sinh. Đúng 1 trong topicId / grammarLessonId khác null. */
@Entity
@Table(name = "lesson_completions")
@Getter
@Setter
@NoArgsConstructor
public class LessonCompletion {

    @Id
    @Type(type = "uuid-char")
    @Column(columnDefinition = "char")
    private UUID id;

    @Type(type = "uuid-char")
    @Column(columnDefinition = "char", nullable = false)
    private UUID userId;

    @Enumerated(EnumType.STRING)
    @Column(columnDefinition = "enum", nullable = false)
    private LessonType lessonType;

    @Type(type = "uuid-char")
    @Column(columnDefinition = "char")
    private UUID topicId;

    @Type(type = "uuid-char")
    @Column(columnDefinition = "char")
    private UUID grammarLessonId;

    @Column(nullable = false)
    private Integer cardsReviewed = 0;

    @Column(nullable = false)
    private Integer durationSeconds = 0;

    @Column(nullable = false)
    private Instant completedAt;

    @Column(insertable = false, updatable = false)
    private Instant receivedAt;
}
