package com.flash.content.dto;

import com.flash.content.entity.Quiz;
import com.flash.content.entity.QuizType;
import lombok.Builder;
import lombok.Getter;

import java.util.UUID;

@Getter
@Builder
public class QuizResponse {

    private final UUID id;
    private final String title;
    private final QuizType quizType;
    private final UUID topicId;
    private final UUID grammarLessonId;
    private final Integer timeLimitSeconds;
    private final Integer passScorePercent;
    private final Integer questionCount;

    /** Chỉ trả cho admin. */
    private final Boolean isPublished;

    public static QuizResponse of(Quiz quiz, int questionCount, boolean forAdmin) {
        return QuizResponse.builder()
                .id(quiz.getId())
                .title(quiz.getTitle())
                .quizType(quiz.getQuizType())
                .topicId(quiz.getTopicId())
                .grammarLessonId(quiz.getGrammarLessonId())
                .timeLimitSeconds(quiz.getTimeLimitSeconds())
                .passScorePercent(quiz.getPassScorePercent())
                .questionCount(questionCount)
                .isPublished(forAdmin ? quiz.getIsPublished() : null)
                .build();
    }
}
