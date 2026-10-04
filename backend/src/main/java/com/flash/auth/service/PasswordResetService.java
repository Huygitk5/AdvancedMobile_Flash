package com.flash.auth.service;

import com.flash.auth.AuthProperties;
import com.flash.auth.entity.PasswordResetToken;
import com.flash.auth.mail.OtpSender;
import com.flash.auth.repository.PasswordResetTokenRepository;
import com.flash.common.BusinessException;
import com.flash.common.ErrorCode;
import com.flash.common.util.Emails;
import com.flash.common.util.Hashing;
import com.flash.user.entity.User;
import com.flash.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class PasswordResetService {

    private static final SecureRandom RANDOM = new SecureRandom();

    private final UserRepository userRepository;
    private final PasswordResetTokenRepository tokenRepository;
    private final RefreshTokenService refreshTokenService;
    private final OtpSender otpSender;
    private final PasswordEncoder passwordEncoder;
    private final AuthProperties authProperties;

    /** Luôn kết thúc êm (API trả 200) để không lộ email nào đã đăng ký. */
    @Transactional
    public void requestReset(String rawEmail) {
        Optional<User> found = userRepository.findByEmailAndDeletedAtIsNull(Emails.normalize(rawEmail));
        if (found.isEmpty()) {
            log.debug("forgot-password cho email chưa đăng ký");
            return;
        }
        User user = found.get();
        Instant now = Instant.now();

        boolean sentRecently = tokenRepository.findFirstByUserIdOrderByCreatedAtDesc(user.getId())
                .map(t -> t.getCreatedAt() != null
                        && t.getCreatedAt().isAfter(now.minus(authProperties.getOtpResendInterval())))
                .orElse(false);
        if (sentRecently) {
            log.debug("Bỏ qua gửi OTP cho user {}: vừa gửi trong {}", user.getId(), authProperties.getOtpResendInterval());
            return;
        }

        tokenRepository.invalidateActive(user.getId(), now);

        String otp = String.format("%06d", RANDOM.nextInt(1_000_000));
        PasswordResetToken token = new PasswordResetToken();
        token.setId(UUID.randomUUID());
        token.setUserId(user.getId());
        token.setTokenHash(hashOtp(token.getId(), otp));
        token.setExpiresAt(now.plus(authProperties.getOtpTtl()));
        tokenRepository.save(token);

        otpSender.sendPasswordResetOtp(user.getEmail(), user.getFullName(), otp);
    }

    /** noRollbackFor để số lần nhập sai vẫn được lưu khi ném INVALID_OTP. */
    @Transactional(noRollbackFor = BusinessException.class)
    public void resetPassword(String rawEmail, String otp, String newPassword) {
        User user = userRepository.findByEmailAndDeletedAtIsNull(Emails.normalize(rawEmail))
                .orElseThrow(() -> new BusinessException(ErrorCode.INVALID_OTP));
        Instant now = Instant.now();
        PasswordResetToken token = tokenRepository.findActiveForUpdate(user.getId(), now).stream()
                .findFirst()
                .orElseThrow(() -> new BusinessException(ErrorCode.INVALID_OTP));

        if (token.getAttemptCount() >= authProperties.getOtpMaxAttempts()) {
            throw new BusinessException(ErrorCode.TOO_MANY_REQUESTS,
                    "Nhập sai OTP quá nhiều lần, vui lòng yêu cầu mã mới");
        }
        if (!Hashing.constantTimeEquals(hashOtp(token.getId(), otp), token.getTokenHash())) {
            token.setAttemptCount(token.getAttemptCount() + 1);
            throw new BusinessException(ErrorCode.INVALID_OTP);
        }

        token.setUsedAt(now);
        user.setPasswordHash(passwordEncoder.encode(newPassword));
        refreshTokenService.revokeAll(user.getId());
    }

    /**
     * OTP chỉ có 10^6 giá trị nên hash kèm id của token làm salt:
     * vừa chống tra bảng, vừa không vi phạm UNIQUE(token_hash) khi 2 user trùng OTP.
     */
    private static String hashOtp(UUID tokenId, String otp) {
        return Hashing.sha256Hex(tokenId + ":" + otp);
    }
}
