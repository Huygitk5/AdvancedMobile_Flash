package com.flash.gamification.dto;

import com.flash.gamification.entity.QuestDefinition;
import com.flash.gamification.entity.QuestFrequency;
import com.flash.gamification.entity.QuestType;
import lombok.Builder;
import lombok.Getter;

import java.util.UUID;

@Getter
@Builder
public class QuestDefinitionResponse {

    private final UUID id;
    private final String code;
    private final String title;
    private final String description;
    private final QuestType questType;
    private final QuestFrequency frequency;
    private final Integer targetValue;
    private final Integer xpReward;
    private final String iconName;
    private final Boolean isActive;
    private final Integer sortOrder;

    public static QuestDefinitionResponse from(QuestDefinition d) {
        return QuestDefinitionResponse.builder()
                .id(d.getId())
                .code(d.getCode())
                .title(d.getTitle())
                .description(d.getDescription())
                .questType(d.getQuestType())
                .frequency(d.getFrequency())
                .targetValue(d.getTargetValue())
                .xpReward(d.getXpReward())
                .iconName(d.getIconName())
                .isActive(d.getIsActive())
                .sortOrder(d.getSortOrder())
                .build();
    }
}
