package com.flash.auth.service;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.Instant;
import java.util.UUID;

/** Refresh token vừa phát hành. rawToken chỉ tồn tại trong bộ nhớ, DB chỉ lưu hash. */
@Getter
@AllArgsConstructor
public class IssuedRefreshToken {

    private final UUID id;
    private final UUID userId;
    private final String rawToken;
    private final Instant expiresAt;
}
