package com.flash.content.dto;

import com.fasterxml.jackson.annotation.JsonUnwrapped;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.List;
import java.util.UUID;

/** Dữ liệu GrammarDetailScreen: các field của GrammarResponse + nội dung chi tiết. */
@Getter
@AllArgsConstructor
public class GrammarDetailResponse {

    @JsonUnwrapped
    private final GrammarResponse summary;

    private final String content;
    private final String usageNotes;
    private final List<GrammarExampleResponse> examples;

    /** Quiz luyện tập của chủ điểm (nút "Làm bài tập"), null nếu chưa có. */
    private final UUID quizId;
}
