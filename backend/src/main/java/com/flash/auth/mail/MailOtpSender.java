package com.flash.auth.mail;

import com.flash.auth.AuthProperties;
import com.flash.auth.entity.OtpPurpose;
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
    public void sendOtp(String email, String fullName, OtpPurpose purpose, String otp) {
        JavaMailSender sender = mailSender.getIfAvailable();
        if (sender == null) {
            log.info("[DEV - chưa cấu hình SMTP] OTP {} cho {}: {}", purpose, email, otp);
            return;
        }
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(from);
        message.setTo(email);
        message.setSubject("Flash English - " + subject(purpose));
        message.setText("Xin chào " + fullName + ",\n\n"
                + intro(purpose) + otp + "\n"
                + "Mã có hiệu lực trong " + authProperties.getOtpTtl().toMinutes() + " phút. "
                + "Không chia sẻ mã này cho bất kỳ ai.\n\n"
                + "Nếu bạn không thực hiện yêu cầu này, hãy bỏ qua email này.");
        try {
            sender.send(message);
        } catch (MailException e) {
            // Không ném lỗi ra API: các endpoint gửi OTP luôn trả 200 để không lộ email có tồn tại hay không
            log.error("Gửi email OTP tới {} thất bại: {}", email, e.getMessage());
        }
    }

    private static String subject(OtpPurpose purpose) {
        switch (purpose) {
            case EMAIL_VERIFY:
                return "Mã xác thực email";
            case CHANGE_PASSWORD:
                return "Mã xác nhận đổi mật khẩu";
            default:
                return "Mã đặt lại mật khẩu";
        }
    }

    private static String intro(OtpPurpose purpose) {
        switch (purpose) {
            case EMAIL_VERIFY:
                return "Mã OTP xác thực email đăng ký tài khoản của bạn là: ";
            case CHANGE_PASSWORD:
                return "Mã OTP xác nhận đổi mật khẩu của bạn là: ";
            default:
                return "Mã OTP đặt lại mật khẩu của bạn là: ";
        }
    }
}
