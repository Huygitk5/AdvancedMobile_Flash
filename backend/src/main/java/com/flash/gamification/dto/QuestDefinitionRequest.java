package com.flash.gamification.dto;

import com.flash.gamification.entity.QuestFrequency;
import com.flash.gamification.entity.QuestType;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import javax.validation.constraints.Min;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Pattern;
import javax.validation.constraints.Size;

@Getter
@Setter
@NoArgsConstructor
public class QuestDefinitionRequest {

    /** Mã cố định, VD: DAILY_LEARN_20_WORDS. */
    @NotBlank
    @Size(max = 50)
    @Pattern(regexp = "[A-Z0-9_]+", message = "Chỉ gồm chữ in hoa, số và dấu _")
    private String code;

    @NotBlank
    @Size(max = 150)
    private String title;

    @Size(max = 500)
    private String description;

    @NotNull
    private QuestType questType;

    private QuestFrequency frequency;

    @NotNull
    @Min(1)
    private Integer targetValue;

    @NotNull
    @Min(0)
    private Integer xpReward;

    @NotBlank
    @Size(max = 50)
    private String iconName;

    private Boolean isActive;

    private Integer sortOrder;
}
