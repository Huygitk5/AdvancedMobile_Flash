package com.flash.auth.service;

import com.flash.auth.dto.AuthResponse;
import com.flash.auth.dto.GoogleLoginRequest;
import com.flash.auth.dto.LoginRequest;
import com.flash.auth.dto.RefreshTokenRequest;
import com.flash.auth.dto.RegisterRequest;
import com.flash.auth.dto.VerifyEmailRequest;
import com.flash.auth.AuthProperties;
import com.flash.auth.entity.AuthProviderType;
import com.flash.auth.entity.OtpPurpose;
import com.flash.auth.entity.UserAuthProvider;
import com.flash.auth.google.GoogleTokenVerifier;
import com.flash.auth.google.GoogleUserInfo;
import com.flash.auth.repository.UserAuthProviderRepository;
import com.flash.common.BusinessException;
import com.flash.common.ErrorCode;
import com.flash.common.util.Emails;
import com.flash.security.JwtService;
import com.flash.user.dto.ChangePasswordRequest;
import com.flash.user.dto.UserResponse;
import com.flash.user.entity.User;
import com.flash.user.entity.UserRole;
import com.flash.user.entity.UserStatus;
import com.flash.user.repository.UserRepository;
import com.flash.user.service.UserService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.Instant;
import java.util.UUID;

@Slf4j
@Service
public class AuthService {

    private final UserRepository userRepository;
    private final UserAuthProviderRepository authProviderRepository;
    private final UserService userService;
    private final RefreshTokenService refreshTokenService;
    private final JwtService jwtService;
    private final GoogleTokenVerifier googleTokenVerifier;
    private final PasswordEncoder passwordEncoder;
    private final OtpService otpService;
    private final AuthProperties authProperties;

    /** Hash giả để so sánh khi email không tồn tại, giữ thời gian phản hồi giống trường hợp sai mật khẩu. */
    private final String dummyPasswordHash;

    public AuthService(UserRepository userRepository, UserAuthProviderRepository authProviderRepository,
                       UserService userService, RefreshTokenService refreshTokenService, JwtService jwtService,
                       GoogleTokenVerifier googleTokenVerifier, PasswordEncoder passwordEncoder,
                       OtpService otpService, AuthProperties authProperties) {
        this.userRepository = userRepository;
        this.authProviderRepository = authProviderRepository;
        this.userService = userService;
        this.refreshTokenService = refreshTokenService;
        this.jwtService = jwtService;
        this.googleTokenVerifier = googleTokenVerifier;
        this.passwordEncoder = passwordEncoder;
        this.otpService = otpService;
        this.authProperties = authProperties;
        this.dummyPasswordHash = passwordEncoder.encode(UUID.randomUUID().toString());
    }

    /**
     * Khi bật xác thực email: tạo tài khoản PENDING_VERIFY, gửi OTP và chưa cấp token
     * (verificationRequired = true). Đăng ký lại cùng email chưa xác thực thì ghi đè tên/mật khẩu và gửi lại OTP.
     */
    @Transactional
    public AuthResponse register(RegisterRequest request, String userAgent) {
        if (!authProperties.isRequireEmailVerification()) {
            User user = userService.createUser(request.getEmail(), request.getFullName(),
                    passwordEncoder.encode(request.getPassword()), UserRole.USER, false, null);
            return issueTokens(user, request.getDeviceId(), userAgent);
        }

        User pending = userRepository.findByEmailAndDeletedAtIsNull(Emails.normalize(request.getEmail()))
                .filter(u -> u.getStatus() == UserStatus.PENDING_VERIFY)
                .orElse(null);
        User user;
        if (pending != null) {
            pending.setFullName(request.getFullName().trim());
            pending.setPasswordHash(passwordEncoder.encode(request.getPassword()));
            user = pending;
        } else {
            user = userService.createUser(request.getEmail(), request.getFullName(),
                    passwordEncoder.encode(request.getPassword()), UserRole.USER, false, null);
            user.setStatus(UserStatus.PENDING_VERIFY);
        }
        otpService.issue(user, OtpPurpose.EMAIL_VERIFY);
        return AuthResponse.builder().user(UserResponse.from(user)).verificationRequired(true).build();
    }

    /** Nhập đúng OTP: kích hoạt tài khoản và đăng nhập luôn. noRollbackFor để lưu số lần nhập sai. */
    @Transactional(noRollbackFor = BusinessException.class)
    public AuthResponse verifyEmail(VerifyEmailRequest request, String userAgent) {
        User user = userRepository.findByEmailAndDeletedAtIsNull(Emails.normalize(request.getEmail()))
                .filter(u -> u.getStatus() == UserStatus.PENDING_VERIFY)
                .orElseThrow(() -> new BusinessException(ErrorCode.INVALID_OTP));
        otpService.verify(user, OtpPurpose.EMAIL_VERIFY, request.getOtp());

        user.setStatus(UserStatus.ACTIVE);
        user.setEmailVerifiedAt(Instant.now());
        return issueTokens(user, request.getDeviceId(), userAgent);
    }

    /** Luôn kết thúc êm (API trả 200) để không lộ email nào đã đăng ký. */
    @Transactional
    public void resendVerification(String rawEmail) {
        userRepository.findByEmailAndDeletedAtIsNull(Emails.normalize(rawEmail))
                .filter(u -> u.getStatus() == UserStatus.PENDING_VERIFY)
                .ifPresent(u -> otpService.issue(u, OtpPurpose.EMAIL_VERIFY));
    }

    /** Gửi OTP xác nhận đổi mật khẩu tới email của người đang đăng nhập. */
    @Transactional
    public void requestChangePasswordOtp(UUID userId) {
        otpService.issue(userService.getActiveUser(userId), OtpPurpose.CHANGE_PASSWORD);
    }

    @Transactional(noRollbackFor = BusinessException.class)
    public AuthResponse login(LoginRequest request, String userAgent) {
        User user = userRepository.findByEmailAndDeletedAtIsNull(Emails.normalize(request.getEmail())).orElse(null);
        String hash = user != null && user.getPasswordHash() != null ? user.getPasswordHash() : dummyPasswordHash;
        boolean matches = passwordEncoder.matches(request.getPassword(), hash);
        if (user == null || user.getPasswordHash() == null || !matches) {
            throw new BusinessException(ErrorCode.INVALID_CREDENTIALS);
        }
        if (user.getStatus() == UserStatus.PENDING_VERIFY) {
            // Mật khẩu đúng nhưng chưa xác thực email: gửi lại OTP rồi báo client mở màn nhập mã
            otpService.issue(user, OtpPurpose.EMAIL_VERIFY);
            throw new BusinessException(ErrorCode.EMAIL_NOT_VERIFIED);
        }
        ensureCanSignIn(user);
        return issueTokens(user, request.getDeviceId(), userAgent);
    }

    @Transactional
    public AuthResponse loginWithGoogle(GoogleLoginRequest request, String userAgent) {
        GoogleUserInfo info = googleTokenVerifier.verify(request.getIdToken());
        if (!info.isEmailVerified() || !StringUtils.hasText(info.getEmail())) {
            throw new BusinessException(ErrorCode.INVALID_TOKEN, "Email của tài khoản Google chưa được xác minh");
        }

        User user = authProviderRepository
                .findByProviderAndProviderUserId(AuthProviderType.GOOGLE, info.getSubject())
                .flatMap(link -> userRepository.findByIdAndDeletedAtIsNull(link.getUserId()))
                .orElseGet(() -> linkOrCreateGoogleUser(info));
        ensureCanSignIn(user);
        return issueTokens(user, request.getDeviceId(), userAgent);
    }

    @Transactional(noRollbackFor = BusinessException.class)
    public AuthResponse refresh(RefreshTokenRequest request, String userAgent) {
        IssuedRefreshToken next = refreshTokenService.rotate(request.getRefreshToken(), request.getDeviceId(), userAgent);
        User user = userRepository.findByIdAndDeletedAtIsNull(next.getUserId())
                .orElseThrow(() -> new BusinessException(ErrorCode.INVALID_TOKEN));
        if (user.getStatus() == UserStatus.LOCKED) {
            refreshTokenService.revokeAll(user.getId());
            throw new BusinessException(ErrorCode.ACCOUNT_LOCKED);
        }
        return buildResponse(user, next);
    }

    @Transactional
    public void logout(String refreshToken) {
        refreshTokenService.revoke(refreshToken);
    }

    /**
     * Đổi mật khẩu thì thu hồi mọi phiên (kể cả thiết bị khác) và phát cặp token mới cho thiết bị hiện tại.
     * Tài khoản chỉ đăng nhập Google (chưa có mật khẩu) được đặt mật khẩu mà không cần mật khẩu cũ.
     */
    @Transactional(noRollbackFor = BusinessException.class)
    public AuthResponse changePassword(UUID userId, ChangePasswordRequest request, String userAgent) {
        User user = userService.getActiveUser(userId);
        if (user.getPasswordHash() != null && (request.getCurrentPassword() == null
                || !passwordEncoder.matches(request.getCurrentPassword(), user.getPasswordHash()))) {
            throw new BusinessException(ErrorCode.WRONG_PASSWORD);
        }
        if (authProperties.isRequireEmailVerification()) {
            otpService.verify(user, OtpPurpose.CHANGE_PASSWORD, request.getOtp());
        }
        user.setPasswordHash(passwordEncoder.encode(request.getNewPassword()));
        refreshTokenService.revokeAll(userId);
        return issueTokens(user, request.getDeviceId(), userAgent);
    }

    private User linkOrCreateGoogleUser(GoogleUserInfo info) {
        String email = Emails.normalize(info.getEmail());
        User user = userRepository.findByEmailAndDeletedAtIsNull(email).orElseGet(() -> {
            String name = StringUtils.hasText(info.getName()) ? info.getName() : email.substring(0, email.indexOf('@'));
            return userService.createUser(email, name, null, UserRole.USER, true, info.getPictureUrl());
        });
        if (user.getEmailVerifiedAt() == null) {
            user.setEmailVerifiedAt(Instant.now());
        }
        if (user.getStatus() == UserStatus.PENDING_VERIFY) {
            user.setStatus(UserStatus.ACTIVE);
        }

        UserAuthProvider link = new UserAuthProvider();
        link.setUserId(user.getId());
        link.setProvider(AuthProviderType.GOOGLE);
        link.setProviderUserId(info.getSubject());
        link.setProviderEmail(email);
        authProviderRepository.save(link);
        log.info("Liên kết Google cho user {}", user.getId());
        return user;
    }

    private void ensureCanSignIn(User user) {
        if (user.getStatus() == UserStatus.LOCKED) {
            throw new BusinessException(ErrorCode.ACCOUNT_LOCKED);
        }
    }

    private AuthResponse issueTokens(User user, String deviceId, String userAgent) {
        return buildResponse(user, refreshTokenService.issue(user.getId(), deviceId, userAgent));
    }

    private AuthResponse buildResponse(User user, IssuedRefreshToken refreshToken) {
        return AuthResponse.builder()
                .user(UserResponse.from(user))
                .accessToken(jwtService.generateAccessToken(user))
                .refreshToken(refreshToken.getRawToken())
                .tokenType("Bearer")
                .expiresIn((long) jwtService.getAccessTokenTtlSeconds())
                .refreshTokenExpiresAt(refreshToken.getExpiresAt())
                .build();
    }
}
