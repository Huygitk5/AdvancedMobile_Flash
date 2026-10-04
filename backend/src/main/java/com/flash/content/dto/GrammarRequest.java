package com.flash.content.dto;

import com.flash.common.enums.CefrLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import javax.validation.Valid;
import javax.validation.constraints.Max;
import javax.validation.constraints.Min;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Size;
import java.util.ArrayList;
import java.util.List;

/** Tạo / sửa chủ điểm ngữ pháp. examples thay toàn bộ danh sách cũ. */
@Getter
@Setter
@NoArgsConstructor
public class GrammarRequest {

    @NotBlank
    @Size(max = 150)
    private String title;

    @Size(max = 500)
    private String description;

    @NotBlank
    @Size(max = 255)
    private String structure;

    private String content;

    private String usageNotes;

    @NotBlank
    @Size(max = 50)
    private String iconName;

    private CefrLevel level;

    @Min(0)
    @Max(4_294_967_295L)
    private Long coverColor;

    @Min(1)
    @Max(600)
    private Integer estimatedMinutes;

    private Integer sortOrder;

    private Boolean isPublished;

    @Valid
    private List<Example> examples = new ArrayList<>();

    @Getter
    @Setter
    @NoArgsConstructor
    public static class Example {

        @NotBlank
        private String sentence;

        private String translation;

        @Size(max = 100)
        private String highlight;
    }
}
