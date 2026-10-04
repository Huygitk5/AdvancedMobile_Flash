package com.flash.security;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.flash.common.ErrorCode;
import com.flash.common.JsonErrorWriter;
import org.springframework.web.filter.OncePerRequestFilter;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Giới hạn số request /v1/auth/** theo (IP, endpoint) trong cửa sổ cố định 1 phút.
 * Bộ nhớ trong 1 instance: đủ cho 1 server; chạy nhiều instance thì chuyển sang Redis/Bucket4j.
 * Sau reverse proxy cần bật server.forward-headers-strategy để getRemoteAddr() là IP thật.
 */
public class AuthRateLimitFilter extends OncePerRequestFilter {

    private static final String AUTH_PREFIX = "/v1/auth/";
    private static final int CLEANUP_THRESHOLD = 10_000;

    private final int limitPerMinute;
    private final ObjectMapper objectMapper;
    private final Map<String, Window> windows = new ConcurrentHashMap<>();

    public AuthRateLimitFilter(int limitPerMinute, ObjectMapper objectMapper) {
        this.limitPerMinute = limitPerMinute;
        this.objectMapper = objectMapper;
    }

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        return !request.getRequestURI().startsWith(AUTH_PREFIX);
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException {
        long minute = System.currentTimeMillis() / 60_000;
        if (windows.size() > CLEANUP_THRESHOLD) {
            windows.entrySet().removeIf(e -> e.getValue().minute < minute);
        }

        String key = request.getRemoteAddr() + "|" + request.getRequestURI();
        Window window = windows.compute(key, (k, old) -> old == null || old.minute != minute ? new Window(minute) : old);
        if (window.count.incrementAndGet() > limitPerMinute) {
            JsonErrorWriter.write(response, objectMapper, ErrorCode.TOO_MANY_REQUESTS);
            return;
        }
        chain.doFilter(request, response);
    }

    private static final class Window {
        private final long minute;
        private final AtomicInteger count = new AtomicInteger();

        private Window(long minute) {
            this.minute = minute;
        }
    }
}
