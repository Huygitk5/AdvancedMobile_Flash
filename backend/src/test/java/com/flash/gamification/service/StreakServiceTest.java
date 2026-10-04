package com.flash.gamification.service;

import com.flash.stats.repository.DailyStatisticRepository;
import com.flash.user.entity.User;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.time.ZoneId;
import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

/** Thuật toán streak §5.3d mục 6. Ranh giới ngày theo timezone được kiểm ở GamificationIntegrationTest. */
@ExtendWith(MockitoExtension.class)
class StreakServiceTest {

    private static final LocalDate D = LocalDate.of(2026, 10, 1);

    @Mock
    private DailyStatisticRepository dailyStatisticRepository;

    @InjectMocks
    private StreakService streakService;

    private User user;

    @BeforeEach
    void setUp() {
        user = new User();
        user.setId(UUID.randomUUID());
    }

    @Test
    void firstActivityStartsStreakAtOne() {
        streakService.recordActivity(user, D);
        assertStreak(1, 1, D);
    }

    @Test
    void sameDayDoesNotChangeStreak() {
        streakService.recordActivity(user, D);
        streakService.recordActivity(user, D);
        assertStreak(1, 1, D);
    }

    @Test
    void consecutiveDaysIncreaseStreakAndLongest() {
        streakService.recordActivity(user, D);
        streakService.recordActivity(user, D.plusDays(1));
        streakService.recordActivity(user, D.plusDays(2));
        assertStreak(3, 3, D.plusDays(2));
        verifyNoInteractions(dailyStatisticRepository);
    }

    @Test
    void gapResetsStreakButKeepsLongest() {
        user.setStreakDays(5);
        user.setLongestStreak(5);
        user.setLastActiveDate(D);

        streakService.recordActivity(user, D.plusDays(2));

        assertStreak(1, 5, D.plusDays(2));
    }

    /** Sự kiện offline của ngày D+1 đến sau khi đã ghi D và D+2: lấp chỗ trống nên streak thành 3. */
    @Test
    void lateEventRecomputesStreakFromDailyStatistics() {
        user.setStreakDays(1);
        user.setLongestStreak(1);
        user.setLastActiveDate(D.plusDays(2));
        when(dailyStatisticRepository.findActiveDatesDesc(any(), eq(D.plusDays(2))))
                .thenReturn(List.of(D.plusDays(2), D.plusDays(1), D, D.minusDays(5)));

        streakService.recordActivity(user, D.plusDays(1));

        assertStreak(3, 3, D.plusDays(2));
    }

    @Test
    void lateEventThatDoesNotFillGapKeepsStreak() {
        user.setStreakDays(1);
        user.setLongestStreak(4);
        user.setLastActiveDate(D.plusDays(5));
        when(dailyStatisticRepository.findActiveDatesDesc(any(), eq(D.plusDays(5))))
                .thenReturn(List.of(D.plusDays(5), D.plusDays(2)));

        streakService.recordActivity(user, D.plusDays(2));

        assertStreak(1, 4, D.plusDays(5));
    }

    @Test
    void currentStreakIsZeroOnceADayIsMissed() {
        user.setStreakDays(7);
        user.setLongestStreak(7);
        user.setLastActiveDate(LocalDate.now(ZoneId.of(user.getTimezone())).minusDays(2));
        assertThat(streakService.currentStreak(user)).isZero();

        user.setLastActiveDate(LocalDate.now(ZoneId.of(user.getTimezone())).minusDays(1));
        assertThat(streakService.currentStreak(user)).isEqualTo(7);
    }

    private void assertStreak(int streak, int longest, LocalDate lastActive) {
        assertThat(user.getStreakDays()).isEqualTo(streak);
        assertThat(user.getLongestStreak()).isEqualTo(longest);
        assertThat(user.getLastActiveDate()).isEqualTo(lastActive);
    }
}
