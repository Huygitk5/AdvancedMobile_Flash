package com.flash.gamification.service;

import java.time.Duration;
import java.time.Instant;

/** Bảng luật XP và kiểm tra tính hợp lý của thời gian sự kiện (DATA_ARCHITECTURE.md §5.3d). */
public final class XpRules {

    /** Know một thẻ, lần đầu trong ngày với thẻ đó. */
    public static final int KNOW_XP = 2;
    public static final int KNOW_DAILY_CAP = 300;

    /** Thẻ chuyển sang is_learned lần đầu. */
    public static final int LEARNED_XP = 5;

    public static final int LESSON_XP = 10;
    /** Chỉ 20 bài đầu tiên mỗi ngày được tính XP. */
    public static final int LESSON_DAILY_XP_LIMIT = 20;

    /** Quiz: mỗi câu đúng, và thưởng thêm khi đạt 100%. Chỉ lần làm đầu tiên trong ngày của mỗi quiz. */
    public static final int QUIZ_CORRECT_XP = 2;
    public static final int QUIZ_PERFECT_BONUS = 10;

    /** Hai review cùng một thẻ cách nhau ít hơn mức này bị coi là bất thường. */
    public static final Duration MIN_REVIEW_GAP = Duration.ofSeconds(1);
    public static final int MAX_REVIEWS_PER_MINUTE = 60;

    private static final Duration MAX_PAST = Duration.ofDays(7);
    private static final Duration MAX_FUTURE = Duration.ofMinutes(5);

    private XpRules() {
    }

    /**
     * Thời điểm sự kiện (đã hiệu chỉnh lệch đồng hồ) phải nằm trong [now - 7 ngày, now + 5 phút].
     * Sự kiện ngoài khoảng này vẫn được lưu nhưng không cộng XP, không tính streak.
     */
    public static boolean isPlausible(Instant eventTime, Instant now) {
        return !eventTime.isBefore(now.minus(MAX_PAST)) && !eventTime.isAfter(now.plus(MAX_FUTURE));
    }
}
