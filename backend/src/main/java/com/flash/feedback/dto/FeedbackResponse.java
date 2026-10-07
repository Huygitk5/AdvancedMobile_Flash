package com.flash.feedback.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.util.UUID;

/**
 * Một feedback kèm thông tin để hiển thị: người gửi và tên item / nơi item thuộc về.
 * <ul>
 *   <li>flashcard: itemTitle = từ vựng, parentTitle = tên topic, topicId = topic của từ</li>
 *   <li>grammar: itemTitle = tên bài ngữ pháp, grammarLessonId = itemId</li>
 *   <li>quiz: itemTitle = tên topic / bài ngữ pháp mà quiz thuộc về, parentTitle = tiêu đề quiz,
 *       topicId hoặc grammarLessonId tương ứng</li>
 * </ul>
 */
@Getter
@Builder
public class FeedbackResponse {

    private final UUID id;
    private final CreatedBy createdBy;
    private final Instant createdAt;
    private final String content;
    /** 1 = flashcard, 2 = grammar, 3 = quiz. */
    private final Integer feedbackFor;
    private final UUID itemId;
    private final Boolean isViewed;
    private final String itemTitle;
    private final String parentTitle;
    private final UUID topicId;
    private final UUID grammarLessonId;

    @Getter
    @AllArgsConstructor
    public static class CreatedBy {
        private final UUID id;
        private final String fullName;
        private final String email;
    }
}
