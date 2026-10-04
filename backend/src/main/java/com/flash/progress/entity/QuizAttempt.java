package com.flash.progress.entity;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.Type;

import javax.persistence.*;
import java.time.Instant;
import java.util.UUID;

/** Một lần làm quiz (QuizResult). Điểm do server chấm từ quiz_attempt_answers. */
@Entity
@Table(name = "quiz_attempts")
@Getter
@Setter
@NoArgsConstructor
public class QuizAttempt {

    @Id
    @Type(type = "uuid-char")
    @Column(columnDefinition = "char")
    private UUID id;

    @Type(type = "uuid-char")
    @Column(columnDefinition = "char", nullable = false)
    private UUID userId;

    @Type(type = "uuid-char")
    @Column(columnDefinition = "char", nullable = false)
    private UUID quizId;

    @Column(columnDefinition = "smallint", nullable = false)
    private Integer totalQuestions;

    @Column(columnDefinition = "smallint", nullable = false)
    private Integer correctAnswers;

    @Column(columnDefinition = "smallint", nullable = false)
    private Integer wrongAnswers;

    @Column(columnDefinition = "tinyint", nullable = false)
    private Integer scorePercent;

    @Column(nullable = false)
    private Integer timeTakenSeconds;

    @Column(nullable = false)
    private Instant startedAt;

    @Column(nullable = false)
    private Instant submittedAt;

    @Column(insertable = false, updatable = false)
    private Instant receivedAt;
}
