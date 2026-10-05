package com.flash.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.flash.auth.AuthProperties;
import com.flash.security.AuthRateLimitFilter;
import com.flash.security.JwtAuthFilter;
import com.flash.security.JwtService;
import com.flash.security.RestAccessDeniedHandler;
import com.flash.security.RestAuthenticationEntryPoint;
import com.flash.security.SyncRateLimitFilter;
import com.flash.sync.SyncProperties;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.method.configuration.EnableGlobalMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;
import java.util.List;

/**
 * Stateless REST security với JWT Bearer.
 * Các filter được tạo bằng new (không phải bean) để Spring Boot không tự đăng ký chúng
 * thêm một lần nữa vào servlet filter chain.
 */
@Configuration
@EnableGlobalMethodSecurity(prePostEnabled = true)
@RequiredArgsConstructor
public class SecurityConfig {

    private static final String[] PUBLIC_PATHS = {
            "/v1/health",
            "/v1/auth/**",
            "/swagger-ui.html",
            "/swagger-ui/**",
            "/v3/api-docs/**",
    };

    private final RestAuthenticationEntryPoint authenticationEntryPoint;
    private final RestAccessDeniedHandler accessDeniedHandler;
    private final JwtService jwtService;
    private final AuthProperties authProperties;
    private final SyncProperties syncProperties;
    private final ObjectMapper objectMapper;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .csrf().disable()
                .cors().and()
                .httpBasic().disable()
                .formLogin().disable()
                .logout().disable()
                .sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS).and()
                .exceptionHandling()
                    .authenticationEntryPoint(authenticationEntryPoint)
                    .accessDeniedHandler(accessDeniedHandler).and()
                .authorizeRequests()
                    .antMatchers(PUBLIC_PATHS).permitAll()
                    .anyRequest().authenticated().and()
                .addFilterBefore(new AuthRateLimitFilter(authProperties.getRateLimitPerMinute(), objectMapper),
                        UsernamePasswordAuthenticationFilter.class)
                .addFilterBefore(new JwtAuthFilter(jwtService), UsernamePasswordAuthenticationFilter.class)
                // Sau JwtAuthFilter để đếm theo user đã xác thực
                .addFilterAfter(new SyncRateLimitFilter(syncProperties.getRateLimitPerMinute(), objectMapper),
                        JwtAuthFilter.class);
        return http.build();
    }

    /**
     * CORS cho app Flutter Web và Swagger UI. API dùng Bearer token (không cookie) nên cho phép mọi origin là an toàn;
     * production có thể giới hạn bằng CORS_ALLOWED_ORIGINS=https://app.example.com,https://admin.example.com.
     */
    @Bean
    public CorsConfigurationSource corsConfigurationSource(
            @Value("${app.cors.allowed-origins:*}") String allowedOrigins) {
        List<String> origins = Arrays.asList(allowedOrigins.trim().split("\\s*,\\s*"));
        CorsConfiguration config = new CorsConfiguration();
        config.setAllowedOriginPatterns(origins);
        config.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        config.setAllowedHeaders(Arrays.asList("Authorization", "Content-Type", "Accept", "Accept-Language"));
        config.setMaxAge(3600L);
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return source;
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
