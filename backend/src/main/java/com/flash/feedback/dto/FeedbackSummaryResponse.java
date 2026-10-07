package com.flash.feedback.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

/** Số feedback của user theo loại. */
@Getter
@AllArgsConstructor
public class FeedbackSummaryResponse {

    private final int flashcard;
    private final int grammar;
    private final int quiz;
}
