package com.flash.common;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.Instant;
import java.util.List;

/**
 * Envelope chung cho mọi response (DATA_ARCHITECTURE.md §6.1).
 */
@Getter
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ApiResponse<T> {

    private final boolean success;
    private final String code;
    private final String message;
    private final T data;
    private final List<FieldError> errors;
    private final Instant timestamp;

    public static <T> ApiResponse<T> ok(T data) {
        return new ApiResponse<>(true, "OK", "Thành công", data, null, Instant.now());
    }

    public static <T> ApiResponse<T> ok(T data, String message) {
        return new ApiResponse<>(true, "OK", message, data, null, Instant.now());
    }

    public static ApiResponse<Void> error(ErrorCode errorCode, String message, List<FieldError> errors) {
        return new ApiResponse<>(false, errorCode.name(), message, null, errors, Instant.now());
    }

    /** Lỗi kèm dữ liệu, VD: 409 VERSION_CONFLICT trả về bản ghi hiện tại trên server. */
    public static <T> ApiResponse<T> error(ErrorCode errorCode, String message, T data) {
        return new ApiResponse<>(false, errorCode.name(), message, data, null, Instant.now());
    }

    @Getter
    @AllArgsConstructor
    public static class FieldError {
        private final String field;
        private final String message;
    }
}
