package com.flash.admin;

import com.fasterxml.jackson.databind.JsonNode;
import com.flash.support.IntegrationTestBase;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.web.servlet.MvcResult;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

class AdminOverviewIntegrationTest extends IntegrationTestBase {

    @Autowired
    private JdbcTemplate jdbc;

    /** Tài khoản ADMIN không được tính vào "học viên" của màn Tổng quan. */
    @Test
    void overviewCountsOnlyStudentsAsStudents() throws Exception {
        JsonNode admin = registerAdmin();
        register(uniqueEmail());
        register(uniqueEmail());

        MvcResult result = mockMvc.perform(get("/v1/admin/overview").header("Authorization", bearer(admin)))
                .andExpect(status().isOk())
                .andReturn();
        JsonNode data = body(result).get("data");

        Long students = jdbc.queryForObject("SELECT COUNT(*) FROM users WHERE role = 'USER' AND deleted_at IS NULL", Long.class);
        Long admins = jdbc.queryForObject("SELECT COUNT(*) FROM users WHERE role = 'ADMIN' AND deleted_at IS NULL", Long.class);
        assertThat(data.get("students").asLong()).isEqualTo(students);
        assertThat(data.get("admins").asLong()).isEqualTo(admins).isPositive();
        assertThat(data.get("topics").asLong()).isEqualTo(5);
        assertThat(data.get("flashcards").asLong()).isEqualTo(2);
        assertThat(data.get("recentStudents").size()).isBetween(1, 5);
        for (JsonNode recent : data.get("recentStudents")) {
            String role = jdbc.queryForObject("SELECT role FROM users WHERE id = ?", String.class, recent.get("id").asText());
            assertThat(role).isEqualTo("USER");
        }
    }

    @Test
    void userListCanBeFilteredByRole() throws Exception {
        JsonNode admin = registerAdmin();
        register(uniqueEmail());

        JsonNode students = body(mockMvc.perform(get("/v1/users?role=USER&size=100").header("Authorization", bearer(admin)))
                .andExpect(status().isOk()).andReturn()).at("/data/items");
        assertThat(students).isNotEmpty();
        students.forEach(u -> assertThat(u.get("role").asText()).isEqualTo("USER"));

        JsonNode admins = body(mockMvc.perform(get("/v1/users?role=ADMIN&size=100").header("Authorization", bearer(admin)))
                .andExpect(status().isOk()).andReturn()).at("/data/items");
        assertThat(admins).isNotEmpty();
        admins.forEach(u -> assertThat(u.get("role").asText()).isEqualTo("ADMIN"));
    }

    @Test
    void overviewIsForAdminsOnly() throws Exception {
        JsonNode user = register(uniqueEmail());
        mockMvc.perform(get("/v1/admin/overview").header("Authorization", bearer(user)))
                .andExpect(status().isForbidden());
    }
}
