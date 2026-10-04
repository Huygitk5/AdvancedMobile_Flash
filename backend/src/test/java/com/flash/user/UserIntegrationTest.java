package com.flash.user;

import com.fasterxml.jackson.databind.JsonNode;
import com.flash.support.IntegrationTestBase;
import com.flash.user.entity.User;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.ResultActions;

import java.time.Instant;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

class UserIntegrationTest extends IntegrationTestBase {

    @Test
    void updateProfileUsesVersionThenLastWriteWins() throws Exception {
        String token = bearer(register(uniqueEmail()));

        updateProfile(token, Map.of("slogan", "Slogan A", "baseVersion", 0))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.slogan").value("Slogan A"))
                .andExpect(jsonPath("$.data.version").value(1));

        // Thiết bị khác còn giữ version 0, không gửi clientUpdatedAt => xung đột, trả kèm bản server
        updateProfile(token, Map.of("slogan", "Slogan cũ", "baseVersion", 0))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("VERSION_CONFLICT"))
                .andExpect(jsonPath("$.data.slogan").value("Slogan A"));

        // Version lệch nhưng bản sửa mới hơn => Last-Write-Wins
        Map<String, Object> newer = new HashMap<>();
        newer.put("slogan", "Slogan B");
        newer.put("baseVersion", 0);
        newer.put("clientUpdatedAt", Instant.now().plusSeconds(5).toString());
        updateProfile(token, newer)
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.slogan").value("Slogan B"));
    }

    @Test
    void changePasswordRevokesOtherSessionsAndReturnsNewTokens() throws Exception {
        String email = uniqueEmail();
        JsonNode auth = register(email);
        String oldRefresh = auth.get("refreshToken").asText();

        mockMvc.perform(put("/v1/users/change-password").header("Authorization", bearer(auth))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json(Map.of("currentPassword", "wrong", "newPassword", "Changed@123"))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("WRONG_PASSWORD"));

        mockMvc.perform(put("/v1/users/change-password").header("Authorization", bearer(auth))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json(Map.of("currentPassword", PASSWORD, "newPassword", "Changed@123"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.refreshToken").isNotEmpty());

        postJson("/v1/auth/refresh-token", Map.of("refreshToken", oldRefresh)).andExpect(status().isUnauthorized());
        postJson("/v1/auth/login", Map.of("email", email, "password", "Changed@123")).andExpect(status().isOk());
    }

    @Test
    void settingsDefaultsAndPartialUpdate() throws Exception {
        String token = bearer(register(uniqueEmail()));

        mockMvc.perform(get("/v1/users/me/settings").header("Authorization", token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.isSoundEnabled").value(true))
                .andExpect(jsonPath("$.data.isDarkMode").value(false))
                .andExpect(jsonPath("$.data.appLanguage").value("vi"))
                .andExpect(jsonPath("$.data.dailyGoalLessons").value(5));

        mockMvc.perform(put("/v1/users/me/settings").header("Authorization", token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json(Map.of("isDarkMode", true, "dailyReminderTime", "20:30"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.isDarkMode").value(true))
                .andExpect(jsonPath("$.data.isSoundEnabled").value(true))
                .andExpect(jsonPath("$.data.dailyReminderTime").value("20:30"));
    }

    @Test
    void deleteAccountAnonymizesAndFreesEmail() throws Exception {
        String email = uniqueEmail();
        JsonNode auth = register(email);
        String userId = auth.at("/user/id").asText();

        mockMvc.perform(delete("/v1/users/delete").header("Authorization", bearer(auth))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json(Map.of("password", PASSWORD))))
                .andExpect(status().isNoContent());

        postJson("/v1/auth/login", Map.of("email", email, "password", PASSWORD)).andExpect(status().isUnauthorized());
        User deleted = userRepository.findById(UUID.fromString(userId)).orElseThrow();
        assertThat(deleted.getDeletedAt()).isNotNull();
        assertThat(deleted.getEmail()).startsWith("deleted+");
        // Email đã được giải phóng, đăng ký lại được
        register(email);
    }

    @Test
    void publicProfileHidesPrivateFields() throws Exception {
        JsonNode viewer = register(uniqueEmail());
        String targetId = register(uniqueEmail()).at("/user/id").asText();

        mockMvc.perform(get("/v1/users/get/" + targetId).header("Authorization", bearer(viewer)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.fullName").value("Test User"))
                .andExpect(jsonPath("$.data.email").doesNotExist())
                .andExpect(jsonPath("$.data.currentXp").doesNotExist());
    }

    @Test
    void adminEndpointsRequireAdminRole() throws Exception {
        String userToken = bearer(register(uniqueEmail()));
        mockMvc.perform(get("/v1/users").header("Authorization", userToken))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.code").value("FORBIDDEN"));

        String adminToken = bearer(registerAdmin());
        String targetEmail = uniqueEmail();
        JsonNode created = body(mockMvc.perform(post("/v1/users/create").header("Authorization", adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json(Map.of("fullName", "Created By Admin", "email", targetEmail,
                                "password", PASSWORD, "role", "USER", "level", "B1"))))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.data.level").value("B1"))
                .andReturn()).get("data");
        String targetId = created.get("id").asText();

        mockMvc.perform(get("/v1/users").param("keyword", targetEmail).header("Authorization", adminToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.totalElements").value(1))
                .andExpect(jsonPath("$.data.items[0].id").value(targetId));

        // Khoá user => không đăng nhập được
        mockMvc.perform(put("/v1/users/update/" + targetId).header("Authorization", adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json(Map.of("status", "LOCKED"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.status").value("LOCKED"));
        postJson("/v1/auth/login", Map.of("email", targetEmail, "password", PASSWORD))
                .andExpect(status().isLocked())
                .andExpect(jsonPath("$.code").value("ACCOUNT_LOCKED"));

        mockMvc.perform(delete("/v1/users/delete/" + targetId).header("Authorization", adminToken))
                .andExpect(status().isNoContent());
        mockMvc.perform(get("/v1/users/get/" + targetId).header("Authorization", adminToken))
                .andExpect(status().isNotFound());
    }

    private ResultActions updateProfile(String token, Map<String, Object> body)
            throws Exception {
        return mockMvc.perform(put("/v1/users/update").header("Authorization", token)
                .contentType(MediaType.APPLICATION_JSON)
                .content(json(body)));
    }
}
