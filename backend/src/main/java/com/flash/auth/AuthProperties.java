package com.flash.auth;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;

import java.time.Duration;

@Getter
@Setter
@ConfigurationProperties(prefix = "app.auth")
public class AuthProperties {

    /** Thời gian sống của OTP đặt lại mật khẩu. */
    private Duration otpTtl = Duration.ofMinutes(10);

    /** Số lần nhập sai OTP tối đa trước khi khoá mã. */
    private int otpMaxAttempts = 5;

    /** Khoảng cách tối thiểu giữa 2 lần gửi OTP cho cùng một tài khoản. */
    private Duration otpResendInterval = Duration.ofSeconds(60);

    /** Số request /v1/auth/** tối đa mỗi phút cho mỗi (IP, endpoint). */
    private int rateLimitPerMinute = 20;
}
