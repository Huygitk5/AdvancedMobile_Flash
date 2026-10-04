package com.flash.progress.dto;

import lombok.Builder;
import lombok.Getter;

import java.util.List;
import java.util.UUID;

/** Khớp model QuizReviewItem bên Flutter. userIndex = -1 khi bỏ qua câu đó. */
@Getter
@Builder
public class QuizReviewItemResponse {

    /** id câu hỏi. */
    private final UUID id;
    private final String question;
    private final List<String> options;
    private final int correctIndex;
    private final int userIndex;
    private final Boolean isCorrect;
    private final String explanation;
}
