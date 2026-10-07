package com.flash.home.dto;

import com.flash.common.enums.CefrLevel;
import com.flash.common.util.Progress;
import com.flash.content.entity.GrammarLesson;
import com.flash.content.entity.Topic;
import com.flash.progress.entity.UserGrammarProgress;
import com.flash.progress.entity.UserTopicProgress;
import lombok.Builder;
import lombok.Getter;

import java.util.UUID;

/**
 * Model Lesson bên Flutter: DTO tổng hợp từ topic (type = vocabulary) hoặc grammar (type = grammar).
 * id là id của topic / grammar lesson để mở đúng màn hình.
 */
@Getter
@Builder
public class LessonResponse {

    public static final String TYPE_VOCABULARY = "vocabulary";
    public static final String TYPE_GRAMMAR = "grammar";

    private final UUID id;
    private final String type;
    private final String title;
    private final CefrLevel level;
    private final Double progress;
    private final Integer itemCount;
    private final Integer estimatedMinutes;
    private final Long coverColor;

    public static LessonResponse of(Topic topic, UserTopicProgress progress) {
        int learned = progress != null ? progress.getLearnedWords() : 0;
        return LessonResponse.builder()
                .id(topic.getId())
                .type(TYPE_VOCABULARY)
                .title(topic.getTitle())
                .level(topic.getLevel())
                .progress(Progress.ratio(learned, topic.getTotalWords()))
                .itemCount(topic.getTotalWords())
                .estimatedMinutes(topic.getEstimatedMinutes())
                .coverColor(topic.getCoverColor())
                .build();
    }

    public static LessonResponse of(GrammarLesson lesson, UserGrammarProgress progress, int exampleCount) {
        return LessonResponse.builder()
                .id(lesson.getId())
                .type(TYPE_GRAMMAR)
                .title(lesson.getTitle())
                .level(lesson.getLevel())
                .progress(progress != null ? progress.getProgress().doubleValue() : 0d)
                .itemCount(exampleCount)
                .estimatedMinutes(lesson.getEstimatedMinutes())
                .coverColor(lesson.getCoverColor())
                .build();
    }
}
