package com.flash.auth.service;

import com.flash.auth.entity.OtpPurpose;
import com.flash.common.BusinessException;
import com.flash.common.ErrorCode;
import com.flash.common.util.Emails;
import com.flash.user.entity.User;
import com.flash.user.entity.UserStatus;
import com.flash.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class PasswordResetService {

    private final UserRepository userRepository;
    private final OtpService otpService;
    private final RefreshTokenService refreshTokenService;
    private final PasswordEncoder passwordEncoder;

    /** Luôn kết thúc êm (API trả 200) để không lộ email nào đã đăng ký. */
    @Transactional
    public void requestReset(String rawEmail) {
        Optional<User> found = userRepository.findByEmailAndDeletedAtIsNull(Emails.normalize(rawEmail));
        if (found.isEmpty()) {
            log.debug("forgot-password cho email chưa đăng ký");
            return;
        }
        User user = found.get();
        if (user.getStatus() == UserStatus.PENDING_VERIFY) {
            log.debug("forgot-password cho tài khoản {} chưa xác thực email, bỏ qua", user.getId());
            return;
        }
        otpService.issue(user, OtpPurpose.PASSWORD_RESET);
    }

    /** noRollbackFor để số lần nhập sai vẫn được lưu khi ném INVALID_OTP. */
    @Transactional(noRollbackFor = BusinessException.class)
    public void resetPassword(String rawEmail, String otp, String newPassword) {
        User user = userRepository.findByEmailAndDeletedAtIsNull(Emails.normalize(rawEmail))
                .orElseThrow(() -> new BusinessException(ErrorCode.INVALID_OTP));
        otpService.verify(user, OtpPurpose.PASSWORD_RESET, otp);

        user.setPasswordHash(passwordEncoder.encode(newPassword));
        refreshTokenService.revokeAll(user.getId());
    }
}
