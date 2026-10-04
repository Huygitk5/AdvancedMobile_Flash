package com.flash.home.dto;

import com.flash.gamification.entity.QuestDefinition;
import com.flash.gamification.entity.UserQuest;
import lombok.Builder;
import lombok.Getter;

import java.util.UUID;

/** Khớp model Quest bên Flutter (current / target / xp / isClaimed); icon gửi dạng tên. */
@Getter
@Builder
public class QuestResponse {

    /** id của lần giao (user_quests.id), dùng cho POST /v1/quests/claim/{id}. */
    private final UUID id;
    private final UUID questDefinitionId;
    private final String title;
    private final String iconName;
    private final Integer current;
    private final Integer target;
    private final Integer xp;
    private final Boolean isClaimed;

    public static QuestResponse of(UserQuest quest, QuestDefinition definition) {
        return QuestResponse.builder()
                .id(quest.getId())
                .questDefinitionId(definition.getId())
                .title(definition.getTitle())
                .iconName(definition.getIconName())
                .current(Math.min(quest.getCurrentValue(), quest.getTargetValue()))
                .target(quest.getTargetValue())
                .xp(quest.getXpReward())
                .isClaimed(quest.getIsClaimed())
                .build();
    }
}
