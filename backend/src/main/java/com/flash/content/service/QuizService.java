package com.flash.content.service;

import com.flash.common.BusinessException;
import com.flash.common.ErrorCode;
import com.flash.content.dto.QuizDetailResponse;
import com.flash.content.dto.QuizQuestionResponse;
import com.flash.content.dto.QuizRequest;
import com.flash.content.dto.QuizResponse;
import com.flash.content.entity.Quiz;
import com.flash.content.entity.QuizQuestion;
import com.flash.content.entity.QuizQuestionOption;
import com.flash.content.entity.QuizType;
import com.flash.content.repository.FlashcardRepository;
import com.flash.content.repository.QuizQuestionOptionRepository;
import com.flash.content.repository.QuizQuestionRepository;
import com.flash.content.repository.QuizRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

/** Đề kiểm tra (nội dung). Nộp bài / chấm điểm nằm ở progress.service.QuizAttemptService. */
@Service
@RequiredArgsConstructor
public class QuizService {

    private final QuizRepository quizRepository;
    private final QuizQuestionRepository questionRepository;
    private final QuizQuestionOptionRepository optionRepository;
    private final FlashcardRepository flashcardRepository;
    private final ContentLookup contentLookup;

    @Transactional(readOnly = true)
    public List<QuizResponse> list(UUID topicId, UUID grammarLessonId, boolean includeUnpublished) {
        List<Quiz> quizzes = quizRepository.search(topicId, grammarLessonId, includeUnpublished);
        if (quizzes.isEmpty()) {
            return List.of();
        }
        Map<UUID, Long> counts = questionRepository.countByQuizIds(
                        quizzes.stream().map(Quiz::getId).collect(Collectors.toList())).stream()
                .collect(Collectors.toMap(row -> (UUID) row[0], row -> (Long) row[1]));
        return quizzes.stream()
                .map(q -> QuizResponse.of(q, counts.getOrDefault(q.getId(), 0L).intValue(), includeUnpublished))
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public QuizDetailResponse get(UUID id, boolean isAdmin) {
        Quiz quiz = findQuiz(id, isAdmin);
        return detail(quiz, isAdmin);
    }

    @Transactional
    public QuizDetailResponse create(QuizRequest request) {
        Quiz quiz = new Quiz();
        apply(quiz, request);
        quizRepository.save(quiz);
        replaceQuestions(quiz.getId(), request.getQuestions());
        return detail(quiz, true);
    }

    @Transactional
    public QuizDetailResponse update(UUID id, QuizRequest request) {
        Quiz quiz = findQuiz(id, true);
        apply(quiz, request);
        quizRepository.saveAndFlush(quiz);
        replaceQuestions(id, request.getQuestions());
        return detail(quiz, true);
    }

    @Transactional
    public void delete(UUID id) {
        findQuiz(id, true).setDeletedAt(Instant.now());
    }

    private Quiz findQuiz(UUID id, boolean includeUnpublished) {
        return quizRepository.findByIdAndDeletedAtIsNull(id)
                .filter(q -> includeUnpublished || q.getIsPublished())
                .orElseThrow(() -> new BusinessException(ErrorCode.NOT_FOUND, "Không tìm thấy bài kiểm tra"));
    }

    /** 1 query câu hỏi + 1 query toàn bộ đáp án, ghép trong bộ nhớ. */
    private QuizDetailResponse detail(Quiz quiz, boolean forAdmin) {
        List<QuizQuestion> questions = questionRepository.findByQuizIdAndDeletedAtIsNullOrderBySortOrder(quiz.getId());
        Map<UUID, List<String>> optionsByQuestion = questions.isEmpty() ? Map.of()
                : optionRepository.findByQuestionIdInOrderByQuestionIdAscOptionIndexAsc(
                        questions.stream().map(QuizQuestion::getId).collect(Collectors.toList())).stream()
                .collect(Collectors.groupingBy(QuizQuestionOption::getQuestionId,
                        Collectors.mapping(QuizQuestionOption::getOptionText, Collectors.toList())));

        List<QuizQuestionResponse> items = questions.stream()
                .map(q -> QuizQuestionResponse.builder()
                        .id(q.getId())
                        .quizId(quiz.getId())
                        .topicId(quiz.getTopicId())
                        .flashcardId(q.getFlashcardId())
                        .questionText(q.getQuestionText())
                        .options(optionsByQuestion.getOrDefault(q.getId(), List.of()))
                        .correctAnswerIndex(q.getCorrectOptionIndex())
                        .explanation(q.getExplanation())
                        .build())
                .collect(Collectors.toList());
        return new QuizDetailResponse(QuizResponse.of(quiz, items.size(), forAdmin), items);
    }

    /** Xoá mềm câu hỏi cũ (bài làm cũ vẫn xem lại được), thêm bộ câu hỏi mới. */
    private void replaceQuestions(UUID quizId, List<QuizRequest.Question> questions) {
        questionRepository.softDeleteByQuiz(quizId, Instant.now());
        int order = 1;
        for (QuizRequest.Question item : questions) {
            if (item.getFlashcardId() != null && flashcardRepository.findByIdAndDeletedAtIsNull(item.getFlashcardId()).isEmpty()) {
                throw new BusinessException(ErrorCode.VALIDATION_ERROR, "Câu " + order + ": flashcardId không tồn tại");
            }
            QuizQuestion question = new QuizQuestion();
            question.setQuizId(quizId);
            question.setFlashcardId(item.getFlashcardId());
            question.setQuestionText(item.getQuestionText().trim());
            question.setCorrectOptionIndex(item.getCorrectOptionIndex());
            question.setExplanation(item.getExplanation());
            question.setSortOrder(order++);
            questionRepository.save(question);

            for (int i = 0; i < item.getOptions().size(); i++) {
                QuizQuestionOption option = new QuizQuestionOption();
                option.setQuestionId(question.getId());
                option.setOptionIndex(i);
                option.setOptionText(item.getOptions().get(i).trim());
                optionRepository.save(option);
            }
        }
    }

    /** Quiz thuộc đúng 1 trong 2: topic hoặc grammar lesson (MySQL không CHECK được vì cột có FK). */
    private void apply(Quiz quiz, QuizRequest request) {
        if (request.getQuizType() == QuizType.TOPIC) {
            if (request.getTopicId() == null || request.getGrammarLessonId() != null) {
                throw new BusinessException(ErrorCode.VALIDATION_ERROR, "Quiz TOPIC cần topicId và không có grammarLessonId");
            }
            contentLookup.topic(request.getTopicId(), true);
        } else {
            if (request.getGrammarLessonId() == null || request.getTopicId() != null) {
                throw new BusinessException(ErrorCode.VALIDATION_ERROR, "Quiz GRAMMAR cần grammarLessonId và không có topicId");
            }
            contentLookup.grammar(request.getGrammarLessonId(), true);
        }
        quiz.setTitle(request.getTitle().trim());
        quiz.setQuizType(request.getQuizType());
        quiz.setTopicId(request.getTopicId());
        quiz.setGrammarLessonId(request.getGrammarLessonId());
        quiz.setTimeLimitSeconds(request.getTimeLimitSeconds());
        quiz.setPassScorePercent(request.getPassScorePercent() != null ? request.getPassScorePercent() : 70);
        quiz.setIsPublished(Boolean.TRUE.equals(request.getIsPublished()));
    }
}
