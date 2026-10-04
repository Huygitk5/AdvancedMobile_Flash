package com.flash.content.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.List;

@Getter
@AllArgsConstructor
public class QuizDetailResponse {

    private final QuizResponse quiz;
    private final List<QuizQuestionResponse> questions;
}
