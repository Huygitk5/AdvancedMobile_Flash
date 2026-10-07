package com.flash.user.dto;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class DeleteAccountRequest {

    /** Bắt buộc nếu tài khoản có mật khẩu. */
    private String password;
}
