package com.flash.gamification.dto;

import com.flash.home.dto.QuestResponse;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.List;

/** ChallengeScreen: số dư XP và nhiệm vụ của chu kỳ hiện tại (DATA_ARCHITECTURE.md §6.8). */
@Getter
@AllArgsConstructor
public class TodayQuestsResponse {

    private final int totalXp;
    private final List<QuestResponse> quests;
}
