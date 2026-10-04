package com.flash.user.dto;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Size;

@Getter
@Setter
@NoArgsConstructor
public class ChangePasswordRequest {

    /** Bắt buộc nếu tài khoản đã có mật khẩu; tài khoản chỉ dùng Google thì bỏ trống. */
    private String currentPassword;

    @NotBlank
    @Size(min = 8, max = 72)
    private String newPassword;

    @Size(max = 100)
    private String deviceId;
}
