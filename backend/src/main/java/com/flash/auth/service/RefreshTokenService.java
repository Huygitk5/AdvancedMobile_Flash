package com.flash.auth.service;

import com.flash.auth.entity.RefreshToken;
import com.flash.auth.repository.RefreshTokenRepository;
import com.flash.common.BusinessException;
import com.flash.common.ErrorCode;
import com.flash.common.util.Hashing;
import com.flash.security.JwtProperties;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.Instant;
import java.util.Base64;
import java.util.UUID;

/**
 * Refresh token: chuỗi ngẫu nhiên 256 bit, DB chỉ lưu SHA-256.
 * Mỗi lần refresh sẽ phát token mới và thu hồi token cũ (rotation, liên kết qua replaced_by_id).
 * Token đã bị thay thế mà còn được dùng lại nghĩa là có thể đã bị đánh cắp,
 * nên thu hồi toàn bộ phiên của user.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class RefreshTokenService {

    private static final SecureRandom RANDOM = new SecureRandom();
    private static final int TOKEN_BYTES = 32;
    private static final int MAX_USER_AGENT_LENGTH = 255;
    private static final int MAX_DEVICE_ID_LENGTH = 100;

    private final RefreshTokenRepository refreshTokenRepository;
    private final JwtProperties jwtProperties;

    @Transactional
    public IssuedRefreshToken issue(UUID userId, String deviceId, String userAgent) {
        byte[] bytes = new byte[TOKEN_BYTES];
        RANDOM.nextBytes(bytes);
        String rawToken = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);

        RefreshToken token = new RefreshToken();
        token.setUserId(userId);
        token.setTokenHash(Hashing.sha256Hex(rawToken));
        token.setDeviceId(truncate(deviceId, MAX_DEVICE_ID_LENGTH));
        token.setUserAgent(truncate(userAgent, MAX_USER_AGENT_LENGTH));
        token.setExpiresAt(Instant.now().plus(jwtProperties.getRefreshTokenTtl()));
        refreshTokenRepository.save(token);
        return new IssuedRefreshToken(token.getId(), userId, rawToken, token.getExpiresAt());
    }

    /**
     * Đổi refresh token cũ lấy token mới. noRollbackFor để việc thu hồi hàng loạt khi phát hiện
     * dùng lại token vẫn được commit dù method ném lỗi.
     */
    @Transactional(noRollbackFor = BusinessException.class)
    public IssuedRefreshToken rotate(String rawToken, String deviceId, String userAgent) {
        RefreshToken current = refreshTokenRepository.findByTokenHashForUpdate(Hashing.sha256Hex(rawToken))
                .orElseThrow(() -> new BusinessException(ErrorCode.INVALID_TOKEN));
        Instant now = Instant.now();

        if (current.getRevokedAt() != null) {
            if (current.getReplacedById() != null) {
                int revoked = revokeAll(current.getUserId());
                log.warn("Phát hiện dùng lại refresh token đã bị thay thế, user={}, thu hồi {} phiên",
                        current.getUserId(), revoked);
            }
            throw new BusinessException(ErrorCode.INVALID_TOKEN);
        }
        if (current.getExpiresAt().isBefore(now)) {
            throw new BusinessException(ErrorCode.INVALID_TOKEN, "Phiên đăng nhập đã hết hạn");
        }

        IssuedRefreshToken next = issue(current.getUserId(),
                deviceId != null ? deviceId : current.getDeviceId(), userAgent);
        current.setRevokedAt(now);
        current.setReplacedById(next.getId());
        return next;
    }

    /** Thu hồi 1 token (logout). Token không tồn tại hoặc đã thu hồi thì bỏ qua. */
    @Transactional
    public void revoke(String rawToken) {
        refreshTokenRepository.findByTokenHash(Hashing.sha256Hex(rawToken))
                .filter(t -> t.getRevokedAt() == null)
                .ifPresent(t -> t.setRevokedAt(Instant.now()));
    }

    /** Thu hồi mọi phiên của user (đổi/đặt lại mật khẩu, khoá, xoá tài khoản). */
    @Transactional
    public int revokeAll(UUID userId) {
        return refreshTokenRepository.revokeAllActive(userId, Instant.now());
    }

    private static String truncate(String value, int max) {
        return value == null || value.length() <= max ? value : value.substring(0, max);
    }
}
