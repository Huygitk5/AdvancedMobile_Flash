package com.flash.stats.dto;

/** Khoảng thời gian trên ProgressScreen. WEEK/MONTH tính lùi từ hôm nay (theo timezone của user). */
public enum StatsRange {
    WEEK(7), MONTH(30), ALL(0);

    private final int days;

    StatsRange(int days) {
        this.days = days;
    }

    public int getDays() {
        return days;
    }
}
