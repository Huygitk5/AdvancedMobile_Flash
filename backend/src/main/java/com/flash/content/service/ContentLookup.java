package com.flash.content.service;

import com.flash.common.BusinessException;
import com.flash.common.ErrorCode;
import com.flash.content.entity.GrammarLesson;
import com.flash.content.entity.Topic;
import com.flash.content.repository.GrammarLessonRepository;
import com.flash.content.repository.TopicRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.UUID;

/**
 * Tìm nội dung theo id với quy tắc hiển thị chung:
 * user thường chỉ thấy bản đã xuất bản, admin thấy cả bản nháp; bản đã xoá thì không ai thấy.
 */
@Component
@RequiredArgsConstructor
public class ContentLookup {

    private final TopicRepository topicRepository;
    private final GrammarLessonRepository grammarLessonRepository;

    public Topic topic(UUID id, boolean includeUnpublished) {
        return topicRepository.findByIdAndDeletedAtIsNull(id)
                .filter(t -> includeUnpublished || t.getIsPublished())
                .orElseThrow(() -> new BusinessException(ErrorCode.NOT_FOUND, "Không tìm thấy chủ đề"));
    }

    public GrammarLesson grammar(UUID id, boolean includeUnpublished) {
        return grammarLessonRepository.findByIdAndDeletedAtIsNull(id)
                .filter(g -> includeUnpublished || g.getIsPublished())
                .orElseThrow(() -> new BusinessException(ErrorCode.NOT_FOUND, "Không tìm thấy chủ điểm ngữ pháp"));
    }
}
