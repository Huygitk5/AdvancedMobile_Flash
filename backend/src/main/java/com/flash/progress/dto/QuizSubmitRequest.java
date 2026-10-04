package com.flash.progress.dto;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import javax.validation.Valid;
import javax.validation.constraints.Max;
import javax.validation.constraints.Min;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

/** Nộp bài: chỉ gửi đáp án đã chọn, điểm do server chấm (DATA_ARCHITECTURE.md §6.7). */
@Getter
@Setter
@NoArgsConstructor
public class QuizSubmitRequest {

    /** id do client sinh; nộp lại cùng attemptId trả về kết quả cũ. */
    @NotNull
    private UUID attemptId;

    @NotNull
    private UUID quizId;

    @NotNull
    private Instant startedAt;

    @NotNull
    private Instant submittedAt;

    @NotNull
    @Min(0)
    @Max(86_400)
    private Integer timeTakenSeconds;

    @NotNull
    @Size(max = 500)
    @Valid
    private List<Answer> answers;

    @Getter
    @Setter
    @NoArgsConstructor
    public static class Answer {

        @NotNull
        private UUID questionId;

        /** null = bỏ qua câu này. */
        @Min(0)
        @Max(3)
        private Integer selectedOptionIndex;
    }
}
