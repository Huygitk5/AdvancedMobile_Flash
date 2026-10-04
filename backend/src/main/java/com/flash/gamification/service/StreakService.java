package com.flash.gamification.service;

import com.flash.common.util.Zones;
import com.flash.stats.repository.DailyStatisticRepository;
import com.flash.user.entity.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

/**
 * Streak theo ngày địa phương của user (DATA_ARCHITECTURE.md §5.3d, mục 6).
 * Người gọi phải đang giữ khoá dòng user và đã ghi hoạt động của ngày đó vào daily_statistics.
 */
@Service
@RequiredArgsConstructor
public class StreakService {

    private final DailyStatisticRepository dailyStatisticRepository;

    /** @param day ngày địa phương của sự kiện học hợp lệ (đã hiệu chỉnh lệch đồng hồ) */
    @Transactional(propagation = Propagation.MANDATORY)
    public void recordActivity(User user, LocalDate day) {
        LocalDate last = user.getLastActiveDate();
        if (last == null || day.isAfter(last)) {
            boolean consecutive = last != null && day.equals(last.plusDays(1));
            user.setStreakDays(consecutive ? user.getStreakDays() + 1 : 1);
            user.setLastActiveDate(day);
        } else if (day.isBefore(last)) {
            // Sự kiện offline đến muộn: có thể vừa lấp một ngày trống, nên đếm lại từ dữ liệu ngày
            user.setStreakDays(countStreakEndingAt(user, last));
        }
        user.setLongestStreak(Math.max(user.getLongestStreak(), user.getStreakDays()));
    }

    /**
     * Streak đang hiển thị: users.streak_days chỉ được cập nhật khi có hoạt động,
     * nên nếu đã bỏ lỡ quá 1 ngày thì chuỗi thực tế là 0.
     */
    public int currentStreak(User user) {
        LocalDate last = user.getLastActiveDate();
        if (last == null || last.isBefore(Zones.today(user).minusDays(1))) {
            return 0;
        }
        return user.getStreakDays();
    }

    private int countStreakEndingAt(User user, LocalDate last) {
        List<LocalDate> activeDays = dailyStatisticRepository.findActiveDatesDesc(user.getId(), last);
        int count = 0;
        LocalDate expected = last;
        for (LocalDate day : activeDays) {
            if (!day.equals(expected)) {
                break;
            }
            count++;
            expected = expected.minusDays(1);
        }
        return Math.max(count, 1);
    }
}
