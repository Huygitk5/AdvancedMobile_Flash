package com.flash.auth.google;

import lombok.AllArgsConstructor;
import lombok.Getter;

/** Thông tin lấy từ idToken Google đã được xác minh. */
@Getter
@AllArgsConstructor
public class GoogleUserInfo {

    /** Claim "sub": id cố định của tài khoản Google. */
    private final String subject;
    private final String email;
    private final boolean emailVerified;
    private final String name;
    private final String pictureUrl;
}
