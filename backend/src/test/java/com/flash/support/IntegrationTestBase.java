package com.flash.support;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.flash.user.entity.User;
import com.flash.user.entity.UserRole;
import com.flash.user.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.test.web.servlet.ResultActions;
import org.testcontainers.containers.MySQLContainer;

import java.nio.charset.StandardCharsets;
import java.util.Map;
import java.util.TimeZone;
import java.util.UUID;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Chạy với MySQL 8 thật (Testcontainers): Flyway V1/V2 + Hibernate validate được kiểm tra mỗi lần test.
 * Một container dùng chung cho mọi test class (singleton), nên mỗi test tự tạo email riêng.
 */
@SpringBootTest
@AutoConfigureMockMvc
public abstract class IntegrationTestBase {

    protected static final String PASSWORD = "Password@123";

    private static final MySQLContainer<?> MYSQL = new MySQLContainer<>("mysql:8.0")
            .withDatabaseName("flash_db")
            .withUsername("flash")
            .withPassword("flash")
            .withUrlParam("serverTimezone", "UTC")
            .withUrlParam("characterEncoding", "utf8")
            .withCommand("--character-set-server=utf8mb4", "--collation-server=utf8mb4_0900_ai_ci",
                    "--default-time-zone=+00:00", "--innodb_ft_min_token_size=2");

    static {
        // Giống FlashApplication.main: JVM chạy ở UTC
        TimeZone.setDefault(TimeZone.getTimeZone("UTC"));
        MYSQL.start();
    }

    @DynamicPropertySource
    static void datasource(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", MYSQL::getJdbcUrl);
        registry.add("spring.datasource.username", MYSQL::getUsername);
        registry.add("spring.datasource.password", MYSQL::getPassword);
        // MockMvc luôn gọi từ cùng 1 IP: nới rate limit để các test không chặn lẫn nhau
        registry.add("app.auth.rate-limit-per-minute", () -> 10_000);
    }

    @Autowired
    protected MockMvc mockMvc;

    @Autowired
    protected ObjectMapper objectMapper;

    @Autowired
    protected UserRepository userRepository;

    protected static String uniqueEmail() {
        return "user-" + UUID.randomUUID().toString().substring(0, 8) + "@test.local";
    }

    protected String json(Object body) throws Exception {
        return objectMapper.writeValueAsString(body);
    }

    protected JsonNode body(MvcResult result) throws Exception {
        return objectMapper.readTree(result.getResponse().getContentAsString(StandardCharsets.UTF_8));
    }

    protected ResultActions postJson(String url, Object body) throws Exception {
        return mockMvc.perform(post(url).contentType(MediaType.APPLICATION_JSON).content(json(body)));
    }

    /** Đăng ký user mới, trả về data của AuthResponse. */
    protected JsonNode register(String email) throws Exception {
        MvcResult result = postJson("/v1/auth/register",
                Map.of("fullName", "Test User", "email", email, "password", PASSWORD, "deviceId", "device-1"))
                .andExpect(status().isCreated())
                .andReturn();
        return body(result).get("data");
    }

    protected static String bearer(JsonNode auth) {
        return "Bearer " + auth.get("accessToken").asText();
    }

    /** Đăng ký user thường, nâng quyền ADMIN trực tiếp trong DB, rồi đăng nhập lại để JWT mang role mới. */
    protected JsonNode registerAdmin() throws Exception {
        String email = uniqueEmail();
        String id = register(email).at("/user/id").asText();
        User user = userRepository.findById(UUID.fromString(id)).orElseThrow();
        user.setRole(UserRole.ADMIN);
        userRepository.save(user);
        MvcResult login = postJson("/v1/auth/login", Map.of("email", email, "password", PASSWORD))
                .andExpect(status().isOk())
                .andReturn();
        return body(login).get("data");
    }
}
