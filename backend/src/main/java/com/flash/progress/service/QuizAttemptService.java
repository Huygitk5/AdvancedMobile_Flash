package com.flash.progress.service;

import com.flash.common.BusinessException;
import com.flash.common.ErrorCode;
import com.flash.common.PageResponse;
import com.flash.common.util.Zones;
import com.flash.content.entity.Quiz;
import com.flash.content.entity.QuizQuestion;
import com.flash.content.entity.QuizQuestionOption;
import com.flash.content.entity.QuizType;
import com.flash.content.repository.QuizQuestionOptionRepository;
import com.flash.content.repository.QuizQuestionRepository;
import com.flash.content.repository.QuizRepository;
import com.flash.gamification.entity.QuestType;
import com.flash.gamification.entity.XpSourceType;
import com.flash.gamification.service.QuestService;
import com.flash.gamification.service.XpRules;
import com.flash.gamification.service.XpService;
import com.flash.progress.dto.QuizResultResponse;
import com.flash.progress.dto.QuizReviewItemResponse;
import com.flash.progress.dto.QuizSubmitRequest;
import com.flash.progress.entity.QuizAttempt;
import com.flash.progress.entity.QuizAttemptAnswer;
import com.flash.progress.repository.QuizAttemptAnswerRepository;
import com.flash.progress.repository.QuizAttemptRepository;
import com.flash.user.entity.User;
import com.flash.user.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * Nộp và xem lại bài kiểm tra. Server chấm lại từ answers[], bỏ qua mọi con số điểm client gửi.
 * (Đặt tên khác content.service.QuizService - phần đề bài.)
 */
@Service
@RequiredArgsConstructor
public class QuizAttemptService {

    private final UserService userService;
    private final QuizRepository quizRepository;
    private final QuizQuestionRepository questionRepository;
    private final QuizQuestionOptionRepository optionRepository;
    private final QuizAttemptRepository attemptRepository;
    private final QuizAttemptAnswerRepository answerRepository;
    private final ContentProgressService contentProgressService;
    private final ActivityRecorder activityRecorder;
    private final XpService xpService;
    private final QuestService questService;

    @Transactional
    public QuizResultResponse submit(UUID userId, QuizSubmitRequest request) {
        User user = userService.lockActiveUser(userId);

        Optional<QuizAttempt> existing = attemptRepository.findById(request.getAttemptId());
        if (existing.isPresent()) {
            QuizAttempt attempt = existing.get();
            if (!attempt.getUserId().equals(userId)) {
                throw new BusinessException(ErrorCode.CONFLICT, "attemptId đã được sử dụng");
            }
            return result(attempt).duplicate(true).build();
        }

        Quiz quiz = quizRepository.findByIdAndDeletedAtIsNull(request.getQuizId())
                .filter(Quiz::getIsPublished)
                .orElseThrow(() -> new BusinessException(ErrorCode.NOT_FOUND, "Không tìm thấy bài kiểm tra"));
        List<QuizQuestion> questions = questionRepository.findByQuizIdAndDeletedAtIsNullOrderBySortOrder(quiz.getId());
        Map<UUID, Integer> selected = validateAnswers(request, questions);

        int correct = 0;
        for (QuizQuestion question : questions) {
            if (Objects.equals(selected.get(question.getId()), question.getCorrectOptionIndex())) {
                correct++;
            }
        }
        int total = questions.size();
        int scorePercent = Math.round(correct * 100f / total);
        boolean perfect = correct == total;

        QuizAttempt attempt = new QuizAttempt();
        attempt.setId(request.getAttemptId());
        attempt.setUserId(userId);
        attempt.setQuizId(quiz.getId());
        attempt.setTotalQuestions(total);
        attempt.setCorrectAnswers(correct);
        attempt.setWrongAnswers(total - correct);
        attempt.setScorePercent(scorePercent);
        attempt.setTimeTakenSeconds(request.getTimeTakenSeconds());
        attempt.setStartedAt(request.getStartedAt());
        attempt.setSubmittedAt(request.getSubmittedAt());
        attemptRepository.save(attempt);
        for (QuizQuestion question : questions) {
            QuizAttemptAnswer answer = new QuizAttemptAnswer();
            answer.setAttemptId(attempt.getId());
            answer.setQuestionId(question.getId());
            answer.setSelectedOptionIndex(selected.get(question.getId()));
            answer.setIsCorrect(Objects.equals(selected.get(question.getId()), question.getCorrectOptionIndex()));
            answerRepository.save(answer);
        }

        Instant now = Instant.now();
        Instant submittedAt = request.getSubmittedAt();
        Instant studiedAt = submittedAt.isBefore(now) ? submittedAt : now;
        if (quiz.getQuizType() == QuizType.GRAMMAR) {
            contentProgressService.grammarQuizScored(userId, quiz.getGrammarLessonId(), scorePercent,
                    scorePercent >= quiz.getPassScorePercent(), studiedAt);
        } else {
            contentProgressService.refreshTopic(userId, quiz.getTopicId(), studiedAt);
        }

        int xpAwarded = 0;
        if (XpRules.isPlausible(submittedAt, now)) {
            int correctCount = correct;
            activityRecorder.record(user, submittedAt, stat -> {
                stat.setQuizzesCompleted(stat.getQuizzesCompleted() + 1);
                stat.setCorrectAnswers(stat.getCorrectAnswers() + correctCount);
                stat.setTotalAnswers(stat.getTotalAnswers() + total);
                stat.setStudySeconds(stat.getStudySeconds() + request.getTimeTakenSeconds());
            });
            xpAwarded = awardXp(user, quiz, correct, perfect, submittedAt);
            questService.onEvent(user, QuestType.COMPLETE_QUIZ, 1, submittedAt);
            if (perfect) {
                questService.onEvent(user, QuestType.PERFECT_QUIZ, 1, submittedAt);
            }
            questService.onEvent(user, QuestType.STUDY_MINUTES, request.getTimeTakenSeconds() / 60, submittedAt);
        }

        List<UUID> wrong = questions.stream()
                .filter(q -> !Objects.equals(selected.get(q.getId()), q.getCorrectOptionIndex()))
                .map(QuizQuestion::getId)
                .collect(Collectors.toList());
        return QuizResultResponse.base(attempt, quiz, wrong).xpAwarded(xpAwarded).duplicate(false).build();
    }

    @Transactional(readOnly = true)
    public PageResponse<QuizResultResponse> attempts(UUID userId, UUID quizId, int page, int size) {
        Page<QuizAttempt> attempts = attemptRepository.search(userId, quizId, PageRequest.of(page, size));
        List<UUID> attemptIds = attempts.map(QuizAttempt::getId).getContent();
        Map<UUID, List<UUID>> wrongByAttempt = attemptIds.isEmpty() ? Map.of()
                : answerRepository.findByAttemptIdIn(attemptIds).stream()
                .filter(a -> !a.getIsCorrect())
                .collect(Collectors.groupingBy(QuizAttemptAnswer::getAttemptId,
                        Collectors.mapping(QuizAttemptAnswer::getQuestionId, Collectors.toList())));
        Map<UUID, Quiz> quizzes = quizRepository.findAllById(
                        attempts.map(QuizAttempt::getQuizId).toSet()).stream()
                .collect(Collectors.toMap(Quiz::getId, Function.identity()));
        return PageResponse.of(attempts.map(a -> QuizResultResponse.base(a, quizzes.get(a.getQuizId()),
                wrongByAttempt.getOrDefault(a.getId(), List.of())).build()));
    }

    @Transactional(readOnly = true)
    public QuizResultResponse attempt(UUID userId, UUID attemptId) {
        return result(findAttempt(userId, attemptId)).build();
    }

    /**
     * Dữ liệu QuizReviewScreen. Đọc cả câu hỏi đã bị xoá mềm (admin sửa đề sau khi user làm bài),
     * nên bài làm cũ vẫn xem lại đúng như lúc làm.
     */
    @Transactional(readOnly = true)
    public List<QuizReviewItemResponse> review(UUID userId, UUID attemptId) {
        QuizAttempt attempt = findAttempt(userId, attemptId);
        List<QuizAttemptAnswer> answers = answerRepository.findByAttemptId(attempt.getId());
        Map<UUID, QuizAttemptAnswer> answerByQuestion = answers.stream()
                .collect(Collectors.toMap(QuizAttemptAnswer::getQuestionId, Function.identity()));
        List<QuizQuestion> questions = questionRepository.findAllById(answerByQuestion.keySet()).stream()
                .sorted(Comparator.comparing(QuizQuestion::getSortOrder))
                .collect(Collectors.toList());
        Map<UUID, List<String>> options = questions.isEmpty() ? Map.of()
                : optionRepository.findByQuestionIdInOrderByQuestionIdAscOptionIndexAsc(answerByQuestion.keySet()).stream()
                .collect(Collectors.groupingBy(QuizQuestionOption::getQuestionId,
                        Collectors.mapping(QuizQuestionOption::getOptionText, Collectors.toList())));

        return questions.stream().map(q -> {
            QuizAttemptAnswer answer = answerByQuestion.get(q.getId());
            return QuizReviewItemResponse.builder()
                    .id(q.getId())
                    .question(q.getQuestionText())
                    .options(options.getOrDefault(q.getId(), List.of()))
                    .correctIndex(q.getCorrectOptionIndex())
                    .userIndex(answer.getSelectedOptionIndex() != null ? answer.getSelectedOptionIndex() : -1)
                    .isCorrect(answer.getIsCorrect())
                    .explanation(q.getExplanation())
                    .build();
        }).collect(Collectors.toList());
    }

    /**
     * Phải trả lời (hoặc bỏ qua bằng null) đúng mỗi câu hiện có của đề một lần, và
     * time_taken_seconds ≥ số câu × 1 giây. Sai thì 422 (client xoá op, không thử lại).
     */
    private static Map<UUID, Integer> validateAnswers(QuizSubmitRequest request, List<QuizQuestion> questions) {
        if (questions.isEmpty()) {
            throw new BusinessException(ErrorCode.BUSINESS_RULE_VIOLATION, "Bài kiểm tra chưa có câu hỏi");
        }
        Set<UUID> questionIds = questions.stream().map(QuizQuestion::getId).collect(Collectors.toSet());
        Map<UUID, Integer> selected = new HashMap<>();
        for (QuizSubmitRequest.Answer answer : request.getAnswers()) {
            if (!questionIds.contains(answer.getQuestionId())) {
                throw new BusinessException(ErrorCode.BUSINESS_RULE_VIOLATION,
                        "Câu hỏi " + answer.getQuestionId() + " không thuộc bài kiểm tra (đề có thể đã được cập nhật)");
            }
            if (selected.containsKey(answer.getQuestionId())) {
                throw new BusinessException(ErrorCode.BUSINESS_RULE_VIOLATION, "Một câu hỏi được trả lời nhiều lần");
            }
            selected.put(answer.getQuestionId(), answer.getSelectedOptionIndex());
        }
        if (selected.size() < questions.size()) {
            throw new BusinessException(ErrorCode.BUSINESS_RULE_VIOLATION,
                    "Thiếu câu trả lời: " + selected.size() + "/" + questions.size());
        }
        if (request.getTimeTakenSeconds() < questions.size()) {
            throw new BusinessException(ErrorCode.BUSINESS_RULE_VIOLATION, "Thời gian làm bài không hợp lệ");
        }
        return selected;
    }

    /**
     * +2/câu đúng, +10 nếu 100%; chỉ lần làm đầu tiên trong ngày (địa phương) của mỗi quiz.
     * source_id chứa ngày nên nộp lại nhiều lần trong ngày cũng không được cộng lần hai.
     */
    private int awardXp(User user, Quiz quiz, int correct, boolean perfect, Instant submittedAt) {
        LocalDate day = Zones.localDate(user, submittedAt);
        long attemptsToday = attemptRepository.countByUserIdAndQuizIdAndSubmittedAtGreaterThanEqualAndSubmittedAtLessThan(
                user.getId(), quiz.getId(), Zones.startOfDay(user, day), Zones.startOfDay(user, day.plusDays(1)));
        if (attemptsToday > 1) {
            return 0;
        }
        int amount = correct * XpRules.QUIZ_CORRECT_XP + (perfect ? XpRules.QUIZ_PERFECT_BONUS : 0);
        return xpService.award(user, amount, XpSourceType.QUIZ, "quiz:" + quiz.getId() + ":" + day, day);
    }

    private QuizAttempt findAttempt(UUID userId, UUID attemptId) {
        return attemptRepository.findByIdAndUserId(attemptId, userId)
                .orElseThrow(() -> new BusinessException(ErrorCode.NOT_FOUND, "Không tìm thấy bài làm"));
    }

    private QuizResultResponse.QuizResultResponseBuilder result(QuizAttempt attempt) {
        List<UUID> wrong = answerRepository.findByAttemptId(attempt.getId()).stream()
                .filter(a -> !a.getIsCorrect())
                .map(QuizAttemptAnswer::getQuestionId)
                .collect(Collectors.toList());
        return QuizResultResponse.base(attempt, quizRepository.findById(attempt.getQuizId()).orElse(null), wrong);
    }
}
