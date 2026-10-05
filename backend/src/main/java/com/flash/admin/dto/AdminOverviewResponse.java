package com.flash.admin.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

/** Số liệu màn Tổng quan của admin. students chỉ đếm role USER, quản trị viên đếm riêng ở admins. */
@Getter
@Builder
public class AdminOverviewResponse {

    private final long students;
    private final long activeStudents;
    private final long newStudentsLast7Days;
    private final long admins;
    private final long topics;
    private final long flashcards;
    private final long grammarLessons;
    private final long quizzes;
    private final long rewardItems;
    private final long questDefinitions;
    private final List<RecentStudent> recentStudents;

    @Getter
    @AllArgsConstructor
    public static class RecentStudent {
        private final UUID id;
        private final String fullName;
        private final String email;
        private final Instant createdAt;
    }
}
