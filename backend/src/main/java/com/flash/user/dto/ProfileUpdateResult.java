package com.flash.user.dto;

import com.flash.common.enums.Resolution;
import lombok.AllArgsConstructor;
import lombok.Getter;

/** Hồ sơ cuối cùng trên server sau LWW + ai thắng (op PROFILE_UPDATE khi sync). */
@Getter
@AllArgsConstructor
public class ProfileUpdateResult {

    private final UserResponse user;
    private final Resolution resolution;
}
