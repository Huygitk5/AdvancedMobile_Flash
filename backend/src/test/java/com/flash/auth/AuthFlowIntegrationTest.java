package com.flash.auth;

import com.fasterxml.jackson.databind.JsonNode;
import com.flash.auth.google.GoogleTokenVerifier;
import com.flash.auth.google.GoogleUserInfo;
import com.flash.auth.mail.OtpSender;
import com.flash.support.IntegrationTestBase;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.web.servlet.MvcResult;

import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

class AuthFlowIntegrationTest extends IntegrationTestBase {

    @MockBean
    private OtpSender otpSender;

    @MockBean
    private GoogleTokenVerifier googleTokenVerifier;

    @Test
    void registerLoginAndMe() throws Exception {
        String email = uniqueEmail();
        JsonNode auth = register(email.toUpperCase());

        assertThat(auth.get("tokenType").asText()).isEqualTo("Bearer");
        assertThat(auth.get("expiresIn").asLong()).isEqualTo(900);
        assertThat(auth.at("/user/email").asText()).isEqualTo(email);
        assertThat(auth.at("/user/slogan").asText()).isEqualTo("Học, học nữa, học mãi!");

        postJson("/v1/auth/register", Map.of("fullName", "Dup", "email", email, "password", PASSWORD))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("EMAIL_ALREADY_EXISTS"));

        postJson("/v1/auth/login", Map.of("email", email, "password", "wrong-password"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("INVALID_CREDENTIALS"));

        MvcResult login = postJson("/v1/auth/login", Map.of("email", email, "password", PASSWORD))
                .andExpect(status().isOk())
                .andReturn();

        mockMvc.perform(get("/v1/users/me").header("Authorization", bearer(body(login).get("data"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.email").value(email))
                .andExpect(jsonPath("$.data.currentXp").value(0))
                .andExpect(jsonPath("$.data.version").value(0));
    }

    @Test
    void protectedEndpointsRequireValidToken() throws Exception {
        mockMvc.perform(get("/v1/users/me"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("UNAUTHORIZED"));
        mockMvc.perform(get("/v1/users/me").header("Authorization", "Bearer not-a-jwt"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void validationErrorsAreReportedPerField() throws Exception {
        postJson("/v1/auth/register", Map.of("fullName", "", "email", "not-an-email", "password", "123"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_ERROR"))
                .andExpect(jsonPath("$.errors.length()").value(3));
    }

    @Test
    void refreshTokenRotationAndReuseDetection() throws Exception {
        JsonNode auth = register(uniqueEmail());
        String r1 = auth.get("refreshToken").asText();

        String r2 = refresh(r1).get("refreshToken").asText();
        String r3 = refresh(r2).get("refreshToken").asText();
        assertThat(r2).isNotEqualTo(r1);
        assertThat(r3).isNotEqualTo(r2);

        // Dùng lại r1 (đã bị thay thế) => nghi bị đánh cắp => thu hồi toàn bộ phiên, kể cả r3
        postJson("/v1/auth/refresh-token", Map.of("refreshToken", r1))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("INVALID_TOKEN"));
        postJson("/v1/auth/refresh-token", Map.of("refreshToken", r3))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void logoutRevokesRefreshToken() throws Exception {
        String refreshToken = register(uniqueEmail()).get("refreshToken").asText();

        postJson("/v1/auth/logout", Map.of("refreshToken", refreshToken)).andExpect(status().isNoContent());
        postJson("/v1/auth/refresh-token", Map.of("refreshToken", refreshToken))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void passwordResetWithOtp() throws Exception {
        String email = uniqueEmail();
        String oldRefresh = register(email).get("refreshToken").asText();

        postJson("/v1/auth/forgot-password", Map.of("email", email)).andExpect(status().isOk());
        String otp = captureOtp(email);
        String wrongOtp = otp.equals("000000") ? "111111" : "000000";

        postJson("/v1/auth/reset-password", Map.of("email", email, "otp", wrongOtp, "newPassword", "NewPassword@1"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("INVALID_OTP"));
        postJson("/v1/auth/reset-password", Map.of("email", email, "otp", otp, "newPassword", "NewPassword@1"))
                .andExpect(status().isOk());

        // OTP chỉ dùng được 1 lần
        postJson("/v1/auth/reset-password", Map.of("email", email, "otp", otp, "newPassword", "Another@123"))
                .andExpect(status().isBadRequest());
        postJson("/v1/auth/login", Map.of("email", email, "password", PASSWORD))
                .andExpect(status().isUnauthorized());
        postJson("/v1/auth/login", Map.of("email", email, "password", "NewPassword@1"))
                .andExpect(status().isOk());
        // Đặt lại mật khẩu thu hồi mọi phiên cũ
        postJson("/v1/auth/refresh-token", Map.of("refreshToken", oldRefresh))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void otpIsLockedAfterMaxAttempts() throws Exception {
        String email = uniqueEmail();
        register(email);
        postJson("/v1/auth/forgot-password", Map.of("email", email)).andExpect(status().isOk());
        String otp = captureOtp(email);
        String wrongOtp = otp.equals("000000") ? "111111" : "000000";

        for (int i = 0; i < 5; i++) {
            postJson("/v1/auth/reset-password", Map.of("email", email, "otp", wrongOtp, "newPassword", "NewPassword@1"))
                    .andExpect(status().isBadRequest());
        }
        // Lần thứ 6, kể cả đúng OTP, vẫn bị chặn
        postJson("/v1/auth/reset-password", Map.of("email", email, "otp", otp, "newPassword", "NewPassword@1"))
                .andExpect(status().isTooManyRequests());
    }

    @Test
    void forgotPasswordDoesNotRevealUnknownEmail() throws Exception {
        postJson("/v1/auth/forgot-password", Map.of("email", uniqueEmail()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));
    }

    @Test
    void googleLoginCreatesUserOnceThenReusesIt() throws Exception {
        String email = uniqueEmail();
        when(googleTokenVerifier.verify("google-id-token"))
                .thenReturn(new GoogleUserInfo("google-sub-" + email, email, true, "Google User", null));

        JsonNode first = body(postJson("/v1/auth/google", Map.of("idToken", "google-id-token"))
                .andExpect(status().isOk()).andReturn()).get("data");
        JsonNode second = body(postJson("/v1/auth/google", Map.of("idToken", "google-id-token"))
                .andExpect(status().isOk()).andReturn()).get("data");

        assertThat(second.at("/user/id").asText()).isEqualTo(first.at("/user/id").asText());
        assertThat(first.at("/user/emailVerified").asBoolean()).isTrue();
        assertThat(first.at("/user/hasPassword").asBoolean()).isFalse();
    }

    @Test
    void googleLoginLinksExistingPasswordAccountWithSameEmail() throws Exception {
        String email = uniqueEmail();
        String userId = register(email).at("/user/id").asText();
        when(googleTokenVerifier.verify("token-for-existing"))
                .thenReturn(new GoogleUserInfo("sub-existing-" + email, email, true, "Same Person", null));

        postJson("/v1/auth/google", Map.of("idToken", "token-for-existing"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.user.id").value(userId))
                .andExpect(jsonPath("$.data.user.hasPassword").value(true));
    }

    private JsonNode refresh(String refreshToken) throws Exception {
        MvcResult result = postJson("/v1/auth/refresh-token", Map.of("refreshToken", refreshToken))
                .andExpect(status().isOk())
                .andReturn();
        return body(result).get("data");
    }

    private String captureOtp(String email) {
        ArgumentCaptor<String> otp = ArgumentCaptor.forClass(String.class);
        verify(otpSender).sendPasswordResetOtp(eq(email), anyString(), otp.capture());
        return otp.getValue();
    }
}
