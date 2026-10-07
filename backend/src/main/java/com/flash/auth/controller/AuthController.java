package com.flash.auth.controller;

import com.flash.auth.dto.AuthResponse;
import com.flash.auth.dto.ForgotPasswordRequest;
import com.flash.auth.dto.GoogleLoginRequest;
import com.flash.auth.dto.LoginRequest;
import com.flash.auth.dto.LogoutRequest;
import com.flash.auth.dto.RefreshTokenRequest;
import com.flash.auth.dto.RegisterRequest;
import com.flash.auth.dto.ResendVerificationRequest;
import com.flash.auth.dto.ResetPasswordRequest;
import com.flash.auth.dto.VerifyEmailRequest;
import com.flash.auth.service.AuthService;
import com.flash.auth.service.PasswordResetService;
import com.flash.common.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirements;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import javax.validation.Valid;

@Tag(name = "Auth", description = "Đăng ký, đăng nhập, token, quên mật khẩu")
@SecurityRequirements
@RestController
@RequestMapping("/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;
    private final PasswordResetService passwordResetService;

    @Operation(summary = "Đăng ký bằng email/mật khẩu",
            description = "Khi bật xác thực email: trả verificationRequired = true (chưa có token) và gửi OTP tới email, "
                    + "client gọi tiếp POST /v1/auth/verify-email")
    @PostMapping("/register")
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<AuthResponse> register(@Valid @RequestBody RegisterRequest request,
                                              @RequestHeader(value = HttpHeaders.USER_AGENT, required = false) String userAgent) {
        AuthResponse response = authService.register(request, userAgent);
        return ApiResponse.ok(response, response.isVerificationRequired()
                ? "Vui lòng nhập mã OTP đã gửi tới email để hoàn tất đăng ký" : "Đăng ký thành công");
    }

    @Operation(summary = "Xác thực email bằng OTP", description = "Đúng OTP thì kích hoạt tài khoản và đăng nhập luôn")
    @PostMapping("/verify-email")
    public ApiResponse<AuthResponse> verifyEmail(@Valid @RequestBody VerifyEmailRequest request,
                                                 @RequestHeader(value = HttpHeaders.USER_AGENT, required = false) String userAgent) {
        return ApiResponse.ok(authService.verifyEmail(request, userAgent), "Xác thực email thành công");
    }

    @Operation(summary = "Gửi lại OTP xác thực email", description = "Luôn trả 200 dù email có tồn tại hay không")
    @PostMapping("/resend-verification")
    public ApiResponse<Void> resendVerification(@Valid @RequestBody ResendVerificationRequest request) {
        authService.resendVerification(request.getEmail());
        return ApiResponse.ok(null, "Nếu email đang chờ xác thực, mã OTP mới sẽ được gửi tới hộp thư của bạn");
    }

    @Operation(summary = "Đăng nhập bằng email/mật khẩu")
    @PostMapping("/login")
    public ApiResponse<AuthResponse> login(@Valid @RequestBody LoginRequest request,
                                           @RequestHeader(value = HttpHeaders.USER_AGENT, required = false) String userAgent) {
        return ApiResponse.ok(authService.login(request, userAgent));
    }

    @Operation(summary = "Đăng nhập bằng Google (server xác minh idToken)")
    @PostMapping("/google")
    public ApiResponse<AuthResponse> google(@Valid @RequestBody GoogleLoginRequest request,
                                            @RequestHeader(value = HttpHeaders.USER_AGENT, required = false) String userAgent) {
        return ApiResponse.ok(authService.loginWithGoogle(request, userAgent));
    }

    @Operation(summary = "Gửi OTP đặt lại mật khẩu",
            description = "Luôn trả 200 dù email có tồn tại hay không")
    @PostMapping("/forgot-password")
    public ApiResponse<Void> forgotPassword(@Valid @RequestBody ForgotPasswordRequest request) {
        passwordResetService.requestReset(request.getEmail());
        return ApiResponse.ok(null, "Nếu email đã đăng ký, mã OTP sẽ được gửi tới hộp thư của bạn");
    }

    @Operation(summary = "Đặt lại mật khẩu bằng OTP")
    @PostMapping("/reset-password")
    public ApiResponse<Void> resetPassword(@Valid @RequestBody ResetPasswordRequest request) {
        passwordResetService.resetPassword(request.getEmail(), request.getOtp(), request.getNewPassword());
        return ApiResponse.ok(null, "Đặt lại mật khẩu thành công, vui lòng đăng nhập lại");
    }

    @Operation(summary = "Đổi refresh token lấy cặp token mới (rotation)")
    @PostMapping("/refresh-token")
    public ApiResponse<AuthResponse> refresh(@Valid @RequestBody RefreshTokenRequest request,
                                             @RequestHeader(value = HttpHeaders.USER_AGENT, required = false) String userAgent) {
        return ApiResponse.ok(authService.refresh(request, userAgent));
    }

    @Operation(summary = "Đăng xuất: thu hồi refresh token của thiết bị")
    @PostMapping("/logout")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void logout(@Valid @RequestBody LogoutRequest request) {
        authService.logout(request.getRefreshToken());
    }
}
