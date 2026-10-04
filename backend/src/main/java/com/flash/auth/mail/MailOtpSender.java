package com.flash.auth.mail;

import com.flash.auth.AuthProperties;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.MailException;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Component;

/**
 * Gửi OTP qua email. Khi chưa cấu hình SMTP (spring.mail.host) thì chỉ in OTP ra log để dev test.
 */
@Slf4j
@Component
public class MailOtpSender implements OtpSender {

    private final ObjectProvider<JavaMailSender> mailSender;
    private final AuthProperties authProperties;
    private final String from;

    public MailOtpSender(ObjectProvider<JavaMailSender> mailSender, AuthProperties authProperties,
                         @Value("${app.mail.from:no-reply@flash.local}") String from) {
        this.mailSender = mailSender;
        this.authProperties = authProperties;
        this.from = from;
    }

    @Override
    public void sendPasswordResetOtp(String email, String fullName, String otp) {
        JavaMailSender sender = mailSender.getIfAvailable();
        if (sender == null) {
            log.info("[DEV - chưa cấu hình SMTP] OTP đặt lại mật khẩu cho {}: {}", email, otp);
            return;
        }
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(from);
        message.setTo(email);
        message.setSubject("Flash English - Mã đặt lại mật khẩu");
        message.setText("Xin chào " + fullName + ",\n\n"
                + "Mã OTP đặt lại mật khẩu của bạn là: " + otp + "\n"
                + "Mã có hiệu lực trong " + authProperties.getOtpTtl().toMinutes() + " phút.\n\n"
                + "Nếu bạn không yêu cầu, hãy bỏ qua email này.");
        try {
            sender.send(message);
        } catch (MailException e) {
            // Không ném lỗi ra API: forgot-password luôn trả 200 để không lộ email có tồn tại hay không
            log.error("Gửi email OTP tới {} thất bại: {}", email, e.getMessage());
        }
    }
}
