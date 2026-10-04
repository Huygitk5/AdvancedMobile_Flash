package com.flash.user;

import com.flash.user.entity.UserRole;
import com.flash.user.repository.UserRepository;
import com.flash.user.service.UserService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

/**
 * Tạo tài khoản ADMIN đầu tiên từ biến môi trường ADMIN_EMAIL / ADMIN_PASSWORD (nếu có).
 * Email đã tồn tại thì bỏ qua, không đổi mật khẩu hay quyền của tài khoản đó.
 */
@Slf4j
@Component
public class AdminBootstrap implements ApplicationRunner {

    private final UserRepository userRepository;
    private final UserService userService;
    private final PasswordEncoder passwordEncoder;
    private final String email;
    private final String password;
    private final String fullName;

    public AdminBootstrap(UserRepository userRepository, UserService userService, PasswordEncoder passwordEncoder,
                          @Value("${app.bootstrap-admin.email:}") String email,
                          @Value("${app.bootstrap-admin.password:}") String password,
                          @Value("${app.bootstrap-admin.full-name:Administrator}") String fullName) {
        this.userRepository = userRepository;
        this.userService = userService;
        this.passwordEncoder = passwordEncoder;
        this.email = email;
        this.password = password;
        this.fullName = fullName;
    }

    @Override
    public void run(ApplicationArguments args) {
        if (!StringUtils.hasText(email) || !StringUtils.hasText(password)) {
            return;
        }
        if (userRepository.findByEmailAndDeletedAtIsNull(email.trim().toLowerCase()).isPresent()) {
            log.info("Admin bootstrap: {} đã tồn tại, bỏ qua", email);
            return;
        }
        userService.createUser(email, fullName, passwordEncoder.encode(password), UserRole.ADMIN, true, null);
        log.info("Admin bootstrap: đã tạo tài khoản ADMIN {}", email);
    }
}
