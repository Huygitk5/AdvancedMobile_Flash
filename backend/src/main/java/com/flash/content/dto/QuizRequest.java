package com.flash.content.dto;

import com.flash.content.entity.QuizType;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import javax.validation.Valid;
import javax.validation.constraints.Max;
import javax.validation.constraints.Min;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotEmpty;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;
import java.util.List;
import java.util.UUID;

/** Tạo / sửa quiz. questions thay toàn bộ danh sách cũ. */
@Getter
@Setter
@NoArgsConstructor
public class QuizRequest {

    @NotBlank
    @Size(max = 150)
    private String title;

    @NotNull
    private QuizType quizType;

    /** Bắt buộc khi quizType = TOPIC. */
    private UUID topicId;

    /** Bắt buộc khi quizType = GRAMMAR. */
    private UUID grammarLessonId;

    @Min(10)
    private Integer timeLimitSeconds;

    @Min(0)
    @Max(100)
    private Integer passScorePercent;

    private Boolean isPublished;

    @NotEmpty
    @Valid
    private List<Question> questions;

    @Getter
    @Setter
    @NoArgsConstructor
    public static class Question {

        @NotBlank
        private String questionText;

        /** Đúng 4 đáp án A, B, C, D. */
        @NotNull
        @Size(min = 4, max = 4)
        private List<@NotBlank @Size(max = 500) String> options;

        @NotNull
        @Min(0)
        @Max(3)
        private Integer correctOptionIndex;

        private String explanation;

        private UUID flashcardId;
    }
}
