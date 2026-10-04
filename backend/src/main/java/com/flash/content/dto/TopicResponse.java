package com.flash.content.dto;

import com.flash.common.enums.CefrLevel;
import com.flash.common.enums.ProgressStatus;
import com.flash.common.util.Progress;
import com.flash.content.entity.Topic;
import com.flash.progress.entity.UserTopicProgress;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.util.UUID;

/** Khớp model Topic bên Flutter (progress 0..1), thêm trạng thái học của user. */
@Getter
@Builder
public class TopicResponse {

    private final UUID id;
    private final String title;
    private final String description;
    private final String iconPath;
    private final CefrLevel level;
    private final Long coverColor;
    private final Integer estimatedMinutes;
    private final Integer totalWords;
    private final Integer learnedWords;
    private final Double progress;
    private final ProgressStatus status;
    private final Instant lastStudiedAt;

    /** Chỉ trả cho admin. */
    private final Boolean isPublished;

    public static TopicResponse of(Topic topic, UserTopicProgress progress, boolean forAdmin) {
        int learned = progress != null ? progress.getLearnedWords() : 0;
        return TopicResponse.builder()
                .id(topic.getId())
                .title(topic.getTitle())
                .description(topic.getDescription())
                .iconPath(topic.getIconPath())
                .level(topic.getLevel())
                .coverColor(topic.getCoverColor())
                .estimatedMinutes(topic.getEstimatedMinutes())
                .totalWords(topic.getTotalWords())
                .learnedWords(learned)
                .progress(Progress.ratio(learned, topic.getTotalWords()))
                .status(progress != null ? progress.getStatus() : ProgressStatus.NOT_STARTED)
                .lastStudiedAt(progress != null ? progress.getLastStudiedAt() : null)
                .isPublished(forAdmin ? topic.getIsPublished() : null)
                .build();
    }
}
