package com.flash.sync.service;

import lombok.Getter;

import java.time.Duration;
import java.time.Instant;

/**
 * Cửa sổ của một lần pull: đọc các dòng có updated_at &gt; since, tối đa {@code limit} dòng mỗi bảng.
 * <ul>
 *   <li>Hết dữ liệu: cursor = thời điểm bắt đầu truy vấn − 2 giây (chồng lấn nhỏ để không sót transaction
 *       commit chậm; client upsert theo khoá chính nên nhận trùng không sao).</li>
 *   <li>Có bảng vượt limit: hasMore = true, cursor dừng ngay trước dòng đầu tiên chưa trả về
 *       (lấy nhỏ nhất qua các bảng), lần pull sau đọc tiếp từ đó.</li>
 * </ul>
 */
@Getter
public class DeltaWindow {

    static final Duration OVERLAP = Duration.ofSeconds(2);

    private final Instant since;
    private final int limit;
    private final Instant queryStart;
    private boolean hasMore;
    private Instant nextCursor;

    public DeltaWindow(Instant since, int limit, Instant queryStart) {
        this.since = since;
        this.limit = limit;
        this.queryStart = queryStart;
    }

    /** Ghi nhận một bảng còn dữ liệu chưa trả: lần sau đọc từ các dòng có updated_at &gt; {@code resumeAfter}. */
    void truncatedAt(Instant resumeAfter) {
        hasMore = true;
        if (nextCursor == null || resumeAfter.isBefore(nextCursor)) {
            nextCursor = resumeAfter;
        }
    }

    public Instant cursor() {
        return hasMore ? nextCursor : queryStart.minus(OVERLAP);
    }
}
