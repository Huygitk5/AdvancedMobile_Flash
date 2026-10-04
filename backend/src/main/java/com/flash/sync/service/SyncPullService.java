package com.flash.sync.service;

import com.flash.gamification.dto.InventoryResponse;
import com.flash.gamification.entity.UserInventory;
import com.flash.gamification.entity.UserQuest;
import com.flash.progress.dto.NoteResponse;
import com.flash.progress.dto.SrsProgressResponse;
import com.flash.progress.entity.UserBookmark;
import com.flash.progress.entity.UserFlashcardNote;
import com.flash.progress.entity.UserFlashcardProgress;
import com.flash.progress.entity.UserGrammarProgress;
import com.flash.progress.entity.UserTopicProgress;
import com.flash.stats.dto.DailyStatisticResponse;
import com.flash.stats.entity.DailyStatistic;
import com.flash.sync.dto.SyncPullResponse;
import com.flash.sync.dto.UserDataChanges;
import com.flash.user.dto.UserResponse;
import com.flash.user.dto.UserSettingsResponse;
import com.flash.user.repository.UserSettingsRepository;
import com.flash.user.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * GET /v1/sync/pull: mọi dòng dữ liệu của user có updated_at &gt; since, kể cả tombstone (deleted_at).
 * Chạy trong 1 transaction chỉ đọc (REPEATABLE READ của InnoDB) nên các bảng nhất quán với nhau.
 */
@Service
@RequiredArgsConstructor
public class SyncPullService {

    private static final String BY_USER = "e.userId = :userId";

    private final DeltaReader deltaReader;
    private final UserService userService;
    private final UserSettingsRepository settingsRepository;

    @Transactional(readOnly = true)
    public SyncPullResponse<UserDataChanges> pull(UUID userId, Instant since, int limit) {
        DeltaWindow window = new DeltaWindow(since, limit, Instant.now());
        Map<String, Object> params = Map.of("userId", userId);

        UserDataChanges changes = UserDataChanges.builder()
                .userFlashcardProgress(read(window, UserFlashcardProgress.class, params,
                        UserFlashcardProgress::getUpdatedAt, SrsProgressResponse::from))
                .userFlashcardNotes(read(window, UserFlashcardNote.class, params,
                        UserFlashcardNote::getUpdatedAt, NoteResponse::from))
                .userBookmarks(read(window, UserBookmark.class, params,
                        UserBookmark::getUpdatedAt, UserDataChanges.BookmarkRow::from))
                .userTopicProgress(read(window, UserTopicProgress.class, params,
                        UserTopicProgress::getUpdatedAt, UserDataChanges.TopicProgressRow::from))
                .userGrammarProgress(read(window, UserGrammarProgress.class, params,
                        UserGrammarProgress::getUpdatedAt, UserDataChanges.GrammarProgressRow::from))
                .userQuests(read(window, UserQuest.class, params,
                        UserQuest::getUpdatedAt, UserDataChanges.QuestRow::from))
                .userInventories(read(window, UserInventory.class, params,
                        UserInventory::getUpdatedAt, inv -> InventoryResponse.of(inv, null)))
                .dailyStatistics(read(window, DailyStatistic.class, params,
                        DailyStatistic::getUpdatedAt, DailyStatisticResponse::from))
                .user(UserResponse.from(userService.getActiveUser(userId)))
                .settings(settingsRepository.findById(userId)
                        .filter(s -> s.getUpdatedAt().isAfter(since))
                        .map(UserSettingsResponse::from)
                        .orElse(null))
                .build();
        return new SyncPullResponse<>(window.cursor(), window.isHasMore(), changes);
    }

    private <T, R> List<R> read(DeltaWindow window, Class<T> type, Map<String, Object> params,
                                Function<T, Instant> updatedAt, Function<T, R> mapper) {
        return deltaReader.read(window, type, BY_USER, params, updatedAt).stream()
                .map(mapper)
                .collect(Collectors.toList());
    }
}
