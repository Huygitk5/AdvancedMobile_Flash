package com.flash.security;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.flash.common.ErrorCode;
import com.flash.common.JsonErrorWriter;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.OncePerRequestFilter;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Giới hạn /v1/sync/** theo user (cộng chung push / pull / content) trong cửa sổ 1 phút (§5.3d).
 * Chạy sau {@link JwtAuthFilter}; request chưa xác thực để Spring Security trả 401 như bình thường.
 */
public class SyncRateLimitFilter extends OncePerRequestFilter {

    private static final String SYNC_PREFIX = "/v1/sync/";

    private final FixedWindowRateLimiter limiter;
    private final ObjectMapper objectMapper;

    public SyncRateLimitFilter(int limitPerMinute, ObjectMapper objectMapper) {
        this.limiter = new FixedWindowRateLimiter(limitPerMinute);
        this.objectMapper = objectMapper;
    }

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        return !request.getRequestURI().startsWith(SYNC_PREFIX);
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.getPrincipal() instanceof UserPrincipal
                && !limiter.tryAcquire(((UserPrincipal) auth.getPrincipal()).getId().toString())) {
            JsonErrorWriter.write(response, objectMapper, ErrorCode.TOO_MANY_REQUESTS);
            return;
        }
        chain.doFilter(request, response);
    }
}
