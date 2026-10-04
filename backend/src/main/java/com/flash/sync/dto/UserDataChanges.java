package com.flash.sync.dto;

import com.flash.common.enums.ProgressStatus;
import com.flash.gamification.dto.InventoryResponse;
import com.flash.gamification.entity.UserQuest;
import com.flash.progress.dto.NoteResponse;
import com.flash.progress.dto.SrsProgressResponse;
import com.flash.progress.entity.UserBookmark;
import com.flash.progress.entity.UserGrammarProgress;
import com.flash.progress.entity.UserTopicProgress;
import com.flash.stats.dto.DailyStatisticResponse;
import com.flash.user.dto.UserResponse;
import com.flash.user.dto.UserSettingsResponse;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

/**
 * Delta dữ liệu của user cho GET /v1/sync/pull. Mỗi danh sách khớp một bảng SQLite phía client
 * (docs/sql/client_sqlite.sql); dòng có deletedAt là tombstone. Client bỏ qua dòng local đang is_dirty = 1.
 */
@Getter
@Builder
public class UserDataChanges {

    private final List<SrsProgressResponse> userFlashcardProgress;
    private final List<NoteResponse> userFlashcardNotes;
    private final List<BookmarkRow> userBookmarks;
    private final List<TopicProgressRow> userTopicProgress;
    private final List<GrammarProgressRow> userGrammarProgress;
    private final List<QuestRow> userQuests;
    private final List<InventoryResponse> userInventories;
    private final List<DailyStatisticResponse> dailyStatistics;

    /** Luôn có: XP / streak / tổng số là server-authoritative, client ghi đè bản local. */
    private final UserResponse user;

    /** null nếu cài đặt không đổi kể từ since. */
    private final UserSettingsResponse settings;

    @Getter
    @Builder
    public static class BookmarkRow {
        private final UUID flashcardId;
        private final Integer version;
        private final Instant clientUpdatedAt;
        private final Instant createdAt;
        private final Instant deletedAt;

        public static BookmarkRow from(UserBookmark b) {
            return BookmarkRow.builder()
                    .flashcardId(b.getFlashcardId())
                    .version(b.getVersion())
                    .clientUpdatedAt(b.getClientUpdatedAt())
                    .createdAt(b.getCreatedAt())
                    .deletedAt(b.getDeletedAt())
                    .build();
        }
    }

    @Getter
    @Builder
    public static class TopicProgressRow {
        private final UUID topicId;
        private final Integer learnedWords;
        private final ProgressStatus status;
        private final Instant lastStudiedAt;
        private final Instant completedAt;
        private final Integer version;

        public static TopicProgressRow from(UserTopicProgress p) {
            return TopicProgressRow.builder()
                    .topicId(p.getTopicId())
                    .learnedWords(p.getLearnedWords())
                    .status(p.getStatus())
                    .lastStudiedAt(p.getLastStudiedAt())
                    .completedAt(p.getCompletedAt())
                    .version(p.getVersion())
                    .build();
        }
    }

    @Getter
    @Builder
    public static class GrammarProgressRow {
        private final UUID grammarLessonId;
        private final Double progress;
        private final ProgressStatus status;
        private final Integer bestScorePercent;
        private final Instant lastStudiedAt;
        private final Instant completedAt;
        private final Integer version;

        public static GrammarProgressRow from(UserGrammarProgress p) {
            return GrammarProgressRow.builder()
                    .grammarLessonId(p.getGrammarLessonId())
                    .progress(p.getProgress().doubleValue())
                    .status(p.getStatus())
                    .bestScorePercent(p.getBestScorePercent())
                    .lastStudiedAt(p.getLastStudiedAt())
                    .completedAt(p.getCompletedAt())
                    .version(p.getVersion())
                    .build();
        }
    }

    @Getter
    @Builder
    public static class QuestRow {
        private final UUID id;
        private final UUID questDefinitionId;
        private final LocalDate periodStart;
        private final Integer currentValue;
        private final Integer targetValue;
        private final Integer xpReward;
        private final Instant completedAt;
        private final Boolean isClaimed;
        private final Instant claimedAt;
        private final Integer version;

        public static QuestRow from(UserQuest q) {
            return QuestRow.builder()
                    .id(q.getId())
                    .questDefinitionId(q.getQuestDefinitionId())
                    .periodStart(q.getPeriodStart())
                    .currentValue(q.getCurrentValue())
                    .targetValue(q.getTargetValue())
                    .xpReward(q.getXpReward())
                    .completedAt(q.getCompletedAt())
                    .isClaimed(q.getIsClaimed())
                    .claimedAt(q.getClaimedAt())
                    .version(q.getVersion())
                    .build();
        }
    }
}
