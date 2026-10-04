package com.flash.content.entity;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.Type;

import javax.persistence.*;
import java.util.UUID;

@Entity
@Table(name = "quiz_question_options")
@IdClass(QuizQuestionOptionId.class)
@Getter
@Setter
@NoArgsConstructor
public class QuizQuestionOption {

    @Id
    @Type(type = "uuid-char")
    @Column(columnDefinition = "char")
    private UUID questionId;

    /** 0=A, 1=B, 2=C, 3=D */
    @Id
    @Column(columnDefinition = "tinyint")
    private Integer optionIndex;

    @Column(nullable = false)
    private String optionText;
}
