package com.flash.content.dto;

import com.flash.content.entity.GrammarExample;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.UUID;

@Getter
@AllArgsConstructor
public class GrammarExampleResponse {

    private final UUID id;
    private final String sentence;
    private final String translation;
    private final String highlight;
    private final Integer sortOrder;

    public static GrammarExampleResponse from(GrammarExample example) {
        return new GrammarExampleResponse(example.getId(), example.getSentence(), example.getTranslation(),
                example.getHighlight(), example.getSortOrder());
    }
}
