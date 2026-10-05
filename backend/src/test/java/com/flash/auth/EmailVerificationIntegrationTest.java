package com.flash.auth;

import com.fasterxml.jackson.databind.JsonNode;
import com.flash.auth.entity.OtpPurpose;
import com.flash.auth.mail.OtpSender;
import com.flash.support.IntegrationTestBase;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.web.servlet.MvcResult;

import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.atLeastOnce;
import static org.mockito.Mockito.verify;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/** Bật xác thực email: đăng ký và đổi mật khẩu phải có OTP gửi qua email. */
@SpringBootTest(properties = "app.auth.require-email-verification=true")
class EmailVerificationIntegrationTest extends IntegrationTestBase {

    @MockBean
    private OtpSender otpSender;

    @Autowired
    private JdbcTemplate jdbc;

    @Test
    void registerRequiresEmailVerificationBeforeSignIn() throws Exception {
        String email = uniqueEmail();
        MvcResult registered = postJson("/v1/auth/register",
                Map.of("fullName", "New User", "email", email, "password", PASSWORD))
                .andExpect(status().isCreated())
                .andReturn();
        JsonNode data = body(registered).get("data");
        assertThat(data.get("verificationRequired").asBoolean()).isTrue();
        assertThat(data.has("accessToken")).isFalse();
        assertThat(data.at("/user/status").asText()).isEqualTo("PENDING_VERIFY");
        assertThat(jdbc.queryForObject("SELECT status FROM users WHERE email = ?", String.class, email))
                .isEqualTo("PENDING_VERIFY");

        // Chưa xác thực thì không đăng nhập được
        postJson("/v1/auth/login", Map.of("email", email, "password", PASSWORD))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.code").value("EMAIL_NOT_VERIFIED"));

        String otp = captureOtp(email, OtpPurpose.EMAIL_VERIFY);
        String wrong = otp.equals("000000") ? "111111" : "000000";
        postJson("/v1/auth/verify-email", Map.of("email", email, "otp", wrong))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("INVALID_OTP"));

        MvcResult verified = postJson("/v1/auth/verify-email", Map.of("email", email, "otp", otp, "deviceId", "d1"))
                .andExpect(status().isOk())
                .andReturn();
        JsonNode auth = body(verified).get("data");
        assertThat(auth.get("accessToken").asText()).isNotBlank();
        assertThat(auth.at("/user/status").asText()).isEqualTo("ACTIVE");
        assertThat(auth.at("/user/emailVerified").asBoolean()).isTrue();

        // OTP chỉ dùng một lần; tài khoản đã kích hoạt đăng nhập bình thường
        postJson("/v1/auth/verify-email", Map.of("email", email, "otp", otp)).andExpect(status().isBadRequest());
        postJson("/v1/auth/login", Map.of("email", email, "password", PASSWORD)).andExpect(status().isOk());
    }

    @Test
    void registeringAgainBeforeVerifyingReplacesPasswordAndKeepsOneAccount() throws Exception {
        String email = uniqueEmail();
        postJson("/v1/auth/register", Map.of("fullName", "First", "email", email, "password", PASSWORD))
                .andExpect(status().isCreated());
        postJson("/v1/auth/register", Map.of("fullName", "Second", "email", email, "password", "Another@123"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.data.verificationRequired").value(true));

        assertThat(jdbc.queryForObject("SELECT COUNT(*) FROM users WHERE email = ?", Integer.class, email)).isEqualTo(1);
        assertThat(jdbc.queryForObject("SELECT full_name FROM users WHERE email = ?", String.class, email)).isEqualTo("Second");

        String otp = captureOtp(email, OtpPurpose.EMAIL_VERIFY);
        postJson("/v1/auth/verify-email", Map.of("email", email, "otp", otp)).andExpect(status().isOk());
        postJson("/v1/auth/login", Map.of("email", email, "password", PASSWORD)).andExpect(status().isUnauthorized());
        postJson("/v1/auth/login", Map.of("email", email, "password", "Another@123")).andExpect(status().isOk());

        // Email đã kích hoạt thì không đăng ký lại được
        postJson("/v1/auth/register", Map.of("fullName", "Third", "email", email, "password", PASSWORD))
                .andExpect(status().isConflict());
    }

    @Test
    void verificationOtpIsLockedAfterTooManyWrongAttempts() throws Exception {
        String email = uniqueEmail();
        postJson("/v1/auth/register", Map.of("fullName", "Locked", "email", email, "password", PASSWORD))
                .andExpect(status().isCreated());
        String otp = captureOtp(email, OtpPurpose.EMAIL_VERIFY);
        String wrong = otp.equals("000000") ? "111111" : "000000";
        for (int i = 0; i < 5; i++) {
            postJson("/v1/auth/verify-email", Map.of("email", email, "otp", wrong)).andExpect(status().isBadRequest());
        }
        postJson("/v1/auth/verify-email", Map.of("email", email, "otp", otp)).andExpect(status().isTooManyRequests());
    }

    @Test
    void forgotPasswordIsIgnoredForUnverifiedAccounts() throws Exception {
        String email = uniqueEmail();
        postJson("/v1/auth/register", Map.of("fullName", "Pending", "email", email, "password", PASSWORD))
                .andExpect(status().isCreated());
        postJson("/v1/auth/forgot-password", Map.of("email", email)).andExpect(status().isOk());
        verify(otpSender, org.mockito.Mockito.never()).sendOtp(eq(email), anyString(), eq(OtpPurpose.PASSWORD_RESET), anyString());
    }

    @Test
    void changePasswordNeedsOtpFromEmail() throws Exception {
        String email = uniqueEmail();
        postJson("/v1/auth/register", Map.of("fullName", "Changer", "email", email, "password", PASSWORD))
                .andExpect(status().isCreated());
        String registerOtp = captureOtp(email, OtpPurpose.EMAIL_VERIFY);
        JsonNode auth = body(postJson("/v1/auth/verify-email", Map.of("email", email, "otp", registerOtp))
                .andExpect(status().isOk()).andReturn()).get("data");

        // Thiếu OTP hoặc OTP sai
        putAuth("/v1/users/change-password", auth, Map.of("currentPassword", PASSWORD, "newPassword", "Changed@123"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("INVALID_OTP"));

        mockMvc.perform(org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post("/v1/users/change-password/otp")
                        .header("Authorization", bearer(auth)))
                .andExpect(status().isOk());
        String otp = captureOtp(email, OtpPurpose.CHANGE_PASSWORD);

        // Sai mật khẩu cũ thì không dùng mất OTP
        putAuth("/v1/users/change-password", auth, Map.of("currentPassword", "wrong", "newPassword", "Changed@123", "otp", otp))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("WRONG_PASSWORD"));
        putAuth("/v1/users/change-password", auth, Map.of("currentPassword", PASSWORD, "newPassword", "Changed@123", "otp", otp))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.refreshToken").isNotEmpty());
        postJson("/v1/auth/login", Map.of("email", email, "password", "Changed@123")).andExpect(status().isOk());
    }

    private org.springframework.test.web.servlet.ResultActions putAuth(String url, JsonNode auth, Object body) throws Exception {
        return mockMvc.perform(put(url).header("Authorization", bearer(auth))
                .contentType(MediaType.APPLICATION_JSON).content(json(body)));
    }

    private String captureOtp(String email, OtpPurpose purpose) {
        ArgumentCaptor<String> otp = ArgumentCaptor.forClass(String.class);
        verify(otpSender, atLeastOnce()).sendOtp(eq(email), anyString(), eq(purpose), otp.capture());
        return otp.getValue();
    }
}
