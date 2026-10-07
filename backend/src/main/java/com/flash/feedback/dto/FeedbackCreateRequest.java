package com.flash.feedback.dto;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import java.util.UUID;

/** Tạo feedback. Độ dài tối đa (1000 ký tự, sau khi trim) được kiểm ở service. */
@Getter
@Setter
@NoArgsConstructor
public class FeedbackCreateRequest {

    /** 1 = flashcard, 2 = grammar, 3 = quiz. */
    @NotNull
    private Integer feedbackFor;

    @NotNull
    private UUID itemId;

    @NotBlank
    private String content;
}
