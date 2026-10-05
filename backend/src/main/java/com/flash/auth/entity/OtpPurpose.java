package com.flash.auth.entity;

/** Mục đích của một mã OTP gửi qua email (bảng password_reset_tokens dùng chung). */
public enum OtpPurpose {
    PASSWORD_RESET,
    EMAIL_VERIFY,
    CHANGE_PASSWORD
}
