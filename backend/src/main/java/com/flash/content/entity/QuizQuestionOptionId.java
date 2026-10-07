package com.flash.content.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.util.UUID;

/** Khoá chính phức hợp của {@link QuizQuestionOption}. */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class QuizQuestionOptionId implements Serializable {

    private UUID questionId;
    private Integer optionIndex;
}
