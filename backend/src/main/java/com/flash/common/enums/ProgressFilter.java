package com.flash.common.enums;

import java.util.Arrays;
import java.util.Collection;
import java.util.List;

/**
 * Bộ lọc tiến độ trên TopicScreen / tab Ngữ pháp: Tất cả / Chưa học / Đang học / Hoàn thành.
 * User chưa học thì không có dòng progress (NULL), nên NOT_STARTED phải gồm cả trường hợp đó.
 */
public enum ProgressFilter {
    ALL, NOT_STARTED, IN_PROGRESS, COMPLETED;

    public boolean isAll() {
        return this == ALL;
    }

    public boolean includesMissingProgress() {
        return this == ALL || this == NOT_STARTED;
    }

    /** Luôn khác rỗng vì JPQL "in ()" là cú pháp lỗi. */
    public Collection<ProgressStatus> statuses() {
        return this == ALL ? Arrays.asList(ProgressStatus.values()) : List.of(ProgressStatus.valueOf(name()));
    }
}
