package com.flash.gamification.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.UUID;

@Getter
@AllArgsConstructor
public class ClaimQuestResponse {

    private final UUID userQuestId;
    private final int xpAwarded;
    private final int currentXp;
    private final long totalLifetimeXp;
}
