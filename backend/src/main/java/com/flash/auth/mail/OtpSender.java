package com.flash.auth.mail;

import com.flash.auth.entity.OtpPurpose;

public interface OtpSender {

    /** Gửi mã OTP 6 số tới email của người dùng; nội dung email tuỳ theo mục đích. */
    void sendOtp(String email, String fullName, OtpPurpose purpose, String otp);
}
