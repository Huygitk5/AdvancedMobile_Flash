package com.flash.stats.service;

import com.flash.common.BusinessException;
import com.flash.common.ErrorCode;
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
import java.time.temporal.ChronoUnit;
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

    /** CUSTOM tối đa 366 ngày để một request không kéo cả lịch sử. */
    static final int MAX_CUSTOM_DAYS = 366;

    @Transactional(readOnly = true)
    public StatisticsResponse statistics(UUID userId, StatsRange range, LocalDate customFrom, LocalDate customTo) {
        User user = userService.getActiveUser(userId);
        LocalDate today = Zones.today(user);
        LocalDate from;
        LocalDate to = today;
        List<DailyStatisticResponse> daily;
        switch (range) {
            case ALL:
                daily = repository.findByUserIdOrderByStatDate(userId).stream()
                        .map(DailyStatisticResponse::from)
                        .collect(Collectors.toList());
                from = daily.isEmpty() ? today : daily.get(0).getDate();
                break;
            case YEAR:
                from = today.minusDays(range.getDays() - 1L);
                daily = existing(userId, from, today);
                break;
            case CUSTOM:
                if (customFrom == null || customTo == null) {
                    throw new BusinessException(ErrorCode.VALIDATION_ERROR, "CUSTOM cần cả from và to");
                }
                if (customTo.isBefore(customFrom)) {
                    throw new BusinessException(ErrorCode.VALIDATION_ERROR, "Ngày kết thúc phải sau ngày bắt đầu");
                }
                if (ChronoUnit.DAYS.between(customFrom, customTo) + 1 > MAX_CUSTOM_DAYS) {
                    throw new BusinessException(ErrorCode.VALIDATION_ERROR,
                            "Khoảng ngày tối đa " + MAX_CUSTOM_DAYS + " ngày");
                }
                from = customFrom;
                to = customTo;
                daily = fill(user, from, to);
                break;
            default:
                from = today.minusDays(range.getDays() - 1L);
                daily = fill(user, from, today);
        }

        int correct = daily.stream().mapToInt(DailyStatisticResponse::getCorrectAnswers).sum();
        int total = daily.stream().mapToInt(DailyStatisticResponse::getTotalAnswers).sum();
        return StatisticsResponse.builder()
                .range(range)
                .from(from)
                .to(to)
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

    private List<DailyStatisticResponse> existing(UUID userId, LocalDate from, LocalDate to) {
        return repository.findByUserIdAndStatDateBetweenOrderByStatDate(userId, from, to).stream()
                .map(DailyStatisticResponse::from)
                .collect(Collectors.toList());
    }

    /** Đủ từng ngày trong [from, to], ngày không học điền 0 để biểu đồ không bị hụt cột. */
    private List<DailyStatisticResponse> fill(User user, LocalDate from, LocalDate to) {
        Map<LocalDate, DailyStatistic> byDate = repository
                .findByUserIdAndStatDateBetweenOrderByStatDate(user.getId(), from, to).stream()
                .collect(Collectors.toMap(DailyStatistic::getStatDate, Function.identity()));

        List<DailyStatisticResponse> result = new ArrayList<>();
        for (LocalDate day = from; !day.isAfter(to); day = day.plusDays(1)) {
            DailyStatistic stat = byDate.get(day);
            result.add(stat != null ? DailyStatisticResponse.from(stat) : DailyStatisticResponse.empty(user.getId(), day));
        }
        return result;
    }
}
