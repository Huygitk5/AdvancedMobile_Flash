package com.flash.user.controller;

import com.flash.auth.dto.AuthResponse;
import com.flash.auth.service.AuthService;
import com.flash.common.ApiResponse;
import com.flash.security.CurrentUser;
import com.flash.security.UserPrincipal;
import com.flash.user.dto.ChangePasswordRequest;
import com.flash.user.dto.DeleteAccountRequest;
import com.flash.user.dto.PublicUserResponse;
import com.flash.user.dto.UpdateProfileRequest;
import com.flash.user.dto.UpdateSettingsRequest;
import com.flash.user.dto.UserResponse;
import com.flash.user.dto.UserSettingsResponse;
import com.flash.user.service.UserService;
import com.flash.user.service.UserSettingsService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import javax.validation.Valid;
import java.util.UUID;

@Tag(name = "Users", description = "Hồ sơ, mật khẩu, cài đặt của người dùng hiện tại")
@RestController
@RequestMapping("/v1/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;
    private final UserSettingsService settingsService;
    private final AuthService authService;

    @Operation(summary = "Thông tin user hiện tại")
    @GetMapping("/me")
    public ApiResponse<UserResponse> me(@CurrentUser UserPrincipal me) {
        return ApiResponse.ok(userService.getMe(me.getId()));
    }

    @Operation(summary = "Hồ sơ công khai của một user (VD: bấm vào bảng xếp hạng)")
    @GetMapping("/get/{id}")
    public ApiResponse<PublicUserResponse> getById(@PathVariable UUID id) {
        return ApiResponse.ok(userService.getPublicProfile(id));
    }

    @Operation(summary = "Cập nhật hồ sơ (slogan, tên, level, avatar)",
            description = "409 VERSION_CONFLICT kèm bản server nếu version lệch và bản client không mới hơn")
    @PutMapping("/update")
    public ApiResponse<UserResponse> update(@CurrentUser UserPrincipal me,
                                            @Valid @RequestBody UpdateProfileRequest request) {
        return ApiResponse.ok(userService.updateProfile(me.getId(), request));
    }

    @Operation(summary = "Đổi mật khẩu",
            description = "Thu hồi mọi phiên đăng nhập khác, trả cặp token mới cho thiết bị hiện tại")
    @PutMapping("/change-password")
    public ApiResponse<AuthResponse> changePassword(@CurrentUser UserPrincipal me,
                                                    @Valid @RequestBody ChangePasswordRequest request,
                                                    @RequestHeader(value = HttpHeaders.USER_AGENT, required = false) String userAgent) {
        return ApiResponse.ok(authService.changePassword(me.getId(), request, userAgent), "Đổi mật khẩu thành công");
    }

    @Operation(summary = "Tự xoá tài khoản (soft delete, ẩn danh hoá email)")
    @DeleteMapping("/delete")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteMe(@CurrentUser UserPrincipal me,
                         @RequestBody(required = false) DeleteAccountRequest request) {
        userService.deleteOwnAccount(me.getId(), request != null ? request.getPassword() : null);
    }

    @Operation(summary = "Lấy cài đặt đã đồng bộ")
    @GetMapping("/me/settings")
    public ApiResponse<UserSettingsResponse> getSettings(@CurrentUser UserPrincipal me) {
        return ApiResponse.ok(settingsService.get(me.getId()));
    }

    @Operation(summary = "Lưu cài đặt (cập nhật từng phần)")
    @PutMapping("/me/settings")
    public ApiResponse<UserSettingsResponse> updateSettings(@CurrentUser UserPrincipal me,
                                                            @Valid @RequestBody UpdateSettingsRequest request) {
        return ApiResponse.ok(settingsService.update(me.getId(), request));
    }
}
