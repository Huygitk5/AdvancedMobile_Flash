package com.flash.progress.dto;

import com.flash.user.dto.UserSnapshot;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class ReviewResponse {

    private final SrsProgressResponse progress;
    private final int xpAwarded;

    /** true nếu logId đã được xử lý trước đó (không cộng gì thêm). */
    private final boolean duplicate;

    private final UserSnapshot user;
}
