package com.flash.sync.dto;

/** Kết quả xử lý một op trong /v1/sync/push (DATA_ARCHITECTURE.md §6.11). */
public enum SyncOpStatus {
    /** Đã áp dụng; client ghi đè local bằng data trả về và xoá op khỏi hàng đợi. */
    APPLIED,
    /** opId đã được xử lý trước đó; data là kết quả đã lưu của lần đầu. */
    DUPLICATE,
    /** Bản server mới hơn được giữ (LWW); client ghi đè local bằng data trả về. */
    CONFLICT_SERVER_WINS,
    /** Sai nghiệp vụ / dữ liệu: client xoá op (chuyển dead) và rollback trạng thái lạc quan. */
    REJECTED,
    /**
     * Lỗi tạm thời phía server, op chưa được ghi nhận: client giữ op và gửi lại sau (backoff).
     * Các op đứng sau op lỗi trong cùng lô cũng nhận FAILED để giữ đúng thứ tự FIFO.
     */
    FAILED
}
