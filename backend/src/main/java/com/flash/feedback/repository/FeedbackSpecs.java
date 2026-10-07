package com.flash.feedback.repository;

import com.flash.feedback.entity.Feedback;
import com.flash.feedback.entity.FeedbackType;
import org.springframework.data.jpa.domain.Specification;

import java.time.Instant;
import java.util.UUID;

/** Các điều kiện lọc tuỳ chọn; tham số null thì bỏ qua điều kiện đó. */
public final class FeedbackSpecs {

    private FeedbackSpecs() {
    }

    public static Specification<Feedback> filter(UUID userId, FeedbackType type, Boolean isViewed,
                                                 Instant fromInclusive, Instant toExclusive) {
        Specification<Feedback> spec = Specification.where(null);
        if (userId != null) {
            spec = spec.and((root, q, cb) -> cb.equal(root.get("userId"), userId));
        }
        if (type != null) {
            spec = spec.and((root, q, cb) -> cb.equal(root.get("feedbackFor"), type));
        }
        if (isViewed != null) {
            spec = spec.and((root, q, cb) -> cb.equal(root.get("isViewed"), isViewed));
        }
        if (fromInclusive != null) {
            spec = spec.and((root, q, cb) -> cb.greaterThanOrEqualTo(root.get("createdAt"), fromInclusive));
        }
        if (toExclusive != null) {
            spec = spec.and((root, q, cb) -> cb.lessThan(root.get("createdAt"), toExclusive));
        }
        return spec;
    }
}
