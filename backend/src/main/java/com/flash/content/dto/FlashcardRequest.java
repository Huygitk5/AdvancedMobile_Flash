package com.flash.content.dto;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;
import java.util.UUID;

/** Tạo / sửa flashcard (PUT thay toàn bộ). */
@Getter
@Setter
@NoArgsConstructor
public class FlashcardRequest {

    @NotNull
    private UUID topicId;

    @NotBlank
    @Size(max = 100)
    private String word;

    @NotBlank
    @Size(max = 30)
    private String partOfSpeech;

    @NotBlank
    @Size(max = 100)
    private String pronunciation;

    @NotBlank
    @Size(max = 500)
    private String meaning;

    private String example;

    private String exampleTranslation;

    @Size(max = 500)
    private String audioUrl;

    @Size(max = 500)
    private String imageUrl;

    private Integer sortOrder;
}
