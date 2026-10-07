package com.flash.feedback;

import com.flash.common.BusinessException;
import com.flash.common.ErrorCode;
import com.flash.content.entity.Flashcard;
import com.flash.content.entity.GrammarLesson;
import com.flash.content.entity.Quiz;
import com.flash.content.entity.Topic;
import com.flash.content.repository.FlashcardRepository;
import com.flash.content.repository.GrammarExampleRepository;
import com.flash.content.repository.GrammarLessonRepository;
import com.flash.content.repository.QuizQuestionOptionRepository;
import com.flash.content.repository.QuizQuestionRepository;
import com.flash.content.repository.QuizRepository;
import com.flash.content.repository.TopicRepository;
import com.flash.content.service.ContentLookup;
import com.flash.content.service.FlashcardService;
import com.flash.content.service.GrammarService;
import com.flash.content.service.QuizService;
import com.flash.content.service.TopicService;
import com.flash.feedback.entity.FeedbackType;
import com.flash.feedback.repository.FeedbackRepository;
import com.flash.feedback.service.FeedbackCleanup;
import com.flash.progress.repository.UserGrammarProgressRepository;
import com.flash.progress.repository.UserTopicProgressRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InOrder;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.mockito.junit.jupiter.MockitoSettings;
import org.mockito.quality.Strictness;

import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.inOrder;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

/**
 * Xoá item (xoá mềm) phải xoá cứng feedback của nó: kiểm FeedbackCleanup gọi đúng bulk delete
 * và 4 service content gọi FeedbackCleanup đúng lúc (không cần DB / Docker).
 */
@ExtendWith(MockitoExtension.class)
@MockitoSettings(strictness = Strictness.LENIENT)
class FeedbackCascadeTest {

    @Mock private FeedbackRepository feedbackRepository;
    @Mock private FeedbackCleanup feedbackCleanup;
    @Mock private ContentLookup contentLookup;
    @Mock private FlashcardRepository flashcardRepository;
    @Mock private TopicRepository topicRepository;
    @Mock private GrammarLessonRepository grammarLessonRepository;
    @Mock private GrammarExampleRepository grammarExampleRepository;
    @Mock private UserGrammarProgressRepository grammarProgressRepository;
    @Mock private UserTopicProgressRepository topicProgressRepository;
    @Mock private QuizRepository quizRepository;
    @Mock private QuizQuestionRepository quizQuestionRepository;
    @Mock private QuizQuestionOptionRepository quizQuestionOptionRepository;

    private final UUID id = UUID.randomUUID();

    // ------------------------------------------------------------------ FeedbackCleanup -> bulk delete

    @Test
    void cleanupDeletesByTheRightItemTypes() {
        FeedbackCleanup cleanup = new FeedbackCleanup(feedbackRepository);

        cleanup.onFlashcardDeleted(id);
        verify(feedbackRepository).deleteByItem(FeedbackType.FLASHCARD, id);

        cleanup.onQuizDeleted(id);
        verify(feedbackRepository).deleteByItem(FeedbackType.QUIZ, id);

        cleanup.onGrammarDeleted(id);
        verify(feedbackRepository).deleteByItem(FeedbackType.GRAMMAR, id);
        verify(feedbackRepository).deleteQuizFeedbackByGrammar(FeedbackType.QUIZ, id);

        cleanup.onTopicDeleted(id);
        verify(feedbackRepository).deleteFlashcardFeedbackByTopic(FeedbackType.FLASHCARD, id);
        verify(feedbackRepository).deleteQuizFeedbackByTopic(FeedbackType.QUIZ, id);
    }

    // ------------------------------------------------------------------ service content gọi cleanup

    @Test
    void deletingFlashcardCleansItsFeedback() {
        Flashcard card = new Flashcard();
        card.setId(id);
        card.setTopicId(UUID.randomUUID());
        when(flashcardRepository.findByIdAndDeletedAtIsNull(id)).thenReturn(Optional.of(card));
        FlashcardService service = new FlashcardService(flashcardRepository, topicRepository, contentLookup, feedbackCleanup);

        service.delete(id);

        assertThat(card.getDeletedAt()).isNotNull();
        verify(feedbackCleanup).onFlashcardDeleted(id);
    }

    @Test
    void deletingMissingFlashcardDoesNotCleanAnything() {
        when(flashcardRepository.findByIdAndDeletedAtIsNull(id)).thenReturn(Optional.empty());
        FlashcardService service = new FlashcardService(flashcardRepository, topicRepository, contentLookup, feedbackCleanup);

        assertThatThrownBy(() -> service.delete(id)).isInstanceOfSatisfying(BusinessException.class,
                e -> assertThat(e.getErrorCode()).isEqualTo(ErrorCode.NOT_FOUND));
        verifyNoInteractions(feedbackCleanup);
    }

    @Test
    void deletingGrammarCleansGrammarAndItsQuizFeedback() {
        GrammarLesson lesson = new GrammarLesson();
        lesson.setId(id);
        when(contentLookup.grammar(id, true)).thenReturn(lesson);
        GrammarService service = new GrammarService(grammarLessonRepository, grammarExampleRepository,
                grammarProgressRepository, quizRepository, contentLookup, feedbackCleanup);

        service.delete(id);

        assertThat(lesson.getDeletedAt()).isNotNull();
        verify(feedbackCleanup).onGrammarDeleted(id);
    }

    @Test
    void deletingQuizCleansItsFeedback() {
        Quiz quiz = new Quiz();
        quiz.setId(id);
        quiz.setIsPublished(true);
        when(quizRepository.findByIdAndDeletedAtIsNull(id)).thenReturn(Optional.of(quiz));
        QuizService service = new QuizService(quizRepository, quizQuestionRepository, quizQuestionOptionRepository,
                flashcardRepository, contentLookup, feedbackCleanup);

        service.delete(id);

        assertThat(quiz.getDeletedAt()).isNotNull();
        verify(feedbackCleanup).onQuizDeleted(id);
    }

    @Test
    void deletingTopicCleansFlashcardAndQuizFeedback() {
        Topic topic = new Topic();
        topic.setId(id);
        when(contentLookup.topic(id, true)).thenReturn(topic);
        TopicService service = new TopicService(topicRepository, topicProgressRepository, contentLookup, feedbackCleanup);

        service.delete(id);

        assertThat(topic.getDeletedAt()).isNotNull();
        verify(feedbackCleanup).onTopicDeleted(id);
    }

    @Test
    void deletingMissingTopicDoesNotCleanAnything() {
        when(contentLookup.topic(id, true))
                .thenThrow(new BusinessException(ErrorCode.NOT_FOUND, "Không tìm thấy chủ đề"));
        TopicService service = new TopicService(topicRepository, topicProgressRepository, contentLookup, feedbackCleanup);

        assertThatThrownBy(() -> service.delete(id)).isInstanceOf(BusinessException.class);
        verify(feedbackCleanup, never()).onTopicDeleted(any());
    }
}
