package com.flash.content.dto;

import com.flash.common.enums.CefrLevel;
import com.flash.common.enums.ProgressStatus;
import com.flash.content.entity.GrammarLesson;
import com.flash.progress.entity.UserGrammarProgress;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.util.UUID;

/** Khớp model Grammar bên Flutter. status là enum, Flutter tự đổi sang chuỗi hiển thị ("Đang học 60%"). */
@Getter
@Builder
public class GrammarResponse {

    private final UUID id;
    private final String title;
    private final String description;
    private final String structure;
    private final String iconName;
    private final CefrLevel level;
    private final Long coverColor;
    private final Integer estimatedMinutes;
    private final Double progress;
    private final ProgressStatus status;
    private final Integer bestScorePercent;
    private final Instant lastStudiedAt;

    /** Chỉ trả cho admin. */
    private final Boolean isPublished;

    public static GrammarResponse of(GrammarLesson lesson, UserGrammarProgress progress, boolean forAdmin) {
        return GrammarResponse.builder()
                .id(lesson.getId())
                .title(lesson.getTitle())
                .description(lesson.getDescription())
                .structure(lesson.getStructure())
                .iconName(lesson.getIconName())
                .level(lesson.getLevel())
                .coverColor(lesson.getCoverColor())
                .estimatedMinutes(lesson.getEstimatedMinutes())
                .progress(progress != null ? progress.getProgress().doubleValue() : 0d)
                .status(progress != null ? progress.getStatus() : ProgressStatus.NOT_STARTED)
                .bestScorePercent(progress != null ? progress.getBestScorePercent() : null)
                .lastStudiedAt(progress != null ? progress.getLastStudiedAt() : null)
                .isPublished(forAdmin ? lesson.getIsPublished() : null)
                .build();
    }
}
