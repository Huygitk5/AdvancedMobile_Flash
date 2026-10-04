package com.flash.progress.service;

import com.flash.common.enums.ProgressStatus;
import com.flash.content.entity.Topic;
import com.flash.content.repository.QuizRepository;
import com.flash.content.repository.TopicRepository;
import com.flash.progress.entity.UserGrammarProgress;
import com.flash.progress.entity.UserTopicProgress;
import com.flash.progress.repository.UserFlashcardProgressRepository;
import com.flash.progress.repository.UserGrammarProgressRepository;
import com.flash.progress.repository.UserTopicProgressRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

/** Tiến độ theo topic / chủ điểm ngữ pháp (user_topic_progress, user_grammar_progress). */
@Component
@RequiredArgsConstructor
public class ContentProgressService {

    /** Đã đọc bài ngữ pháp nhưng chưa qua quiz thì tính là học được một nửa. */
    private static final BigDecimal GRAMMAR_READ_PROGRESS = new BigDecimal("0.5000");

    private final TopicRepository topicRepository;
    private final QuizRepository quizRepository;
    private final UserTopicProgressRepository topicProgressRepository;
    private final UserGrammarProgressRepository grammarProgressRepository;
    private final UserFlashcardProgressRepository flashcardProgressRepository;

    /**
     * Đếm lại số từ đã thuộc từ user_flashcard_progress (không +1/-1 nên không bao giờ lệch,
     * kể cả khi log đến muộn làm một thẻ rớt khỏi trạng thái "đã thuộc").
     */
    @Transactional(propagation = Propagation.MANDATORY)
    public UserTopicProgress refreshTopic(UUID userId, UUID topicId, Instant studiedAt) {
        UserTopicProgress progress = topicProgressRepository.findByUserIdAndTopicId(userId, topicId).orElseGet(() -> {
            UserTopicProgress p = new UserTopicProgress();
            p.setUserId(userId);
            p.setTopicId(topicId);
            return p;
        });
        int learned = (int) flashcardProgressRepository.countLearnedInTopic(userId, topicId);
        int total = topicRepository.findById(topicId).map(Topic::getTotalWords).orElse(0);

        progress.setLearnedWords(learned);
        if (total > 0 && learned >= total) {
            progress.setStatus(ProgressStatus.COMPLETED);
            if (progress.getCompletedAt() == null) {
                progress.setCompletedAt(studiedAt);
            }
        } else {
            progress.setStatus(ProgressStatus.IN_PROGRESS);
            progress.setCompletedAt(null);
        }
        progress.setLastStudiedAt(latest(progress.getLastStudiedAt(), studiedAt));
        return topicProgressRepository.save(progress);
    }

    /** Hoàn thành bài đọc: chủ điểm không có quiz thì xong luôn, có quiz thì phải qua quiz mới COMPLETED. */
    @Transactional(propagation = Propagation.MANDATORY)
    public void grammarLessonCompleted(UUID userId, UUID grammarLessonId, Instant at) {
        UserGrammarProgress progress = grammarProgress(userId, grammarLessonId);
        if (progress.getStatus() != ProgressStatus.COMPLETED) {
            boolean hasQuiz = quizRepository
                    .findFirstByGrammarLessonIdAndIsPublishedTrueAndDeletedAtIsNullOrderByCreatedAt(grammarLessonId)
                    .isPresent();
            if (hasQuiz) {
                progress.setStatus(ProgressStatus.IN_PROGRESS);
                progress.setProgress(progress.getProgress().max(GRAMMAR_READ_PROGRESS));
            } else {
                complete(progress, at);
            }
        }
        progress.setLastStudiedAt(latest(progress.getLastStudiedAt(), at));
        grammarProgressRepository.save(progress);
    }

    @Transactional(propagation = Propagation.MANDATORY)
    public void grammarQuizScored(UUID userId, UUID grammarLessonId, int scorePercent, boolean passed, Instant at) {
        UserGrammarProgress progress = grammarProgress(userId, grammarLessonId);
        Integer best = progress.getBestScorePercent();
        progress.setBestScorePercent(best == null ? scorePercent : Math.max(best, scorePercent));
        if (passed) {
            complete(progress, at);
        } else if (progress.getStatus() == ProgressStatus.NOT_STARTED) {
            progress.setStatus(ProgressStatus.IN_PROGRESS);
        }
        progress.setLastStudiedAt(latest(progress.getLastStudiedAt(), at));
        grammarProgressRepository.save(progress);
    }

    private UserGrammarProgress grammarProgress(UUID userId, UUID grammarLessonId) {
        return grammarProgressRepository.findByUserIdAndGrammarLessonId(userId, grammarLessonId).orElseGet(() -> {
            UserGrammarProgress p = new UserGrammarProgress();
            p.setUserId(userId);
            p.setGrammarLessonId(grammarLessonId);
            return p;
        });
    }

    private static void complete(UserGrammarProgress progress, Instant at) {
        progress.setStatus(ProgressStatus.COMPLETED);
        progress.setProgress(BigDecimal.ONE);
        if (progress.getCompletedAt() == null) {
            progress.setCompletedAt(at);
        }
    }

    private static Instant latest(Instant current, Instant candidate) {
        return current == null || candidate.isAfter(current) ? candidate : current;
    }
}
