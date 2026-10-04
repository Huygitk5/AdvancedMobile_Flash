package com.flash.sync.dto;

import com.flash.user.dto.UserSnapshot;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.Instant;
import java.util.List;

@Getter
@AllArgsConstructor
public class SyncPushResponse {

    private final Instant serverTime;

    /** serverReceivedAt − clientSentAt (ms) đã được cộng vào mọi timestamp trong lô. */
    private final long clockOffsetMs;

    /** Đúng thứ tự các op gửi lên. */
    private final List<SyncOpResult> results;

    /** Số liệu server-authoritative sau khi xử lý cả lô. */
    private final UserSnapshot user;
}
