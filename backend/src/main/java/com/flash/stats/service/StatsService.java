package com.flash.stats.service;

import com.flash.common.util.Zones;
import com.flash.gamification.service.StreakService;
import com.flash.stats.dto.DailyStatisticResponse;
import com.flash.stats.dto.StatisticsResponse;
import com.flash.stats.dto.StatsRange;
import com.flash.stats.entity.DailyStatistic;
import com.flash.stats.repository.DailyStatisticRepository;
import com.flash.user.entity.User;
import com.flash.user.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class StatsService {

    private final UserService userService;
    private final DailyStatisticRepository repository;
    private final StreakService streakService;

    @Transactional(readOnly = true)
    public StatisticsResponse statistics(UUID userId, StatsRange range) {
        User user = userService.getActiveUser(userId);
        List<DailyStatisticResponse> daily = range == StatsRange.ALL
                ? repository.findByUserIdOrderByStatDate(userId).stream()
                .map(DailyStatisticResponse::from)
                .collect(Collectors.toList())
                : lastDays(user, range.getDays());

        int correct = daily.stream().mapToInt(DailyStatisticResponse::getCorrectAnswers).sum();
        int total = daily.stream().mapToInt(DailyStatisticResponse::getTotalAnswers).sum();
        return StatisticsResponse.builder()
                .range(range)
                .daily(daily)
                .accuracy(total == 0 ? 0d : (double) correct / total)
                .xpGained(daily.stream().mapToInt(DailyStatisticResponse::getXpGained).sum())
                .wordsLearned(daily.stream().mapToInt(DailyStatisticResponse::getWordsLearned).sum())
                .studySeconds(daily.stream().mapToInt(DailyStatisticResponse::getStudySeconds).sum())
                .streakDays(streakService.currentStreak(user))
                .longestStreak(user.getLongestStreak())
                .totalWordsLearned(user.getTotalWordsLearned())
                .build();
    }

    /** Đủ {@code days} ngày tính đến hôm nay, ngày không học điền 0 để biểu đồ không bị hụt cột. */
    private List<DailyStatisticResponse> lastDays(User user, int days) {
        LocalDate today = Zones.today(user);
        LocalDate from = today.minusDays(days - 1L);
        Map<LocalDate, DailyStatistic> byDate = repository
                .findByUserIdAndStatDateBetweenOrderByStatDate(user.getId(), from, today).stream()
                .collect(Collectors.toMap(DailyStatistic::getStatDate, Function.identity()));

        List<DailyStatisticResponse> result = new ArrayList<>(days);
        for (LocalDate day = from; !day.isAfter(today); day = day.plusDays(1)) {
            DailyStatistic stat = byDate.get(day);
            result.add(stat != null ? DailyStatisticResponse.from(stat) : DailyStatisticResponse.empty(user.getId(), day));
        }
        return result;
    }
}
