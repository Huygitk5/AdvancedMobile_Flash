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

    /** Số giây access token còn hiệu lực. */
    private final long expiresIn;

    private final Instant refreshTokenExpiresAt;
}
