package com.flash.auth.mail;

public interface OtpSender {

    void sendPasswordResetOtp(String email, String fullName, String otp);
}
