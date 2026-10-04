package com.flash.user.dto;

import com.flash.common.enums.Resolution;
import lombok.AllArgsConstructor;
import lombok.Getter;

/** Cài đặt cuối cùng trên server sau LWW + ai thắng. */
@Getter
@AllArgsConstructor
public class UserSettingsResult {

    private final UserSettingsResponse settings;
    private final Resolution resolution;
}
