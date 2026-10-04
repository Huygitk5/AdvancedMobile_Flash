package com.flash.content.dto;

import com.flash.common.enums.CefrLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import javax.validation.constraints.Max;
import javax.validation.constraints.Min;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Size;

/** Tạo / sửa topic (PUT thay toàn bộ). */
@Getter
@Setter
@NoArgsConstructor
public class TopicRequest {

    @NotBlank
    @Size(max = 150)
    private String title;

    @Size(max = 500)
    private String description;

    /** Emoji hoặc đường dẫn asset, VD: "✈️". */
    @NotBlank
    @Size(max = 255)
    private String iconPath;

    private CefrLevel level;

    /** ARGB 0xAARRGGBB. */
    @Min(0)
    @Max(4_294_967_295L)
    private Long coverColor;

    @Min(1)
    @Max(600)
    private Integer estimatedMinutes;

    private Integer sortOrder;

    private Boolean isPublished;
}
