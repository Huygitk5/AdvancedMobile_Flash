package com.flash.security;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Đếm request theo khoá trong cửa sổ cố định 1 phút.
 * Bộ nhớ trong 1 instance: đủ cho 1 server; chạy nhiều instance thì chuyển sang Redis/Bucket4j.
 */
public class FixedWindowRateLimiter {

    private static final int CLEANUP_THRESHOLD = 10_000;

    private final int limitPerMinute;
    private final Map<String, Window> windows = new ConcurrentHashMap<>();

    public FixedWindowRateLimiter(int limitPerMinute) {
        this.limitPerMinute = limitPerMinute;
    }

    /** @return false nếu khoá đã vượt giới hạn trong phút hiện tại */
    public boolean tryAcquire(String key) {
        long minute = System.currentTimeMillis() / 60_000;
        if (windows.size() > CLEANUP_THRESHOLD) {
            windows.entrySet().removeIf(e -> e.getValue().minute < minute);
        }
        Window window = windows.compute(key, (k, old) -> old == null || old.minute != minute ? new Window(minute) : old);
        return window.count.incrementAndGet() <= limitPerMinute;
    }

    private static final class Window {
        private final long minute;
        private final AtomicInteger count = new AtomicInteger();

        private Window(long minute) {
            this.minute = minute;
        }
    }
}
