package com.flash.auth.service;

import com.flash.auth.AuthProperties;
import com.flash.auth.entity.OtpPurpose;
import com.flash.auth.entity.PasswordResetToken;
import com.flash.auth.mail.OtpSender;
import com.flash.auth.repository.PasswordResetTokenRepository;
import com.flash.common.BusinessException;
import com.flash.common.ErrorCode;
import com.flash.common.util.Hashing;
import com.flash.user.entity.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.Instant;
import java.util.UUID;

/**
 * OTP 6 số gửi qua email, dùng chung cho đặt lại mật khẩu, xác thực email và xác nhận đổi mật khẩu.
 * Chỉ lưu hash; mỗi (user, mục đích) có tối đa 1 mã còn hiệu lực; nhập sai quá số lần cho phép thì khoá mã.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class OtpService {

    private static final SecureRandom RANDOM = new SecureRandom();

    private final PasswordResetTokenRepository tokenRepository;
    private final OtpSender otpSender;
    private final AuthProperties authProperties;

    /** @return false nếu bị bỏ qua vì mã trước đó vừa được gửi trong khoảng otp-resend-interval */
    @Transactional
    public boolean issue(User user, OtpPurpose purpose) {
        Instant now = Instant.now();
        boolean sentRecently = tokenRepository.findFirstByUserIdAndPurposeOrderByCreatedAtDesc(user.getId(), purpose)
                .map(t -> t.getCreatedAt() != null
                        && t.getCreatedAt().isAfter(now.minus(authProperties.getOtpResendInterval())))
                .orElse(false);
        if (sentRecently) {
            log.debug("Bỏ qua gửi OTP {} cho user {}: vừa gửi trong {}", purpose, user.getId(),
                    authProperties.getOtpResendInterval());
            return false;
        }

        tokenRepository.invalidateActive(user.getId(), purpose, now);

        String otp = String.format("%06d", RANDOM.nextInt(1_000_000));
        PasswordResetToken token = new PasswordResetToken();
        token.setId(UUID.randomUUID());
        token.setUserId(user.getId());
        token.setPurpose(purpose);
        token.setTokenHash(hash(token.getId(), otp));
        token.setExpiresAt(now.plus(authProperties.getOtpTtl()));
        tokenRepository.save(token);

        otpSender.sendOtp(user.getEmail(), user.getFullName(), purpose, otp);
        return true;
    }

    /**
     * Kiểm tra và dùng (một lần) OTP. Người gọi phải khai báo noRollbackFor = BusinessException
     * để số lần nhập sai vẫn được lưu khi ném INVALID_OTP.
     */
    @Transactional(noRollbackFor = BusinessException.class)
    public void verify(User user, OtpPurpose purpose, String otp) {
        Instant now = Instant.now();
        PasswordResetToken token = tokenRepository.findActiveForUpdate(user.getId(), purpose, now).stream()
                .findFirst()
                .orElseThrow(() -> new BusinessException(ErrorCode.INVALID_OTP));

        if (token.getAttemptCount() >= authProperties.getOtpMaxAttempts()) {
            throw new BusinessException(ErrorCode.TOO_MANY_REQUESTS,
                    "Nhập sai OTP quá nhiều lần, vui lòng yêu cầu mã mới");
        }
        if (otp == null || !Hashing.constantTimeEquals(hash(token.getId(), otp), token.getTokenHash())) {
            token.setAttemptCount(token.getAttemptCount() + 1);
            throw new BusinessException(ErrorCode.INVALID_OTP);
        }
        token.setUsedAt(now);
    }

    /**
     * OTP chỉ có 10^6 giá trị nên hash kèm id của token làm salt:
     * vừa chống tra bảng, vừa không vi phạm UNIQUE(token_hash) khi 2 user trùng OTP.
     */
    private static String hash(UUID tokenId, String otp) {
        return Hashing.sha256Hex(tokenId + ":" + otp);
    }
}
