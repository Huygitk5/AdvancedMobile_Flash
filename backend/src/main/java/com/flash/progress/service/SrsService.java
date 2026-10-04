package com.flash.progress.service;

import com.flash.common.BusinessException;
import com.flash.common.ErrorCode;
import com.flash.common.util.Zones;
import com.flash.content.dto.FlashcardResponse;
import com.flash.content.entity.Flashcard;
import com.flash.content.repository.FlashcardRepository;
import com.flash.gamification.entity.QuestType;
import com.flash.gamification.entity.XpSourceType;
import com.flash.gamification.service.QuestService;
import com.flash.gamification.service.XpRules;
import com.flash.gamification.service.XpService;
import com.flash.progress.dto.ReviewRequest;
import com.flash.progress.dto.ReviewResponse;
import com.flash.progress.dto.SrsProgressResponse;
import com.flash.progress.entity.FlashcardReviewLog;
import com.flash.progress.entity.SrsRating;
import com.flash.progress.entity.UserFlashcardProgress;
import com.flash.progress.repository.FlashcardReviewLogRepository;
import com.flash.progress.repository.UserFlashcardProgressRepository;
import com.flash.user.dto.UserSnapshot;
import com.flash.user.entity.User;
import com.flash.user.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.Instant;
import java.time.LocalDate;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * Lặp lại ngắt quãng kiểu Leitner (DATA_ARCHITECTURE.md §5.2, §5.3c).
 * flashcard_review_logs là nguồn sự thật; user_flashcard_progress chỉ là kết quả phát lại log,
 * nên log của nhiều thiết bị (kể cả đến muộn) luôn hợp nhất đúng theo thứ tự thời gian.
 */
@Service
@RequiredArgsConstructor
public class SrsService {

    static final int MAX_BOX = 5;
    static final int LEARNED_BOX = 3;
    static final int AGAIN_BOX_DROP = 2;
    static final Duration AGAIN_DELAY = Duration.ofMinutes(10);
    /** Khoảng ôn lại theo box 0..5: ngay, 1, 3, 7, 14, 30 ngày. */
    static final Duration[] INTERVALS = {
            Duration.ZERO, Duration.ofDays(1), Duration.ofDays(3),
            Duration.ofDays(7), Duration.ofDays(14), Duration.ofDays(30)
    };

    private static final Comparator<FlashcardReviewLog> CHRONOLOGICAL =
            Comparator.comparing(FlashcardReviewLog::getReviewedAt).thenComparing(FlashcardReviewLog::getId);

    private final UserService userService;
    private final FlashcardRepository flashcardRepository;
    private final FlashcardReviewLogRepository logRepository;
    private final UserFlashcardProgressRepository progressRepository;
    private final ContentProgressService contentProgressService;
    private final ActivityRecorder activityRecorder;
    private final XpService xpService;
    private final QuestService questService;

    @Transactional
    public ReviewResponse review(UUID userId, ReviewRequest request) {
        User user = userService.lockActiveUser(userId);

        Optional<FlashcardReviewLog> existing = logRepository.findById(request.getLogId());
        if (existing.isPresent()) {
            return duplicate(user, existing.get());
        }

        Flashcard card = flashcardRepository.findByIdAndDeletedAtIsNull(request.getFlashcardId())
                .orElseThrow(() -> new BusinessException(ErrorCode.NOT_FOUND, "Không tìm thấy từ vựng"));
        Instant reviewedAt = request.getReviewedAt();
        Instant now = Instant.now();

        Optional<UserFlashcardProgress> found = progressRepository.findByUserIdAndFlashcardId(userId, card.getId());
        boolean firstStudy = found.isEmpty();
        UserFlashcardProgress progress = found.orElseGet(() -> newProgress(userId, card.getId()));
        boolean wasLearned = progress.getIsLearned();

        List<FlashcardReviewLog> history = logRepository
                .findByUserIdAndFlashcardIdOrderByReviewedAtAscIdAsc(userId, card.getId());
        boolean suspicious = isSuspicious(userId, history, reviewedAt);

        FlashcardReviewLog log = new FlashcardReviewLog();
        log.setId(request.getLogId());
        log.setUserId(userId);
        log.setFlashcardId(card.getId());
        log.setRating(request.getRating());
        log.setResponseTimeMs(request.getResponseTimeMs());
        log.setReviewedAt(reviewedAt);
        history.add(log);
        history.sort(CHRONOLOGICAL);
        replay(progress, history);
        logRepository.save(log);
        progressRepository.save(progress);

        boolean nowLearned = progress.getIsLearned();
        boolean becameLearned = !wasLearned && nowLearned;
        if (wasLearned != nowLearned) {
            user.setTotalWordsLearned((int) progressRepository.countByUserIdAndIsLearnedTrue(userId));
        }
        contentProgressService.refreshTopic(userId, card.getTopicId(), earliest(reviewedAt, now));

        int xpAwarded = 0;
        if (XpRules.isPlausible(reviewedAt, now)) {
            LocalDate day = Zones.localDate(user, reviewedAt);
            activityRecorder.record(user, reviewedAt, stat -> {
                stat.setCardsReviewed(stat.getCardsReviewed() + 1);
                if (becameLearned) {
                    stat.setWordsLearned(stat.getWordsLearned() + 1);
                }
            });
            if (!suspicious) {
                xpAwarded += awardXp(user, card.getId(), request.getRating(), becameLearned, day);
            }
            questService.onEvent(user, QuestType.REVIEW_CARDS, 1, reviewedAt);
            if (firstStudy) {
                questService.onEvent(user, QuestType.LEARN_WORDS, 1, reviewedAt);
            }
        }

        progressRepository.flush();
        return new ReviewResponse(SrsProgressResponse.from(progress), xpAwarded, false, UserSnapshot.from(user));
    }

    /** Thẻ đã đến hạn ôn, hạn sớm nhất trước. */
    @Transactional(readOnly = true)
    public List<FlashcardResponse> due(UUID userId, UUID topicId, int limit) {
        return flashcardRepository.findDueWithUserState(userId, topicId, Instant.now(), PageRequest.of(0, limit))
                .stream()
                .map(FlashcardResponse::fromRow)
                .collect(Collectors.toList());
    }

    /**
     * Tính lại trạng thái từ toàn bộ log theo thứ tự thời gian, đồng thời ghi lại box_before/box_after
     * của từng log (log đến muộn chen vào giữa làm các log sau nó đổi box).
     * - Know:  box = min(box + 1, 5), due = reviewedAt + INTERVALS[box]
     * - Again: box = max(box - 2, 0), due = reviewedAt + 10 phút
     */
    static void replay(UserFlashcardProgress progress, List<FlashcardReviewLog> logs) {
        int box = 0;
        int again = 0;
        int know = 0;
        Instant dueAt = null;
        FlashcardReviewLog last = null;
        for (FlashcardReviewLog log : logs) {
            log.setBoxBefore(box);
            if (log.getRating() == SrsRating.KNOW) {
                box = Math.min(box + 1, MAX_BOX);
                know++;
                dueAt = log.getReviewedAt().plus(INTERVALS[box]);
            } else {
                box = Math.max(box - AGAIN_BOX_DROP, 0);
                again++;
                dueAt = log.getReviewedAt().plus(AGAIN_DELAY);
            }
            log.setBoxAfter(box);
            last = log;
        }
        progress.setBox(box);
        progress.setRepetitions(logs.size());
        progress.setAgainCount(again);
        progress.setKnowCount(know);
        progress.setLastRating(last != null ? last.getRating() : null);
        progress.setLastReviewedAt(last != null ? last.getReviewedAt() : null);
        progress.setDueAt(dueAt);
        progress.setIsLearned(box >= LEARNED_BOX);
    }

    /**
     * +2 cho Know lần đầu trong ngày với thẻ đó (source_id chứa ngày nên gửi lại hay bấm lại đều trùng),
     * tối đa 300 XP/ngày; +5 khi thẻ lần đầu được thuộc.
     */
    private int awardXp(User user, UUID flashcardId, SrsRating rating, boolean becameLearned, LocalDate day) {
        int xp = 0;
        if (rating == SrsRating.KNOW) {
            xp += xpService.awardCapped(user, XpRules.KNOW_XP, XpSourceType.FLASHCARD_REVIEW,
                    "know:" + flashcardId + ":" + day, day, "know:%:" + day, XpRules.KNOW_DAILY_CAP);
        }
        if (becameLearned) {
            xp += xpService.award(user, XpRules.LEARNED_XP, XpSourceType.FLASHCARD_REVIEW,
                    "learned:" + flashcardId, day);
        }
        return xp;
    }

    /** Hai review cùng thẻ cách nhau dưới 1 giây, hoặc hơn 60 review/phút: lưu nhưng không cộng XP. */
    private boolean isSuspicious(UUID userId, List<FlashcardReviewLog> history, Instant reviewedAt) {
        boolean tooClose = history.stream()
                .anyMatch(l -> Duration.between(l.getReviewedAt(), reviewedAt).abs().compareTo(XpRules.MIN_REVIEW_GAP) < 0);
        return tooClose || logRepository.countByUserIdAndReviewedAtBetween(userId,
                reviewedAt.minusSeconds(60), reviewedAt) >= XpRules.MAX_REVIEWS_PER_MINUTE;
    }

    private ReviewResponse duplicate(User user, FlashcardReviewLog log) {
        if (!log.getUserId().equals(user.getId())) {
            throw new BusinessException(ErrorCode.CONFLICT, "logId đã được sử dụng");
        }
        UserFlashcardProgress progress = progressRepository
                .findByUserIdAndFlashcardId(user.getId(), log.getFlashcardId())
                .orElseGet(() -> newProgress(user.getId(), log.getFlashcardId()));
        return new ReviewResponse(SrsProgressResponse.from(progress), 0, true, UserSnapshot.from(user));
    }

    private static UserFlashcardProgress newProgress(UUID userId, UUID flashcardId) {
        UserFlashcardProgress progress = new UserFlashcardProgress();
        progress.setUserId(userId);
        progress.setFlashcardId(flashcardId);
        return progress;
    }

    private static Instant earliest(Instant a, Instant b) {
        return a.isBefore(b) ? a : b;
    }
}
