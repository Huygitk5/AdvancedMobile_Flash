package com.flash.gamification.service;

import com.flash.gamification.dto.LeaderboardResponse;
import com.flash.gamification.entity.RankBoard;
import com.flash.gamification.repository.UserInventoryRepository;
import com.flash.user.entity.User;
import com.flash.user.entity.UserStatus;
import com.flash.user.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

/**
 * Bảng xếp hạng đọc từ view v_leaderboard_xp / v_leaderboard_streak.
 * Top N được cache 60 giây trong bộ nhớ (một instance); hạng của chính user luôn tính mới bằng COUNT.
 */
@Service
@RequiredArgsConstructor
public class LeaderboardService {

    static final Duration CACHE_TTL = Duration.ofSeconds(60);

    private final JdbcTemplate jdbcTemplate;
    private final UserService userService;
    private final UserInventoryRepository inventoryRepository;
    private final RewardItemService rewardItemService;
    private final Map<String, CachedTop> cache = new ConcurrentHashMap<>();

    @Transactional(readOnly = true)
    public LeaderboardResponse leaderboard(RankBoard board, UUID userId, int limit) {
        User me = userService.getActiveUser(userId);
        return new LeaderboardResponse(top(board, limit), new LeaderboardResponse.Me(rankOf(board, me), scoreOf(board, me)));
    }

    /** Hạng theo RANK() (số người điểm cao hơn + 1); null nếu user không xuất hiện trên bảng. */
    public Integer rankOf(RankBoard board, User user) {
        if (user.getStatus() != UserStatus.ACTIVE || user.getDeletedAt() != null) {
            return null;
        }
        Long higher = jdbcTemplate.queryForObject("SELECT COUNT(*) FROM users WHERE status = 'ACTIVE' "
                + "AND deleted_at IS NULL AND " + scoreColumn(board) + " > ?", Long.class, scoreOf(board, user));
        return higher == null ? null : higher.intValue() + 1;
    }

    private List<LeaderboardResponse.Entry> top(RankBoard board, int limit) {
        String key = board + ":" + limit;
        CachedTop cached = cache.get(key);
        Instant now = Instant.now();
        if (cached != null && cached.expiresAt.isAfter(now)) {
            return cached.entries;
        }
        List<LeaderboardResponse.Entry> entries = loadTop(board, limit);
        cache.put(key, new CachedTop(entries, now.plus(CACHE_TTL)));
        return entries;
    }

    private List<LeaderboardResponse.Entry> loadTop(RankBoard board, int limit) {
        String view = board == RankBoard.XP ? "v_leaderboard_xp" : "v_leaderboard_streak";
        List<Map<String, Object>> rows = jdbcTemplate.queryForList("SELECT user_id, full_name, avatar_url, score, rank_no "
                + "FROM " + view + " ORDER BY rank_no, full_name LIMIT ?", limit);
        if (rows.isEmpty()) {
            return List.of();
        }
        List<UUID> userIds = rows.stream().map(r -> UUID.fromString((String) r.get("user_id"))).collect(Collectors.toList());
        Map<UUID, List<Long>> borders = inventoryRepository.findEquippedBorders(userIds).stream()
                .collect(Collectors.toMap(r -> (UUID) r[0], r -> rewardItemService.readColors((String) r[1]), (a, b) -> a));

        return rows.stream().map(r -> {
            UUID id = UUID.fromString((String) r.get("user_id"));
            return LeaderboardResponse.Entry.builder()
                    .rank(((Number) r.get("rank_no")).intValue())
                    .userId(id)
                    .fullName((String) r.get("full_name"))
                    .avatarUrl((String) r.get("avatar_url"))
                    .equippedBorderColors(borders.get(id))
                    .score(((Number) r.get("score")).longValue())
                    .build();
        }).collect(Collectors.toList());
    }

    private static long scoreOf(RankBoard board, User user) {
        return board == RankBoard.XP ? user.getTotalLifetimeXp() : user.getLongestStreak();
    }

    private static String scoreColumn(RankBoard board) {
        return board == RankBoard.XP ? "total_lifetime_xp" : "longest_streak";
    }

    private static final class CachedTop {
        private final List<LeaderboardResponse.Entry> entries;
        private final Instant expiresAt;

        private CachedTop(List<LeaderboardResponse.Entry> entries, Instant expiresAt) {
            this.entries = entries;
            this.expiresAt = expiresAt;
        }
    }
}
