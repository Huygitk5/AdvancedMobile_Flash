package com.flash.gamification.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.util.List;
import java.util.UUID;

/** DATA_ARCHITECTURE.md §6.10. rank theo RANK(): đồng điểm thì đồng hạng. */
@Getter
@AllArgsConstructor
public class LeaderboardResponse {

    private final List<Entry> items;

    /** Hạng của user hiện tại (luôn tính mới, không qua cache). */
    private final Me me;

    @Getter
    @Builder
    public static class Entry {
        private final int rank;
        private final UUID userId;
        private final String fullName;
        private final String avatarUrl;
        private final List<Long> equippedBorderColors;
        private final long score;
    }

    @Getter
    @AllArgsConstructor
    public static class Me {
        private final Integer rank;
        private final long score;
    }
}
