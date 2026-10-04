package com.flash.common.util;

import com.flash.user.entity.User;

import java.time.DateTimeException;
import java.time.DayOfWeek;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.temporal.TemporalAdjusters;

/** "Ngày" của user luôn tính theo users.timezone (streak, thống kê ngày, nhiệm vụ ngày). */
public final class Zones {

    public static final ZoneId DEFAULT_ZONE = ZoneId.of("Asia/Ho_Chi_Minh");

    private Zones() {
    }

    public static ZoneId of(User user) {
        try {
            return ZoneId.of(user.getTimezone());
        } catch (DateTimeException e) {
            return DEFAULT_ZONE;
        }
    }

    public static LocalDate localDate(User user, Instant instant) {
        return instant.atZone(of(user)).toLocalDate();
    }

    public static LocalDate today(User user) {
        return LocalDate.now(of(user));
    }

    public static Instant startOfDay(User user, LocalDate date) {
        return date.atStartOfDay(of(user)).toInstant();
    }

    /** Thứ Hai đầu tuần, dùng làm period_start của nhiệm vụ WEEKLY. */
    public static LocalDate weekStart(LocalDate date) {
        return date.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
    }
}
