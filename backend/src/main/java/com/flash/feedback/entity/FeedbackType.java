package com.flash.feedback.entity;

import com.flash.common.BusinessException;
import com.flash.common.ErrorCode;
import lombok.Getter;
import lombok.RequiredArgsConstructor;

/** Loại item được phản hồi. Giá trị số là thứ lưu trong DB (feedbacks.feedback_for) và trao đổi với client. */
@Getter
@RequiredArgsConstructor
public enum FeedbackType {
    FLASHCARD(1),
    GRAMMAR(2),
    QUIZ(3);

    private final int code;

    public static FeedbackType fromCode(Integer code) {
        if (code != null) {
            for (FeedbackType type : values()) {
                if (type.code == code) {
                    return type;
                }
            }
        }
        throw new BusinessException(ErrorCode.VALIDATION_ERROR, "feedbackFor phải là 1 (flashcard), 2 (grammar) hoặc 3 (quiz)");
    }
}
