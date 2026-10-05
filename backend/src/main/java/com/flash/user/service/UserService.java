package com.flash.user.service;

import com.flash.auth.repository.UserAuthProviderRepository;
import com.flash.auth.service.RefreshTokenService;
import com.flash.common.BusinessException;
import com.flash.common.ErrorCode;
import com.flash.common.enums.CefrLevel;
import com.flash.common.enums.Resolution;
import com.flash.common.util.Emails;
import com.flash.user.dto.AdminCreateUserRequest;
import com.flash.user.dto.AdminUpdateUserRequest;
import com.flash.user.dto.ProfileUpdateResult;
import com.flash.user.dto.PublicUserResponse;
import com.flash.user.dto.UpdateProfileRequest;
import com.flash.user.dto.UserResponse;
import com.flash.user.entity.User;
import com.flash.user.entity.UserRole;
import com.flash.user.entity.UserSettings;
import com.flash.user.entity.UserStatus;
import com.flash.user.repository.UserRepository;
import com.flash.user.repository.UserSettingsRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.Instant;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class UserService {

    private static final String DELETED_NAME = "Người dùng đã xoá";

    private final UserRepository userRepository;
    private final UserSettingsRepository settingsRepository;
    private final UserAuthProviderRepository authProviderRepository;
    private final RefreshTokenService refreshTokenService;
    private final PasswordEncoder passwordEncoder;

    /** Tạo user kèm dòng user_settings mặc định. passwordHash null = tài khoản chỉ dùng Google. */
    @Transactional
    public User createUser(String rawEmail, String fullName, String passwordHash, UserRole role,
                           boolean emailVerified, String avatarUrl) {
        String email = Emails.normalize(rawEmail);
        if (userRepository.existsByEmail(email)) {
            throw new BusinessException(ErrorCode.EMAIL_ALREADY_EXISTS);
        }
        User user = new User();
        user.setEmail(email);
        user.setFullName(fullName.trim());
        user.setPasswordHash(passwordHash);
        user.setRole(role);
        user.setStatus(UserStatus.ACTIVE);
        user.setAvatarUrl(avatarUrl);
        user.setEmailVerifiedAt(emailVerified ? Instant.now() : null);
        userRepository.save(user);

        UserSettings settings = new UserSettings();
        settings.setUserId(user.getId());
        settingsRepository.save(settings);
        return user;
    }

    @Transactional(readOnly = true)
    public User getActiveUser(UUID id) {
        return userRepository.findByIdAndDeletedAtIsNull(id)
                .orElseThrow(() -> new BusinessException(ErrorCode.NOT_FOUND, "Không tìm thấy người dùng"));
    }

    /**
     * Khoá dòng user (SELECT ... FOR UPDATE) cho các thao tác đổi XP / streak / thống kê / nhiệm vụ,
     * để các request song song của cùng một user chạy tuần tự.
     */
    @Transactional(propagation = Propagation.MANDATORY)
    public User lockActiveUser(UUID id) {
        return userRepository.findActiveForUpdate(id)
                .orElseThrow(() -> new BusinessException(ErrorCode.NOT_FOUND, "Không tìm thấy người dùng"));
    }

    @Transactional(readOnly = true)
    public UserResponse getMe(UUID id) {
        return UserResponse.from(getActiveUser(id));
    }

    @Transactional(readOnly = true)
    public PublicUserResponse getPublicProfile(UUID id) {
        return PublicUserResponse.from(getActiveUser(id));
    }

    /**
     * Áp dụng khi baseVersion khớp, hoặc khi lệch nhưng clientUpdatedAt mới hơn lần sửa trước
     * (Last-Write-Wins, DATA_ARCHITECTURE.md §5.3). Còn lại trả 409 kèm bản hiện tại trên server.
     * version của users còn tăng khi server cộng XP, nên chỉ so version thì client sẽ hay bị 409.
     */
    @Transactional
    public UserResponse updateProfile(UUID id, UpdateProfileRequest request) {
        ProfileUpdateResult result = updateProfileIfNewer(id, request);
        if (result.getResolution() == Resolution.CONFLICT_SERVER_WINS) {
            throw new BusinessException(ErrorCode.VERSION_CONFLICT,
                    "Hồ sơ đã được cập nhật từ thiết bị khác", result.getUser());
        }
        return result.getUser();
    }

    /** Như {@link #updateProfile} nhưng trả CONFLICT_SERVER_WINS thay vì ném 409 (dùng cho /v1/sync/push). */
    @Transactional
    public ProfileUpdateResult updateProfileIfNewer(UUID id, UpdateProfileRequest request) {
        User user = getActiveUser(id);
        boolean versionMatches = request.getBaseVersion().equals(user.getVersion());
        boolean clientIsNewer = request.getClientUpdatedAt() != null
                && (user.getClientUpdatedAt() == null || request.getClientUpdatedAt().isAfter(user.getClientUpdatedAt()));
        if (!versionMatches && !clientIsNewer) {
            return new ProfileUpdateResult(UserResponse.from(user), Resolution.CONFLICT_SERVER_WINS);
        }

        if (request.getFullName() != null) {
            user.setFullName(request.getFullName().trim());
        }
        if (request.getSlogan() != null) {
            user.setSlogan(request.getSlogan().trim());
        }
        if (request.getLevel() != null) {
            user.setLevel(request.getLevel());
        }
        if (request.getAvatarUrl() != null) {
            user.setAvatarUrl(StringUtils.hasText(request.getAvatarUrl()) ? request.getAvatarUrl().trim() : null);
        }
        user.setClientUpdatedAt(request.getClientUpdatedAt() != null ? request.getClientUpdatedAt() : Instant.now());
        userRepository.saveAndFlush(user);
        return new ProfileUpdateResult(UserResponse.from(user), Resolution.APPLIED);
    }

    @Transactional
    public void deleteOwnAccount(UUID id, String password) {
        User user = getActiveUser(id);
        if (user.getPasswordHash() != null
                && (password == null || !passwordEncoder.matches(password, user.getPasswordHash()))) {
            throw new BusinessException(ErrorCode.WRONG_PASSWORD);
        }
        softDelete(user);
    }

    // ------------------------------------------------------------------ admin

    @Transactional(readOnly = true)
    public Page<UserResponse> search(String keyword, UserStatus status, UserRole role, Pageable pageable) {
        String normalizedKeyword = StringUtils.hasText(keyword) ? keyword.trim() : null;
        return userRepository.search(normalizedKeyword, status, role, pageable).map(UserResponse::from);
    }

    @Transactional
    public UserResponse adminCreate(AdminCreateUserRequest request) {
        User user = createUser(request.getEmail(), request.getFullName(),
                passwordEncoder.encode(request.getPassword()), request.getRole(), true, null);
        user.setLevel(request.getLevel() != null ? request.getLevel() : CefrLevel.A1);
        return UserResponse.from(user);
    }

    @Transactional
    public UserResponse adminUpdate(UUID adminId, UUID id, AdminUpdateUserRequest request) {
        User user = getActiveUser(id);
        boolean demotingSelf = request.getRole() != null && request.getRole() != UserRole.ADMIN;
        boolean lockingSelf = request.getStatus() == UserStatus.LOCKED;
        if (adminId.equals(id) && (demotingSelf || lockingSelf)) {
            throw new BusinessException(ErrorCode.BUSINESS_RULE_VIOLATION, "Không thể tự khoá hoặc tự hạ quyền của chính mình");
        }

        if (request.getFullName() != null) {
            user.setFullName(request.getFullName().trim());
        }
        if (request.getLevel() != null) {
            user.setLevel(request.getLevel());
        }
        if (request.getRole() != null) {
            user.setRole(request.getRole());
        }
        if (request.getStatus() != null && request.getStatus() != user.getStatus()) {
            user.setStatus(request.getStatus());
            if (request.getStatus() == UserStatus.LOCKED) {
                refreshTokenService.revokeAll(id);
            }
        }
        userRepository.saveAndFlush(user);
        return UserResponse.from(user);
    }

    @Transactional
    public void adminDelete(UUID adminId, UUID id) {
        if (adminId.equals(id)) {
            throw new BusinessException(ErrorCode.BUSINESS_RULE_VIOLATION, "Không thể tự xoá tài khoản admin đang dùng");
        }
        softDelete(getActiveUser(id));
    }

    /**
     * Soft delete + ẩn danh hoá: giữ lại dòng để không vỡ FK/lịch sử,
     * giải phóng email và liên kết Google để có thể đăng ký lại.
     */
    private void softDelete(User user) {
        user.setDeletedAt(Instant.now());
        user.setEmail("deleted+" + user.getId() + "@deleted.local");
        user.setFullName(DELETED_NAME);
        user.setPasswordHash(null);
        user.setAvatarUrl(null);
        authProviderRepository.deleteByUserId(user.getId());
        refreshTokenService.revokeAll(user.getId());
        log.info("Đã xoá (soft) user {}", user.getId());
    }
}
