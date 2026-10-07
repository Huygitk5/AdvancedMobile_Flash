package com.flash.progress.service;

import com.flash.common.BusinessException;
import com.flash.common.ErrorCode;
import com.flash.common.util.Zones;
import com.flash.content.service.ContentLookup;
import com.flash.gamification.entity.QuestType;
import com.flash.gamification.entity.XpSourceType;
import com.flash.gamification.service.QuestService;
import com.flash.gamification.service.XpRules;
import com.flash.gamification.service.XpService;
import com.flash.home.dto.HomeSummaryResponse;
import com.flash.progress.dto.LessonCompleteRequest;
import com.flash.progress.dto.LessonCompleteResponse;
import com.flash.progress.entity.LessonCompletion;
import com.flash.progress.entity.LessonType;
import com.flash.progress.repository.LessonCompletionRepository;
import com.flash.stats.entity.DailyStatistic;
import com.flash.user.dto.UserSnapshot;
import com.flash.user.entity.User;
import com.flash.user.entity.UserSettings;
import com.flash.user.repository.UserSettingsRepository;
import com.flash.user.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.util.Optional;
import java.util.UUID;

/** POST /v1/lessons/complete: một bài trong mục tiêu "3/5 bài" hôm nay. */
@Service
@RequiredArgsConstructor
public class LessonService {

    private static final int DEFAULT_DAILY_GOAL = 5;

    private final UserService userService;
    private final UserSettingsRepository settingsRepository;
    private final LessonCompletionRepository repository;
    private final ContentLookup contentLookup;
    private final ContentProgressService contentProgressService;
    private final ActivityRecorder activityRecorder;
    private final XpService xpService;
    private final QuestService questService;

    @Transactional
    public LessonCompleteResponse complete(UUID userId, LessonCompleteRequest request) {
        User user = userService.lockActiveUser(userId);

        Optional<LessonCompletion> existing = repository.findById(request.getId());
        if (existing.isPresent()) {
            if (!existing.get().getUserId().equals(userId)) {
                throw new BusinessException(ErrorCode.CONFLICT, "id bài học đã được sử dụng");
            }
            return new LessonCompleteResponse(0, true, todayLessons(user), UserSnapshot.from(user));
        }
        validateTarget(request);

        Instant now = Instant.now();
        Instant completedAt = request.getCompletedAt();
        int duration = request.getDurationSeconds() != null ? request.getDurationSeconds() : 0;

        // "Bài học hoàn thành" đếm số bài khác nhau: học lại một bài đã xong thì chỉ ghi nhận lượt học, không cộng thêm
        boolean firstCompletionOfLesson = request.getLessonType() == LessonType.TOPIC
                ? !repository.existsByUserIdAndTopicId(userId, request.getTopicId())
                : !repository.existsByUserIdAndGrammarLessonId(userId, request.getGrammarLessonId());

        LessonCompletion completion = new LessonCompletion();
        completion.setId(request.getId());
        completion.setUserId(userId);
        completion.setLessonType(request.getLessonType());
        completion.setTopicId(request.getTopicId());
        completion.setGrammarLessonId(request.getGrammarLessonId());
        completion.setCardsReviewed(request.getCardsReviewed() != null ? request.getCardsReviewed() : 0);
        completion.setDurationSeconds(duration);
        completion.setCompletedAt(completedAt);
        repository.save(completion);
        if (firstCompletionOfLesson) {
            user.setCompletedLessons(user.getCompletedLessons() + 1);
        }

        Instant studiedAt = completedAt.isBefore(now) ? completedAt : now;
        if (request.getLessonType() == LessonType.TOPIC) {
            contentProgressService.refreshTopic(userId, request.getTopicId(), studiedAt);
        } else {
            contentProgressService.grammarLessonCompleted(userId, request.getGrammarLessonId(), studiedAt);
        }

        int xpAwarded = 0;
        if (XpRules.isPlausible(completedAt, now)) {
            LocalDate day = Zones.localDate(user, completedAt);
            DailyStatistic stat = activityRecorder.record(user, completedAt, s -> {
                s.setLessonsCompleted(s.getLessonsCompleted() + 1);
                s.setStudySeconds(s.getStudySeconds() + duration);
            });
            if (stat.getLessonsCompleted() <= XpRules.LESSON_DAILY_XP_LIMIT) {
                // source_id theo (bài, ngày): học lại cùng một bài trong ngày không được cộng XP lần nữa
                xpAwarded = xpService.award(user, XpRules.LESSON_XP, XpSourceType.LESSON_COMPLETE,
                        "lesson:" + lessonTargetId(request) + ":" + day, day);
            }
            questService.onEvent(user, QuestType.COMPLETE_LESSON, 1, completedAt);
            questService.onEvent(user, QuestType.STUDY_MINUTES, duration / 60, completedAt);
        }
        return new LessonCompleteResponse(xpAwarded, false, todayLessons(user), UserSnapshot.from(user));
    }

    /** "3/5 bài" hôm nay theo timezone của user (dùng chung với Home). */
    @Transactional(readOnly = true)
    public HomeSummaryResponse.TodayLessons todayLessons(User user) {
        LocalDate today = Zones.today(user);
        Instant from = Zones.startOfDay(user, today);
        Instant to = Zones.startOfDay(user, today.plusDays(1));
        long done = repository.countDistinctTopics(user.getId(), from, to)
                + repository.countDistinctGrammarLessons(user.getId(), from, to);
        int goal = settingsRepository.findById(user.getId())
                .map(UserSettings::getDailyGoalLessons)
                .orElse(DEFAULT_DAILY_GOAL);
        return new HomeSummaryResponse.TodayLessons((int) done, goal);
    }

    private static UUID lessonTargetId(LessonCompleteRequest request) {
        return request.getLessonType() == LessonType.TOPIC ? request.getTopicId() : request.getGrammarLessonId();
    }

    /** MySQL không CHECK được "đúng 1 trong 2 FK", nên kiểm ở đây. */
    private void validateTarget(LessonCompleteRequest request) {
        if (request.getLessonType() == LessonType.TOPIC) {
            if (request.getTopicId() == null || request.getGrammarLessonId() != null) {
                throw new BusinessException(ErrorCode.VALIDATION_ERROR, "Bài TOPIC cần topicId và không có grammarLessonId");
            }
            contentLookup.topic(request.getTopicId(), false);
        } else {
            if (request.getGrammarLessonId() == null || request.getTopicId() != null) {
                throw new BusinessException(ErrorCode.VALIDATION_ERROR, "Bài GRAMMAR cần grammarLessonId và không có topicId");
            }
            contentLookup.grammar(request.getGrammarLessonId(), false);
        }
    }
}
