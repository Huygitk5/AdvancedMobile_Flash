package com.flash.user.dto;

import com.flash.common.enums.CefrLevel;
import com.flash.user.entity.UserRole;
import com.flash.user.entity.UserStatus;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import javax.validation.constraints.Size;

/** Cập nhật từng phần: field null = giữ nguyên. */
@Getter
@Setter
@NoArgsConstructor
public class AdminUpdateUserRequest {

    @Size(min = 1, max = 100)
    private String fullName;

    private CefrLevel level;

    private UserRole role;

    /** LOCKED sẽ thu hồi mọi phiên đăng nhập của user. */
    private UserStatus status;
}
