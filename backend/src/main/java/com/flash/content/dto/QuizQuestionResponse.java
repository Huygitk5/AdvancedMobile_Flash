package com.flash.content.dto;

import lombok.Builder;
import lombok.Getter;

import java.util.List;
import java.util.UUID;

/**
 * Khớp model QuizQuestion bên Flutter. Có correctAnswerIndex + explanation để làm bài offline;
 * điểm chính thức vẫn do server chấm khi nộp bài (DATA_ARCHITECTURE.md §5.3d).
 */
@Getter
@Builder
public class QuizQuestionResponse {

    private final UUID id;
    private final UUID quizId;
    private final UUID topicId;
    private final UUID flashcardId;
    private final String questionText;
    private final List<String> options;
    private final Integer correctAnswerIndex;
    private final String explanation;
}
