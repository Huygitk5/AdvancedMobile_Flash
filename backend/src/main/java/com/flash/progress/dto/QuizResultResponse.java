package com.flash.progress.dto;

import com.flash.content.entity.Quiz;
import com.flash.progress.entity.QuizAttempt;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

/** Khớp model QuizResult bên Flutter, thêm quizId / scorePercent / xpAwarded (Phụ lục B). */
@Getter
@Builder
public class QuizResultResponse {

    private final UUID id;
    private final UUID userId;
    private final UUID quizId;
    private final String quizTitle;
    private final UUID topicId;
    private final UUID grammarLessonId;
    private final int totalQuestions;
    private final int correctAnswers;
    private final int wrongAnswers;
    private final int scorePercent;
    private final Boolean passed;
    private final int timeTakenSeconds;
    private final Instant startedAt;
    private final Instant submittedAt;

    /** Câu sai hoặc bỏ qua, để QuizReviewScreen lọc. */
    private final List<UUID> wrongQuestionIds;

    /** Chỉ có trong response của /submit. */
    private final Integer xpAwarded;
    private final Boolean duplicate;

    public static QuizResultResponseBuilder base(QuizAttempt attempt, Quiz quiz, List<UUID> wrongQuestionIds) {
        return QuizResultResponse.builder()
                .id(attempt.getId())
                .userId(attempt.getUserId())
                .quizId(attempt.getQuizId())
                .quizTitle(quiz != null ? quiz.getTitle() : null)
                .topicId(quiz != null ? quiz.getTopicId() : null)
                .grammarLessonId(quiz != null ? quiz.getGrammarLessonId() : null)
                .totalQuestions(attempt.getTotalQuestions())
                .correctAnswers(attempt.getCorrectAnswers())
                .wrongAnswers(attempt.getWrongAnswers())
                .scorePercent(attempt.getScorePercent())
                .passed(quiz != null ? attempt.getScorePercent() >= quiz.getPassScorePercent() : null)
                .timeTakenSeconds(attempt.getTimeTakenSeconds())
                .startedAt(attempt.getStartedAt())
                .submittedAt(attempt.getSubmittedAt())
                .wrongQuestionIds(wrongQuestionIds);
    }
}
