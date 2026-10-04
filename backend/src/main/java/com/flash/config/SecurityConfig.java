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
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.method.configuration.EnableGlobalMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

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

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
