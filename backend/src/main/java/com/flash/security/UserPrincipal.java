package com.flash.security;

import com.flash.user.entity.UserRole;
import lombok.AllArgsConstructor;
import lombok.Getter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;

import java.util.Collection;
import java.util.List;
import java.util.UUID;

/** Người dùng đã xác thực, dựng từ claim của access token (không truy vấn DB mỗi request). */
@Getter
@AllArgsConstructor
public class UserPrincipal {

    private final UUID id;
    private final String email;
    private final UserRole role;

    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of(new SimpleGrantedAuthority("ROLE_" + role.name()));
    }
}
