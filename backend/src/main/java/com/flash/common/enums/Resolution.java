package com.flash.common.enums;

/** Kết quả ghi dữ liệu Last-Write-Wins (ghi chú, bookmark, trang bị đồ) - DATA_ARCHITECTURE.md §5.3. */
public enum Resolution {
    /** Bản client được ghi. */
    APPLIED,
    /** Bản server mới hơn nên được giữ; client ghi đè local bằng bản server trả về. */
    CONFLICT_SERVER_WINS
}
