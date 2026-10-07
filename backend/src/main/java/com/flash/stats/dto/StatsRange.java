package com.flash.stats.dto;

/**
 * Khoảng thời gian trên ProgressScreen. WEEK/MONTH/YEAR tính lùi từ hôm nay (theo timezone của user);
 * CUSTOM dùng cặp from/to do client chọn.
 */
public enum StatsRange {
    WEEK(7), MONTH(30), YEAR(365), ALL(0), CUSTOM(0);

    private final int days;

    StatsRange(int days) {
        this.days = days;
    }

    public int getDays() {
        return days;
    }
}
