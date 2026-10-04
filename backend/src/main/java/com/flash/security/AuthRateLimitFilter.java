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

/**
 * Giới hạn số request /v1/auth/** theo (IP, endpoint) trong cửa sổ cố định 1 phút.
 * Sau reverse proxy cần bật server.forward-headers-strategy để getRemoteAddr() là IP thật.
 */
public class AuthRateLimitFilter extends OncePerRequestFilter {

    private static final String AUTH_PREFIX = "/v1/auth/";

    private final FixedWindowRateLimiter limiter;
    private final ObjectMapper objectMapper;

    public AuthRateLimitFilter(int limitPerMinute, ObjectMapper objectMapper) {
        this.limiter = new FixedWindowRateLimiter(limitPerMinute);
        this.objectMapper = objectMapper;
    }

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        return !request.getRequestURI().startsWith(AUTH_PREFIX);
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException {
        if (!limiter.tryAcquire(request.getRemoteAddr() + "|" + request.getRequestURI())) {
            JsonErrorWriter.write(response, objectMapper, ErrorCode.TOO_MANY_REQUESTS);
            return;
        }
        chain.doFilter(request, response);
    }
}
