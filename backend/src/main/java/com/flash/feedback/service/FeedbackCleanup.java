package com.flash.feedback.service;

import com.flash.feedback.entity.FeedbackType;
import com.flash.feedback.repository.FeedbackRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

/**
 * Item chỉ bị xoá mềm nên FK cascade không chạy; khi item bị xoá thì feedback của nó bị xoá cứng
 * (bulk delete, không load từng entity) trong cùng transaction với việc xoá item.
 * Chỉ phụ thuộc FeedbackRepository nên các service content gọi được mà không tạo vòng phụ thuộc.
 */
@Component
@RequiredArgsConstructor
public class FeedbackCleanup {

    private final FeedbackRepository feedbackRepository;

    /** Flashcard bị xoá: xoá feedback của chính từ đó. */
    @Transactional(propagation = Propagation.MANDATORY)
    public void onFlashcardDeleted(UUID flashcardId) {
        feedbackRepository.deleteByItem(FeedbackType.FLASHCARD, flashcardId);
    }

    /** Grammar bị xoá: xoá feedback của bài đó và feedback quiz của các quiz thuộc bài đó. */
    @Transactional(propagation = Propagation.MANDATORY)
    public void onGrammarDeleted(UUID grammarLessonId) {
        feedbackRepository.deleteByItem(FeedbackType.GRAMMAR, grammarLessonId);
        feedbackRepository.deleteQuizFeedbackByGrammar(FeedbackType.QUIZ, grammarLessonId);
    }

    /** Quiz bị xoá: xoá feedback của quiz đó. */
    @Transactional(propagation = Propagation.MANDATORY)
    public void onQuizDeleted(UUID quizId) {
        feedbackRepository.deleteByItem(FeedbackType.QUIZ, quizId);
    }

    /** Topic bị xoá: xoá feedback flashcard của mọi từ trong topic và feedback quiz của mọi quiz thuộc topic. */
    @Transactional(propagation = Propagation.MANDATORY)
    public void onTopicDeleted(UUID topicId) {
        feedbackRepository.deleteFlashcardFeedbackByTopic(FeedbackType.FLASHCARD, topicId);
        feedbackRepository.deleteQuizFeedbackByTopic(FeedbackType.QUIZ, topicId);
    }
}
