package com.flash.common;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

/**
 * Mã lỗi nghiệp vụ -> HTTP status (DATA_ARCHITECTURE.md §6.1).
 */
@Getter
@RequiredArgsConstructor
public enum ErrorCode {
    // 400
    VALIDATION_ERROR(HttpStatus.BAD_REQUEST, "Dữ liệu không hợp lệ"),
    BAD_REQUEST(HttpStatus.BAD_REQUEST, "Yêu cầu không hợp lệ"),
    INVALID_OTP(HttpStatus.BAD_REQUEST, "Mã OTP không đúng hoặc đã hết hạn"),
    WRONG_PASSWORD(HttpStatus.BAD_REQUEST, "Mật khẩu hiện tại không đúng"),
    // 401
    UNAUTHORIZED(HttpStatus.UNAUTHORIZED, "Chưa đăng nhập hoặc phiên đã hết hạn"),
    INVALID_CREDENTIALS(HttpStatus.UNAUTHORIZED, "Email hoặc mật khẩu không đúng"),
    INVALID_TOKEN(HttpStatus.UNAUTHORIZED, "Token không hợp lệ"),
    // 403
    FORBIDDEN(HttpStatus.FORBIDDEN, "Không có quyền truy cập"),
    RANK_REQUIREMENT_NOT_MET(HttpStatus.FORBIDDEN, "Chưa đạt thứ hạng yêu cầu"),
    // 404
    NOT_FOUND(HttpStatus.NOT_FOUND, "Không tìm thấy dữ liệu"),
    // 409
    CONFLICT(HttpStatus.CONFLICT, "Dữ liệu bị xung đột"),
    EMAIL_ALREADY_EXISTS(HttpStatus.CONFLICT, "Email đã được sử dụng"),
    VERSION_CONFLICT(HttpStatus.CONFLICT, "Dữ liệu đã bị thay đổi ở nơi khác"),
    ALREADY_CLAIMED(HttpStatus.CONFLICT, "Phần thưởng đã được nhận"),
    ALREADY_OWNED(HttpStatus.CONFLICT, "Bạn đã sở hữu vật phẩm này"),
    INSUFFICIENT_XP(HttpStatus.CONFLICT, "Không đủ XP"),
    // 422
    QUEST_NOT_COMPLETED(HttpStatus.UNPROCESSABLE_ENTITY, "Nhiệm vụ chưa hoàn thành"),
    BUSINESS_RULE_VIOLATION(HttpStatus.UNPROCESSABLE_ENTITY, "Vi phạm quy tắc nghiệp vụ"),
    // 423, 429
    ACCOUNT_LOCKED(HttpStatus.LOCKED, "Tài khoản đã bị khoá"),
    TOO_MANY_REQUESTS(HttpStatus.TOO_MANY_REQUESTS, "Quá nhiều yêu cầu, vui lòng thử lại sau"),
    // 500
    INTERNAL_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "Lỗi hệ thống");

    private final HttpStatus status;
    private final String defaultMessage;
}
