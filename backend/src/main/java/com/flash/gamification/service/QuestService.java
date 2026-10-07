package com.flash.gamification.service;

import com.flash.common.BusinessException;
import com.flash.common.ErrorCode;
import com.flash.common.util.Zones;
import com.flash.gamification.dto.ClaimQuestResponse;
import com.flash.gamification.dto.TodayQuestsResponse;
import com.flash.gamification.entity.QuestDefinition;
import com.flash.gamification.entity.QuestFrequency;
import com.flash.gamification.entity.QuestType;
import com.flash.gamification.entity.UserQuest;
import com.flash.gamification.entity.XpSourceType;
import com.flash.gamification.repository.QuestDefinitionRepository;
import com.flash.gamification.repository.UserQuestRepository;
import com.flash.home.dto.QuestResponse;
import com.flash.user.entity.User;
import com.flash.user.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.util.Arrays;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * Giao nhiệm vụ theo chu kỳ, cộng tiến độ từ sự kiện học, và nhận thưởng.
 * Tiến độ chỉ do server tính; client claim khi chưa đủ thì bị từ chối (422).
 */
@Service
@RequiredArgsConstructor
public class QuestService {

    /** period_start cố định của nhiệm vụ ONE_TIME, để mỗi user chỉ được giao đúng 1 lần. */
    static final LocalDate ONE_TIME_PERIOD = LocalDate.of(1970, 1, 1);

    private final UserService userService;
    private final QuestDefinitionRepository definitionRepository;
    private final UserQuestRepository userQuestRepository;
    private final XpService xpService;

    /** GET /v1/quests/today: tự giao nhiệm vụ của chu kỳ hiện tại nếu chưa có. */
    @Transactional
    public TodayQuestsResponse today(UUID userId) {
        User user = userService.lockActiveUser(userId);
        LocalDate today = Zones.today(user);
        ensureAssigned(user, today);

        Map<UUID, QuestDefinition> definitions = definitionsById();
        List<QuestResponse> quests = userQuestRepository.findByUserIdAndPeriodStartIn(userId, periods(today)).stream()
                .filter(q -> isCurrent(q, definitions.get(q.getQuestDefinitionId()), today))
                .sorted(Comparator.comparing((UserQuest q) -> definitions.get(q.getQuestDefinitionId()).getSortOrder())
                        .thenComparing(UserQuest::getCreatedAt, Comparator.nullsLast(Comparator.naturalOrder())))
                .map(q -> QuestResponse.of(q, definitions.get(q.getQuestDefinitionId())))
                .collect(Collectors.toList());
        return new TodayQuestsResponse(user.getCurrentXp(), quests);
    }

    /**
     * Cộng tiến độ cho các nhiệm vụ cùng loại thuộc chu kỳ của sự kiện.
     * Sự kiện của hôm nay thì giao nhiệm vụ trước (user có thể học trước khi mở màn Nhiệm vụ);
     * sự kiện offline của ngày cũ chỉ cập nhật nhiệm vụ đã được giao cho ngày đó.
     */
    @Transactional(propagation = Propagation.MANDATORY)
    public void onEvent(User user, QuestType type, int delta, Instant eventTime) {
        if (delta <= 0) {
            return;
        }
        LocalDate day = Zones.localDate(user, eventTime);
        LocalDate today = Zones.today(user);
        if (day.equals(today)) {
            ensureAssigned(user, today);
        }

        Map<UUID, QuestDefinition> definitions = definitionsById();
        for (UserQuest quest : userQuestRepository.findOpenByType(user.getId(), type, periods(day))) {
            if (!isCurrent(quest, definitions.get(quest.getQuestDefinitionId()), day)) {
                continue;
            }
            quest.setCurrentValue(quest.getCurrentValue() + delta);
            if (quest.getCompletedAt() == null && quest.getCurrentValue() >= quest.getTargetValue()) {
                quest.setCompletedAt(eventTime);
            }
        }
    }

    @Transactional
    public ClaimQuestResponse claim(UUID userId, UUID userQuestId) {
        User user = userService.lockActiveUser(userId);
        UserQuest quest = userQuestRepository.findByIdAndUserId(userQuestId, userId)
                .orElseThrow(() -> new BusinessException(ErrorCode.NOT_FOUND, "Không tìm thấy nhiệm vụ"));
        if (quest.getIsClaimed()) {
            throw new BusinessException(ErrorCode.ALREADY_CLAIMED);
        }
        if (quest.getCurrentValue() < quest.getTargetValue()) {
            throw new BusinessException(ErrorCode.QUEST_NOT_COMPLETED,
                    "Tiến độ " + quest.getCurrentValue() + "/" + quest.getTargetValue());
        }

        quest.setIsClaimed(true);
        quest.setClaimedAt(Instant.now());
        int awarded = xpService.award(user, quest.getXpReward(), XpSourceType.QUEST, quest.getId().toString(),
                Zones.today(user));
        return new ClaimQuestResponse(quest.getId(), awarded, user.getCurrentXp(), user.getTotalLifetimeXp());
    }

    /** Snapshot target/xp từ định nghĩa đang active tại thời điểm giao. */
    private void ensureAssigned(User user, LocalDate today) {
        List<UserQuest> existing = userQuestRepository.findByUserIdAndPeriodStartIn(user.getId(), periods(today));
        Set<String> assigned = existing.stream()
                .map(q -> q.getQuestDefinitionId() + "|" + q.getPeriodStart())
                .collect(Collectors.toSet());
        for (QuestDefinition definition : definitionRepository.findByIsActiveTrueOrderBySortOrderAscCreatedAtAsc()) {
            LocalDate period = periodOf(definition.getFrequency(), today);
            if (assigned.contains(definition.getId() + "|" + period)) {
                continue;
            }
            UserQuest quest = new UserQuest();
            quest.setUserId(user.getId());
            quest.setQuestDefinitionId(definition.getId());
            quest.setPeriodStart(period);
            quest.setTargetValue(definition.getTargetValue());
            quest.setXpReward(definition.getXpReward());
            userQuestRepository.save(quest);
        }
    }

    /**
     * Một dòng chỉ thuộc chu kỳ của {@code day} khi period_start khớp đúng tần suất của nó
     * (VD: nhiệm vụ ngày của thứ Hai không được tính là nhiệm vụ tuần). ONE_TIME đã nhận thì ẩn.
     */
    private static boolean isCurrent(UserQuest quest, QuestDefinition definition, LocalDate day) {
        if (definition == null || !quest.getPeriodStart().equals(periodOf(definition.getFrequency(), day))) {
            return false;
        }
        return definition.getFrequency() != QuestFrequency.ONE_TIME || !quest.getIsClaimed();
    }

    static LocalDate periodOf(QuestFrequency frequency, LocalDate day) {
        switch (frequency) {
            case WEEKLY:
                return Zones.weekStart(day);
            case ONE_TIME:
                return ONE_TIME_PERIOD;
            default:
                return day;
        }
    }

    private static Set<LocalDate> periods(LocalDate day) {
        // Không dùng Set.of: thứ Hai thì day == weekStart(day), Set.of ném lỗi khi trùng phần tử
        return new HashSet<>(Arrays.asList(day, Zones.weekStart(day), ONE_TIME_PERIOD));
    }

    private Map<UUID, QuestDefinition> definitionsById() {
        return definitionRepository.findAll().stream()
                .collect(Collectors.toMap(QuestDefinition::getId, Function.identity()));
    }
}
