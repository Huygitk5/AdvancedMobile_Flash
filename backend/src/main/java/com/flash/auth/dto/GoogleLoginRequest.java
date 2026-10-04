package com.flash.auth.dto;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Size;

@Getter
@Setter
@NoArgsConstructor
public class GoogleLoginRequest {

    /** idToken lấy từ google_sign_in trên Flutter. */
    @NotBlank
    private String idToken;

    @Size(max = 100)
    private String deviceId;
}
