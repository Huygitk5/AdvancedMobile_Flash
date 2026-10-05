package com.flash.auth.dto;

import com.flash.user.dto.UserResponse;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;

@Getter
@Builder
public class AuthResponse {

    private final UserResponse user;
    private final String accessToken;
    private final String refreshToken;
    private final String tokenType;

    /** Số giây access token còn hiệu lực; null khi chưa cấp token (verificationRequired). */
    private final Long expiresIn;

    private final Instant refreshTokenExpiresAt;

    /**
     * true khi đăng ký xong nhưng email chưa xác thực: chưa có token, client chuyển sang
     * màn nhập OTP (POST /v1/auth/verify-email).
     */
    private final boolean verificationRequired;
}
