package com.flash.home.service;

import com.flash.common.enums.ProgressStatus;
import com.flash.common.util.Zones;
import com.flash.content.entity.GrammarLesson;
import com.flash.content.entity.Topic;
import com.flash.content.repository.GrammarExampleRepository;
import com.flash.content.repository.GrammarLessonRepository;
import com.flash.content.repository.TopicRepository;
import com.flash.gamification.entity.UserQuest;
import com.flash.gamification.repository.QuestDefinitionRepository;
import com.flash.gamification.repository.UserQuestRepository;
import com.flash.home.dto.HomeSummaryResponse;
import com.flash.home.dto.LessonResponse;
import com.flash.home.dto.QuestResponse;
import com.flash.progress.entity.UserGrammarProgress;
import com.flash.progress.entity.UserTopicProgress;
import com.flash.progress.repository.UserGrammarProgressRepository;
import com.flash.progress.repository.UserTopicProgressRepository;
import com.flash.progress.service.LessonService;
import com.flash.user.entity.User;
import com.flash.user.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class HomeService {

    private static final int RECOMMENDED_LIMIT = 3;

    private final UserService userService;
    private final LessonService lessonService;
    private final TopicRepository topicRepository;
    private final GrammarLessonRepository grammarLessonRepository;
    private final GrammarExampleRepository exampleRepository;
    private final UserTopicProgressRepository topicProgressRepository;
    private final UserGrammarProgressRepository grammarProgressRepository;
    private final UserQuestRepository userQuestRepository;
    private final QuestDefinitionRepository questDefinitionRepository;

    @Transactional(readOnly = true)
    public HomeSummaryResponse summary(UUID userId) {
        User user = userService.getActiveUser(userId);
        LocalDate today = Zones.today(user);

        return HomeSummaryResponse.builder()
                .fullName(user.getFullName())
                .streakDays(user.getStreakDays())
                .currentXp(user.getCurrentXp())
                .targetXp(user.getTargetXp())
                .todayLessons(lessonService.todayLessons(user))
                .continueLesson(continueLesson(userId).orElse(null))
                .recommended(recommended(user))
                .todayChallenge(todayChallenge(userId, today).orElse(null))
                .build();
    }

    /** Bài IN_PROGRESS học gần nhất, so giữa topic và grammar. */
    private Optional<LessonResponse> continueLesson(UUID userId) {
        Optional<UserTopicProgress> topicProgress = topicProgressRepository
                .findFirstByUserIdAndStatusOrderByLastStudiedAtDesc(userId, ProgressStatus.IN_PROGRESS);
        Optional<UserGrammarProgress> grammarProgress = grammarProgressRepository
                .findFirstByUserIdAndStatusOrderByLastStudiedAtDesc(userId, ProgressStatus.IN_PROGRESS);

        Instant topicTime = topicProgress.map(UserTopicProgress::getLastStudiedAt).orElse(Instant.MIN);
        Instant grammarTime = grammarProgress.map(UserGrammarProgress::getLastStudiedAt).orElse(Instant.MIN);
        if (topicProgress.isPresent() && (grammarProgress.isEmpty() || !topicTime.isBefore(grammarTime))) {
            UserTopicProgress p = topicProgress.get();
            return topicRepository.findByIdAndDeletedAtIsNull(p.getTopicId())
                    .filter(Topic::getIsPublished)
                    .map(t -> LessonResponse.of(t, p));
        }
        return grammarProgress.flatMap(p -> grammarLessonRepository.findByIdAndDeletedAtIsNull(p.getGrammarLessonId())
                .filter(GrammarLesson::getIsPublished)
                .map(g -> LessonResponse.of(g, p, exampleCount(g.getId()))));
    }

    /**
     * Bài chưa học, ưu tiên đúng trình độ của user rồi theo thứ tự sắp xếp; xen kẽ từ vựng và ngữ pháp.
     * Lượng nội dung nhỏ (vài chục bài) nên lọc trong bộ nhớ.
     */
    private List<LessonResponse> recommended(User user) {
        Set<UUID> startedTopics = topicProgressRepository.findByUserId(user.getId()).stream()
                .filter(p -> p.getStatus() != ProgressStatus.NOT_STARTED)
                .map(UserTopicProgress::getTopicId)
                .collect(Collectors.toSet());
        Set<UUID> startedGrammar = grammarProgressRepository.findByUserId(user.getId()).stream()
                .filter(p -> p.getStatus() != ProgressStatus.NOT_STARTED)
                .map(UserGrammarProgress::getGrammarLessonId)
                .collect(Collectors.toSet());

        List<Topic> topics = topicRepository.findByIsPublishedTrueAndDeletedAtIsNullOrderBySortOrder().stream()
                .filter(t -> !startedTopics.contains(t.getId()))
                .sorted(Comparator.comparing((Topic t) -> t.getLevel() != user.getLevel())
                        .thenComparing(Topic::getSortOrder))
                .collect(Collectors.toList());
        List<GrammarLesson> lessons = grammarLessonRepository.findByIsPublishedTrueAndDeletedAtIsNullOrderBySortOrder().stream()
                .filter(g -> !startedGrammar.contains(g.getId()))
                .sorted(Comparator.comparing((GrammarLesson g) -> g.getLevel() != user.getLevel())
                        .thenComparing(GrammarLesson::getSortOrder))
                .collect(Collectors.toList());

        List<LessonResponse> result = new ArrayList<>();
        for (int i = 0; result.size() < RECOMMENDED_LIMIT && (i < topics.size() || i < lessons.size()); i++) {
            if (i < topics.size()) {
                result.add(LessonResponse.of(topics.get(i), null));
            }
            if (i < lessons.size() && result.size() < RECOMMENDED_LIMIT) {
                GrammarLesson g = lessons.get(i);
                result.add(LessonResponse.of(g, null, exampleCount(g.getId())));
            }
        }
        return result;
    }

    /** Nhiệm vụ hôm nay chưa nhận thưởng đầu tiên; nếu đã nhận hết thì lấy cái đầu tiên. */
    private Optional<QuestResponse> todayChallenge(UUID userId, LocalDate today) {
        List<UserQuest> quests = userQuestRepository.findByUserIdAndPeriodStartOrderByCreatedAt(userId, today);
        if (quests.isEmpty()) {
            return Optional.empty();
        }
        UserQuest chosen = quests.stream().filter(q -> !q.getIsClaimed()).findFirst().orElse(quests.get(0));
        return questDefinitionRepository.findById(chosen.getQuestDefinitionId())
                .map(definition -> QuestResponse.of(chosen, definition));
    }

    private int exampleCount(UUID grammarLessonId) {
        return exampleRepository.findByGrammarLessonIdAndDeletedAtIsNullOrderBySortOrder(grammarLessonId).size();
    }
}
