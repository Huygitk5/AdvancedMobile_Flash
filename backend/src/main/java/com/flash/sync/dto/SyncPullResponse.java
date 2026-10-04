package com.flash.sync.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.Instant;

/** Response chung của /v1/sync/pull và /v1/sync/content. */
@Getter
@AllArgsConstructor
public class SyncPullResponse<T> {

    /** Gửi lại làm ?since= ở lần pull sau (client lưu vào sync_meta.server_cursor). */
    private final Instant cursor;

    /** true: còn dữ liệu, client gọi tiếp ngay với cursor mới. */
    private final boolean hasMore;

    private final T changes;
}
