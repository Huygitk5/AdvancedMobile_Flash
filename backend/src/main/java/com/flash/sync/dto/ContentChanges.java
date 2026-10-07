package com.flash.sync.dto;

import com.flash.common.enums.CefrLevel;
import com.flash.content.entity.Flashcard;
import com.flash.content.entity.GrammarExample;
import com.flash.content.entity.GrammarLesson;
import com.flash.content.entity.Quiz;
import com.flash.content.entity.QuizQuestion;
import com.flash.content.entity.QuizType;
import com.flash.content.entity.Topic;
import com.flash.gamification.dto.QuestDefinitionResponse;
import com.flash.gamification.dto.RewardItemResponse;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

/**
 * Delta nội dung cho GET /v1/sync/content. Các danh sách khớp bảng cache phía client
 * (docs/sql/client_sqlite.sql, phần A); {@code updatedAt} ghi vào cột server_updated_at.
 * Client không có cột deleted_at cho nội dung: dòng bị xoá / ẩn được báo trong {@link #deleted},
 * client xoá theo id (FK ON DELETE CASCADE ở local tự dọn bảng con).
 */
@Getter
@Builder
public class ContentChanges {

    private final List<TopicRow> topics;
    private final List<FlashcardRow> flashcards;
    private final List<GrammarLessonRow> grammarLessons;
    private final List<GrammarExampleRow> grammarExamples;
    private final List<QuizRow> quizzes;
    private final List<QuizQuestionRow> quizQuestions;

    /** Gồm cả định nghĩa đã tắt (isActive = false): user_quests cũ vẫn tham chiếu tới. */
    private final List<QuestDefinitionResponse> questDefinitions;

    /** Gồm cả vật phẩm đã gỡ khỏi shop (isActive = false): kho đồ của user vẫn tham chiếu tới. */
    private final List<RewardItemResponse> rewardItems;

    private final Deleted deleted;

    /** id nội dung đã bị xoá mềm, bỏ xuất bản, hoặc nằm dưới cha đã bị ẩn. */
    @Getter
    @Builder
    public static class Deleted {
        private final List<UUID> topics;
        private final List<UUID> flashcards;
        private final List<UUID> grammarLessons;
        private final List<UUID> grammarExamples;
        private final List<UUID> quizzes;
        private final List<UUID> quizQuestions;
    }

    @Getter
    @Builder
    public static class TopicRow {
        private final UUID id;
        private final String title;
        private final String description;
        private final String iconPath;
        private final CefrLevel level;
        private final Long coverColor;
        private final Integer estimatedMinutes;
        private final Integer totalWords;
        private final Integer sortOrder;
        private final Instant updatedAt;

        public static TopicRow from(Topic t) {
            return TopicRow.builder()
                    .id(t.getId())
                    .title(t.getTitle())
                    .description(t.getDescription())
                    .iconPath(t.getIconPath())
                    .level(t.getLevel())
                    .coverColor(t.getCoverColor())
                    .estimatedMinutes(t.getEstimatedMinutes())
                    .totalWords(t.getTotalWords())
                    .sortOrder(t.getSortOrder())
                    .updatedAt(t.getUpdatedAt())
                    .build();
        }
    }

    @Getter
    @Builder
    public static class FlashcardRow {
        private final UUID id;
        private final UUID topicId;
        private final String word;
        private final String partOfSpeech;
        private final String pronunciation;
        private final String meaning;
        private final String example;
        private final String exampleTranslation;
        private final String audioUrl;
        private final String imageUrl;
        private final Integer sortOrder;
        private final Instant updatedAt;

        public static FlashcardRow from(Flashcard f) {
            return FlashcardRow.builder()
                    .id(f.getId())
                    .topicId(f.getTopicId())
                    .word(f.getWord())
                    .partOfSpeech(f.getPartOfSpeech())
                    .pronunciation(f.getPronunciation())
                    .meaning(f.getMeaning())
                    .example(f.getExample())
                    .exampleTranslation(f.getExampleTranslation())
                    .audioUrl(f.getAudioUrl())
                    .imageUrl(f.getImageUrl())
                    .sortOrder(f.getSortOrder())
                    .updatedAt(f.getUpdatedAt())
                    .build();
        }
    }

    @Getter
    @Builder
    public static class GrammarLessonRow {
        private final UUID id;
        private final String title;
        private final String description;
        private final String structure;
        private final String content;
        private final String usageNotes;
        private final String iconName;
        private final CefrLevel level;
        private final Long coverColor;
        private final Integer estimatedMinutes;
        private final Integer sortOrder;
        private final Instant updatedAt;

        public static GrammarLessonRow from(GrammarLesson g) {
            return GrammarLessonRow.builder()
                    .id(g.getId())
                    .title(g.getTitle())
                    .description(g.getDescription())
                    .structure(g.getStructure())
                    .content(g.getContent())
                    .usageNotes(g.getUsageNotes())
                    .iconName(g.getIconName())
                    .level(g.getLevel())
                    .coverColor(g.getCoverColor())
                    .estimatedMinutes(g.getEstimatedMinutes())
                    .sortOrder(g.getSortOrder())
                    .updatedAt(g.getUpdatedAt())
                    .build();
        }
    }

    @Getter
    @Builder
    public static class GrammarExampleRow {
        private final UUID id;
        private final UUID grammarLessonId;
        private final String sentence;
        private final String translation;
        private final String highlight;
        private final Integer sortOrder;

        public static GrammarExampleRow from(GrammarExample e) {
            return GrammarExampleRow.builder()
                    .id(e.getId())
                    .grammarLessonId(e.getGrammarLessonId())
                    .sentence(e.getSentence())
                    .translation(e.getTranslation())
                    .highlight(e.getHighlight())
                    .sortOrder(e.getSortOrder())
                    .build();
        }
    }

    @Getter
    @Builder
    public static class QuizRow {
        private final UUID id;
        private final String title;
        private final QuizType quizType;
        private final UUID topicId;
        private final UUID grammarLessonId;
        private final Integer timeLimitSeconds;
        private final Integer passScorePercent;
        private final Instant updatedAt;

        public static QuizRow from(Quiz q) {
            return QuizRow.builder()
                    .id(q.getId())
                    .title(q.getTitle())
                    .quizType(q.getQuizType())
                    .topicId(q.getTopicId())
                    .grammarLessonId(q.getGrammarLessonId())
                    .timeLimitSeconds(q.getTimeLimitSeconds())
                    .passScorePercent(q.getPassScorePercent())
                    .updatedAt(q.getUpdatedAt())
                    .build();
        }
    }

    /** Câu hỏi kèm 4 đáp án (bảng quiz_question_options phía client). */
    @Getter
    @Builder
    public static class QuizQuestionRow {
        private final UUID id;
        private final UUID quizId;
        private final UUID flashcardId;
        private final String questionText;
        private final List<String> options;
        private final Integer correctOptionIndex;
        private final String explanation;
        private final Integer sortOrder;

        public static QuizQuestionRow from(QuizQuestion q, List<String> options) {
            return QuizQuestionRow.builder()
                    .id(q.getId())
                    .quizId(q.getQuizId())
                    .flashcardId(q.getFlashcardId())
                    .questionText(q.getQuestionText())
                    .options(options)
                    .correctOptionIndex(q.getCorrectOptionIndex())
                    .explanation(q.getExplanation())
                    .sortOrder(q.getSortOrder())
                    .build();
        }
    }
}
