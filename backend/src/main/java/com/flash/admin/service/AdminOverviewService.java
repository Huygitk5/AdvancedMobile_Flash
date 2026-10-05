package com.flash.admin.service;

import com.flash.admin.dto.AdminOverviewResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Timestamp;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AdminOverviewService {

    private static final int RECENT_LIMIT = 5;

    private final JdbcTemplate jdbc;

    @Transactional(readOnly = true)
    public AdminOverviewResponse overview() {
        Timestamp weekAgo = Timestamp.from(Instant.now().minus(7, ChronoUnit.DAYS));
        List<AdminOverviewResponse.RecentStudent> recent = jdbc.query(
                "SELECT id, full_name, email, created_at FROM users WHERE role = 'USER' AND deleted_at IS NULL "
                        + "ORDER BY created_at DESC LIMIT ?",
                (rs, i) -> new AdminOverviewResponse.RecentStudent(UUID.fromString(rs.getString("id")),
                        rs.getString("full_name"), rs.getString("email"),
                        rs.getTimestamp("created_at").toInstant()),
                RECENT_LIMIT).stream().collect(Collectors.toList());

        return AdminOverviewResponse.builder()
                .students(count("SELECT COUNT(*) FROM users WHERE role = 'USER' AND deleted_at IS NULL"))
                .activeStudents(count("SELECT COUNT(*) FROM users WHERE role = 'USER' AND deleted_at IS NULL "
                        + "AND status = 'ACTIVE'"))
                .newStudentsLast7Days(jdbc.queryForObject("SELECT COUNT(*) FROM users WHERE role = 'USER' "
                        + "AND deleted_at IS NULL AND created_at >= ?", Long.class, weekAgo))
                .admins(count("SELECT COUNT(*) FROM users WHERE role = 'ADMIN' AND deleted_at IS NULL"))
                .topics(count("SELECT COUNT(*) FROM topics WHERE deleted_at IS NULL"))
                .flashcards(count("SELECT COUNT(*) FROM flashcards WHERE deleted_at IS NULL"))
                .grammarLessons(count("SELECT COUNT(*) FROM grammar_lessons WHERE deleted_at IS NULL"))
                .quizzes(count("SELECT COUNT(*) FROM quizzes WHERE deleted_at IS NULL"))
                .rewardItems(count("SELECT COUNT(*) FROM reward_items WHERE is_active = TRUE"))
                .questDefinitions(count("SELECT COUNT(*) FROM quest_definitions WHERE is_active = TRUE"))
                .recentStudents(recent)
                .build();
    }

    private long count(String sql) {
        Long value = jdbc.queryForObject(sql, Long.class);
        return value == null ? 0 : value;
    }
}
