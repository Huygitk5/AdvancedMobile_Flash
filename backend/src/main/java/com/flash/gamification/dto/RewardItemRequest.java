package com.flash.gamification.dto;

import com.flash.gamification.entity.RankBoard;
import com.flash.gamification.entity.RewardItemType;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import javax.validation.constraints.Max;
import javax.validation.constraints.Min;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Pattern;
import javax.validation.constraints.Size;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
public class RewardItemRequest {

    @NotBlank
    @Size(max = 50)
    @Pattern(regexp = "[A-Z0-9_]+", message = "Chỉ gồm chữ in hoa, số và dấu _")
    private String code;

    @NotBlank
    @Size(max = 100)
    private String name;

    @Size(max = 255)
    private String description;

    @NotNull
    private RewardItemType itemType;

    @Min(0)
    private Integer xpCost;

    /** Bắt buộc với BORDER: 2-5 màu ARGB, VD [4293059298, 4291548641]. */
    @Size(min = 2, max = 5)
    private List<@NotNull @Min(0) @Max(4_294_967_295L) Long> borderColors;

    @Size(max = 500)
    private String imageUrl;

    /** 0 = không yêu cầu hạng. */
    @Min(0)
    private Integer requiredRank;

    private RankBoard rankBoard;

    private Boolean isActive;

    private Integer sortOrder;
}
