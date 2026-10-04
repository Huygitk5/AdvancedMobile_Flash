package com.flash.progress.entity;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.Type;

import javax.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "quiz_attempt_answers")
@IdClass(QuizAttemptAnswerId.class)
@Getter
@Setter
@NoArgsConstructor
public class QuizAttemptAnswer {

    @Id
    @Type(type = "uuid-char")
    @Column(columnDefinition = "char")
    private UUID attemptId;

    @Id
    @Type(type = "uuid-char")
    @Column(columnDefinition = "char")
    private UUID questionId;

    /** null = bỏ qua câu này (bên Dart là -1). */
    @Column(columnDefinition = "tinyint")
    private Integer selectedOptionIndex;

    @Column(nullable = false)
    private Boolean isCorrect;

    private Instant answeredAt;
}
