package com.flash.user.dto;

import com.flash.common.enums.CefrLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;
import java.time.Instant;

/** Cập nhật từng phần: field null = giữ nguyên. */
@Getter
@Setter
@NoArgsConstructor
public class UpdateProfileRequest {

    @Size(min = 1, max = 100)
    private String fullName;

    @Size(max = 255)
    private String slogan;

    private CefrLevel level;

    @Size(max = 500)
    private String avatarUrl;

    /** version của hồ sơ mà client đang dựa trên. */
    @NotNull
    private Integer baseVersion;

    /** Thời điểm user sửa trên thiết bị, dùng cho Last-Write-Wins khi version lệch. */
    private Instant clientUpdatedAt;
}
