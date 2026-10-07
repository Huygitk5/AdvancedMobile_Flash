package com.flash.sync.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.UUID;

@Getter
@AllArgsConstructor
public class SyncOpResult {

    private final UUID opId;
    private final SyncOpStatus status;

    /** Bản ghi chuẩn trên server sau khi xử lý (cùng shape với response của API REST tương ứng). */
    @Schema(type = "object")
    private final Object data;

    /** Chỉ có khi REJECTED / FAILED (hoặc DUPLICATE của một op đã bị từ chối). */
    private final String errorCode;
    private final String message;

    public static SyncOpResult of(UUID opId, SyncOpStatus status, Object data) {
        return new SyncOpResult(opId, status, data, null, null);
    }

    public static SyncOpResult error(UUID opId, SyncOpStatus status, String errorCode, String message) {
        return new SyncOpResult(opId, status, null, errorCode, message);
    }
}
