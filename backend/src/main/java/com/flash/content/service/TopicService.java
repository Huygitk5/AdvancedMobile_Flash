package com.flash.content.service;

import com.flash.common.enums.CefrLevel;
import com.flash.common.enums.ProgressFilter;
import com.flash.common.PageResponse;
import com.flash.content.dto.TopicRequest;
import com.flash.content.dto.TopicResponse;
import com.flash.content.entity.Topic;
import com.flash.content.repository.TopicRepository;
import com.flash.progress.entity.UserTopicProgress;
import com.flash.progress.repository.UserTopicProgressRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.Instant;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class TopicService {

    private final TopicRepository topicRepository;
    private final UserTopicProgressRepository progressRepository;
    private final ContentLookup contentLookup;

    @Transactional(readOnly = true)
    public PageResponse<TopicResponse> list(UUID userId, String keyword, ProgressFilter filter,
                                            boolean includeUnpublished, Pageable pageable) {
        String normalizedKeyword = StringUtils.hasText(keyword) ? keyword.trim() : null;
        return PageResponse.of(topicRepository.searchWithProgress(userId, normalizedKeyword, includeUnpublished,
                        filter.isAll(), filter.statuses(), filter.includesMissingProgress(), pageable)
                .map(row -> TopicResponse.of((Topic) row[0], (UserTopicProgress) row[1], includeUnpublished)));
    }

    @Transactional(readOnly = true)
    public TopicResponse get(UUID userId, UUID id, boolean isAdmin) {
        Topic topic = contentLookup.topic(id, isAdmin);
        UserTopicProgress progress = progressRepository.findByUserIdAndTopicId(userId, id).orElse(null);
        return TopicResponse.of(topic, progress, isAdmin);
    }

    @Transactional
    public TopicResponse create(TopicRequest request) {
        Topic topic = new Topic();
        apply(topic, request);
        topicRepository.save(topic);
        return TopicResponse.of(topic, null, true);
    }

    @Transactional
    public TopicResponse update(UUID id, TopicRequest request) {
        Topic topic = contentLookup.topic(id, true);
        apply(topic, request);
        topicRepository.saveAndFlush(topic);
        return TopicResponse.of(topic, null, true);
    }

    /** Xoá mềm: flashcard của topic tự bị ẩn vì mọi truy vấn đều lọc topic đã xoá. */
    @Transactional
    public void delete(UUID id) {
        contentLookup.topic(id, true).setDeletedAt(Instant.now());
    }

    private static void apply(Topic topic, TopicRequest request) {
        topic.setTitle(request.getTitle().trim());
        topic.setDescription(request.getDescription());
        topic.setIconPath(request.getIconPath().trim());
        topic.setLevel(request.getLevel() != null ? request.getLevel() : CefrLevel.A1);
        topic.setCoverColor(request.getCoverColor());
        topic.setEstimatedMinutes(request.getEstimatedMinutes() != null ? request.getEstimatedMinutes() : 10);
        topic.setSortOrder(request.getSortOrder() != null ? request.getSortOrder() : 0);
        topic.setIsPublished(Boolean.TRUE.equals(request.getIsPublished()));
    }
}
