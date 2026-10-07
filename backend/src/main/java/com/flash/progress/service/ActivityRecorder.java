package com.flash.progress.service;

import com.flash.common.util.Zones;
import com.flash.gamification.entity.QuestType;
import com.flash.gamification.service.QuestService;
import com.flash.gamification.service.StreakService;
import com.flash.stats.entity.DailyStatistic;
import com.flash.stats.service.DailyStatsService;
import com.flash.user.entity.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.util.function.Consumer;

/**
 * Ghi một sự kiện học hợp lệ (review, bài học, quiz): cập nhật thống kê ngày, rồi streak,
 * và nhiệm vụ "Duy trì Streak" khi đây là hoạt động đầu tiên của ngày.
 * Thứ tự quan trọng: streak đếm lại từ daily_statistics nên ngày đó phải được ghi trước.
 */
@Component
@RequiredArgsConstructor
public class ActivityRecorder {

    private final DailyStatsService dailyStatsService;
    private final StreakService streakService;
    private final QuestService questService;

    /** @return thống kê ngày (địa phương) của sự kiện, sau khi đã áp {@code update} */
    @Transactional(propagation = Propagation.MANDATORY)
    public DailyStatistic record(User user, Instant eventTime, Consumer<DailyStatistic> update) {
        LocalDate day = Zones.localDate(user, eventTime);
        DailyStatistic stat = dailyStatsService.forDate(user.getId(), day);
        boolean wasActive = isActive(stat);
        update.accept(stat);

        streakService.recordActivity(user, day);
        if (!wasActive) {
            questService.onEvent(user, QuestType.KEEP_STREAK, 1, eventTime);
        }
        return stat;
    }

    private static boolean isActive(DailyStatistic stat) {
        return stat.getCardsReviewed() > 0 || stat.getLessonsCompleted() > 0 || stat.getQuizzesCompleted() > 0;
    }
}
