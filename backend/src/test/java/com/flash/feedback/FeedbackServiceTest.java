package com.flash.feedback;

import com.flash.common.BusinessException;
import com.flash.common.ErrorCode;
import com.flash.common.PageResponse;
import com.flash.content.entity.Flashcard;
import com.flash.content.entity.GrammarLesson;
import com.flash.content.entity.Quiz;
import com.flash.content.entity.QuizType;
import com.flash.content.entity.Topic;
import com.flash.content.repository.FlashcardRepository;
import com.flash.content.repository.GrammarLessonRepository;
import com.flash.content.repository.QuizRepository;
import com.flash.content.repository.TopicRepository;
import com.flash.feedback.dto.FeedbackCreateRequest;
import com.flash.feedback.dto.FeedbackResponse;
import com.flash.feedback.dto.FeedbackSummaryResponse;
import com.flash.feedback.entity.Feedback;
import com.flash.feedback.entity.FeedbackType;
import com.flash.feedback.repository.FeedbackRepository;
import com.flash.feedback.service.FeedbackService;
import com.flash.user.entity.User;
import com.flash.user.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.ArgumentMatchers;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.mockito.junit.jupiter.MockitoSettings;
import org.mockito.quality.Strictness;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;

import javax.persistence.criteria.CriteriaBuilder;
import javax.persistence.criteria.CriteriaQuery;
import javax.persistence.criteria.Expression;
import javax.persistence.criteria.Root;
import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyBoolean;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/** Logic của FeedbackService với repository giả (không cần DB / Docker). */
@ExtendWith(MockitoExtension.class)
@MockitoSettings(strictness = Strictness.LENIENT)
class FeedbackServiceTest {

    @Mock private FeedbackRepository feedbackRepository;
    @Mock private FlashcardRepository flashcardRepository;
    @Mock private GrammarLessonRepository grammarLessonRepository;
    @Mock private QuizRepository quizRepository;
    @Mock private TopicRepository topicRepository;
    @Mock private UserRepository userRepository;

    private FeedbackService service;

    private final UUID userId = UUID.randomUUID();
    private User user;
    private Topic topic;
    private Flashcard card;
    private GrammarLesson grammar;
    private Quiz topicQuiz;
    private Quiz grammarQuiz;

    @BeforeEach
    void setUp() {
        service = new FeedbackService(feedbackRepository, flashcardRepository, grammarLessonRepository,
                quizRepository, topicRepository, userRepository);

        user = new User();
        user.setId(userId);
        user.setFullName("Nguyễn Văn A");
        user.setEmail("a@test.local");
        user.setTimezone("Asia/Ho_Chi_Minh");
        when(userRepository.findByIdAndDeletedAtIsNull(userId)).thenReturn(Optional.of(user));
        when(userRepository.findAllById(anyList())).thenReturn(List.of(user));

        topic = new Topic();
        topic.setId(UUID.randomUUID());
        topic.setTitle("Daily Life");
        card = new Flashcard();
        card.setId(UUID.randomUUID());
        card.setTopicId(topic.getId());
        card.setWord("beautiful");
        grammar = new GrammarLesson();
        grammar.setId(UUID.randomUUID());
        grammar.setTitle("Present Simple");
        topicQuiz = new Quiz();
        topicQuiz.setId(UUID.randomUUID());
        topicQuiz.setTitle("Daily Life Quiz");
        topicQuiz.setQuizType(QuizType.TOPIC);
        topicQuiz.setTopicId(topic.getId());
        grammarQuiz = new Quiz();
        grammarQuiz.setId(UUID.randomUUID());
        grammarQuiz.setTitle("Present Simple Quiz");
        grammarQuiz.setQuizType(QuizType.GRAMMAR);
        grammarQuiz.setGrammarLessonId(grammar.getId());

        when(flashcardRepository.findByIdAndDeletedAtIsNull(card.getId())).thenReturn(Optional.of(card));
        when(topicRepository.findByIdAndDeletedAtIsNull(topic.getId())).thenReturn(Optional.of(topic));
        when(grammarLessonRepository.findByIdAndDeletedAtIsNull(grammar.getId())).thenReturn(Optional.of(grammar));
        when(quizRepository.findByIdAndDeletedAtIsNull(topicQuiz.getId())).thenReturn(Optional.of(topicQuiz));
        when(quizRepository.findByIdAndDeletedAtIsNull(grammarQuiz.getId())).thenReturn(Optional.of(grammarQuiz));
        when(flashcardRepository.findAllById(anyList())).thenReturn(List.of(card));
        when(topicRepository.findAllById(anyList())).thenReturn(List.of(topic));
        when(grammarLessonRepository.findAllById(anyList())).thenReturn(List.of(grammar));
        when(quizRepository.findAllById(anyList())).thenReturn(List.of(topicQuiz, grammarQuiz));
        // Giống @PrePersist: gán id + createdAt khi lưu
        when(feedbackRepository.save(any(Feedback.class))).thenAnswer(inv -> {
            Feedback f = inv.getArgument(0);
            f.setId(UUID.randomUUID());
            f.setCreatedAt(Instant.parse("2026-03-10T10:00:00Z"));
            f.setUpdatedAt(f.getCreatedAt());
            return f;
        });
    }

    // ------------------------------------------------------------------ tạo

    @Test
    void createFlashcardFeedbackTrimsContentAndFillsDisplayInfo() {
        FeedbackResponse response = service.create(userId, request(1, card.getId(), "  Sai nghĩa  "));

        ArgumentCaptor<Feedback> saved = ArgumentCaptor.forClass(Feedback.class);
        verify(feedbackRepository).save(saved.capture());
        assertThat(saved.getValue().getContent()).isEqualTo("Sai nghĩa");
        assertThat(saved.getValue().getUserId()).isEqualTo(userId);
        assertThat(saved.getValue().getFeedbackFor()).isEqualTo(FeedbackType.FLASHCARD);
        assertThat(saved.getValue().getIsViewed()).isFalse();

        assertThat(response.getContent()).isEqualTo("Sai nghĩa");
        assertThat(response.getFeedbackFor()).isEqualTo(1);
        assertThat(response.getIsViewed()).isFalse();
        assertThat(response.getItemId()).isEqualTo(card.getId());
        assertThat(response.getItemTitle()).isEqualTo("beautiful");
        assertThat(response.getParentTitle()).isEqualTo("Daily Life");
        assertThat(response.getTopicId()).isEqualTo(topic.getId());
        assertThat(response.getGrammarLessonId()).isNull();
        assertThat(response.getCreatedAt()).isEqualTo(Instant.parse("2026-03-10T10:00:00Z"));
        assertThat(response.getCreatedBy().getId()).isEqualTo(userId);
        assertThat(response.getCreatedBy().getFullName()).isEqualTo("Nguyễn Văn A");
        assertThat(response.getCreatedBy().getEmail()).isEqualTo("a@test.local");
    }

    @Test
    void createGrammarFeedbackUsesLessonTitleAndNoParent() {
        FeedbackResponse response = service.create(userId, request(2, grammar.getId(), "Thiếu ví dụ"));

        assertThat(response.getItemTitle()).isEqualTo("Present Simple");
        assertThat(response.getParentTitle()).isNull();
        assertThat(response.getGrammarLessonId()).isEqualTo(grammar.getId());
        assertThat(response.getTopicId()).isNull();
    }

    @Test
    void createQuizFeedbackShowsOwnerTopicOrGrammarAsItemTitleAndQuizAsParent() {
        FeedbackResponse byTopic = service.create(userId, request(3, topicQuiz.getId(), "câu 1"));
        assertThat(byTopic.getItemTitle()).isEqualTo("Daily Life");
        assertThat(byTopic.getParentTitle()).isEqualTo("Daily Life Quiz");
        assertThat(byTopic.getTopicId()).isEqualTo(topic.getId());
        assertThat(byTopic.getGrammarLessonId()).isNull();

        FeedbackResponse byGrammar = service.create(userId, request(3, grammarQuiz.getId(), "câu 2"));
        assertThat(byGrammar.getItemTitle()).isEqualTo("Present Simple");
        assertThat(byGrammar.getParentTitle()).isEqualTo("Present Simple Quiz");
        assertThat(byGrammar.getGrammarLessonId()).isEqualTo(grammar.getId());
        assertThat(byGrammar.getTopicId()).isNull();
    }

    @Test
    void createRejectsBlankOrTooLongContentAndUnknownType() {
        assertValidationError(() -> service.create(userId, request(1, card.getId(), "   ")));
        assertValidationError(() -> service.create(userId, request(1, card.getId(), null)));
        assertValidationError(() -> service.create(userId, request(1, card.getId(), "x".repeat(1001))));
        // Độ dài tính sau khi trim
        assertValidationError(() -> service.create(userId, request(1, card.getId(), " " + "x".repeat(1001))));
        assertValidationError(() -> service.create(userId, request(4, card.getId(), "ok")));
        assertValidationError(() -> service.create(userId, request(null, card.getId(), "ok")));
        verify(feedbackRepository, never()).save(any());

        // Đúng 1000 ký tự (kể cả có khoảng trắng bao quanh) thì được
        service.create(userId, request(1, card.getId(), "  " + "x".repeat(1000) + "  "));
        verify(feedbackRepository, times(1)).save(any());
    }

    @Test
    void createRequiresExistingNotDeletedItem() {
        UUID missing = UUID.randomUUID();
        assertNotFound(() -> service.create(userId, request(1, missing, "x")));
        assertNotFound(() -> service.create(userId, request(2, missing, "x")));
        assertNotFound(() -> service.create(userId, request(3, missing, "x")));
        // Id của loại này gửi kèm loại khác
        assertNotFound(() -> service.create(userId, request(2, card.getId(), "x")));
        verify(feedbackRepository, never()).save(any());
    }

    @Test
    void createRejectsItemWhoseParentWasDeleted() {
        when(topicRepository.findByIdAndDeletedAtIsNull(topic.getId())).thenReturn(Optional.empty());
        assertNotFound(() -> service.create(userId, request(1, card.getId(), "x")));
        assertNotFound(() -> service.create(userId, request(3, topicQuiz.getId(), "x")));

        when(grammarLessonRepository.findByIdAndDeletedAtIsNull(grammar.getId())).thenReturn(Optional.empty());
        assertNotFound(() -> service.create(userId, request(2, grammar.getId(), "x")));
        assertNotFound(() -> service.create(userId, request(3, grammarQuiz.getId(), "x")));
        verify(feedbackRepository, never()).save(any());
    }

    // ------------------------------------------------------------------ sửa / xoá

    @Test
    void updateSucceedsWhenConditionalUpdateHitsOneRow() {
        UUID id = UUID.randomUUID();
        Feedback stored = stored(id, FeedbackType.FLASHCARD, card.getId(), "bản sửa");
        when(feedbackRepository.updateContentIfNotViewed(eq(id), eq(userId), eq("bản sửa"), any(Instant.class))).thenReturn(1);
        when(feedbackRepository.findById(id)).thenReturn(Optional.of(stored));

        FeedbackResponse response = service.update(userId, id, "  bản sửa ");

        assertThat(response.getContent()).isEqualTo("bản sửa");
        assertThat(response.getItemTitle()).isEqualTo("beautiful");
    }

    @Test
    void updateValidatesContentBeforeTouchingDatabase() {
        UUID id = UUID.randomUUID();
        assertValidationError(() -> service.update(userId, id, "  "));
        assertValidationError(() -> service.update(userId, id, "x".repeat(1001)));
        verify(feedbackRepository, never()).updateContentIfNotViewed(any(), any(), any(), any());
    }

    @Test
    void updateAndDeleteRejectedWith409WhenAlreadyViewed() {
        UUID id = UUID.randomUUID();
        when(feedbackRepository.updateContentIfNotViewed(eq(id), eq(userId), any(), any())).thenReturn(0);
        when(feedbackRepository.deleteIfNotViewed(id, userId)).thenReturn(0);
        when(feedbackRepository.existsByIdAndUserId(id, userId)).thenReturn(true);

        assertThatThrownBy(() -> service.update(userId, id, "muộn"))
                .isInstanceOfSatisfying(BusinessException.class,
                        e -> assertThat(e.getErrorCode()).isEqualTo(ErrorCode.FEEDBACK_ALREADY_VIEWED));
        assertThatThrownBy(() -> service.delete(userId, id))
                .isInstanceOfSatisfying(BusinessException.class,
                        e -> assertThat(e.getErrorCode()).isEqualTo(ErrorCode.FEEDBACK_ALREADY_VIEWED));
        assertThat(ErrorCode.FEEDBACK_ALREADY_VIEWED.getStatus().value()).isEqualTo(409);
    }

    @Test
    void updateAndDeleteReturnNotFoundWhenMissingOrNotOwner() {
        UUID id = UUID.randomUUID();
        when(feedbackRepository.updateContentIfNotViewed(eq(id), eq(userId), any(), any())).thenReturn(0);
        when(feedbackRepository.deleteIfNotViewed(id, userId)).thenReturn(0);
        when(feedbackRepository.existsByIdAndUserId(id, userId)).thenReturn(false);

        assertNotFound(() -> service.update(userId, id, "x"));
        assertNotFound(() -> service.delete(userId, id));
    }

    @Test
    void deleteSucceedsWhenConditionalDeleteHitsOneRow() {
        UUID id = UUID.randomUUID();
        when(feedbackRepository.deleteIfNotViewed(id, userId)).thenReturn(1);

        service.delete(userId, id);

        verify(feedbackRepository, never()).existsByIdAndUserId(any(), any());
    }

    // ------------------------------------------------------------------ admin

    @Test
    void setViewedUpdatesAndReturnsFeedback() {
        UUID id = UUID.randomUUID();
        Feedback stored = stored(id, FeedbackType.GRAMMAR, grammar.getId(), "x");
        stored.setIsViewed(true);
        when(feedbackRepository.updateViewed(eq(id), eq(true), any(Instant.class))).thenReturn(1);
        when(feedbackRepository.findById(id)).thenReturn(Optional.of(stored));

        assertThat(service.setViewed(id, true).getIsViewed()).isTrue();
    }

    @Test
    void setViewedOnMissingFeedbackIsNotFound() {
        when(feedbackRepository.updateViewed(any(), anyBoolean(), any())).thenReturn(0);
        assertNotFound(() -> service.setViewed(UUID.randomUUID(), true));
    }

    // ------------------------------------------------------------------ danh sách / lọc

    @Test
    void listMineRestrictsToOwnerAndSortsNewestFirst() {
        stubPage(List.of());

        service.listMine(userId, null, null, null, 2, 15);

        Pageable pageable = capturePageable();
        assertThat(pageable.getPageNumber()).isEqualTo(2);
        assertThat(pageable.getPageSize()).isEqualTo(15);
        assertThat(pageable.getSort().getOrderFor("createdAt").getDirection()).isEqualTo(Sort.Direction.DESC);

        CriteriaBuilder cb = apply(captureSpec());
        verify(cb).equal(any(), eq(userId));
        verify(cb, never()).equal(any(), eq(FeedbackType.FLASHCARD));
        verify(cb, never()).greaterThanOrEqualTo(ArgumentMatchers.<Expression<Instant>>any(), any(Instant.class));
        verify(cb, never()).lessThan(ArgumentMatchers.<Expression<Instant>>any(), any(Instant.class));
    }

    @Test
    void listMineFiltersByTypeAndDayRangeInUserTimezoneInclusiveOfToDay() {
        stubPage(List.of());

        service.listMine(userId, 1, LocalDate.of(2026, 3, 11), LocalDate.of(2026, 3, 11), 0, 20);

        CriteriaBuilder cb = apply(captureSpec());
        verify(cb).equal(any(), eq(FeedbackType.FLASHCARD));
        // 11/03 theo Asia/Ho_Chi_Minh (UTC+7) = [10/03 17:00Z, 11/03 17:00Z)
        verify(cb).greaterThanOrEqualTo(ArgumentMatchers.<Expression<Instant>>any(), eq(Instant.parse("2026-03-10T17:00:00Z")));
        verify(cb).lessThan(ArgumentMatchers.<Expression<Instant>>any(), eq(Instant.parse("2026-03-11T17:00:00Z")));
    }

    @Test
    void dayRangeFollowsTheTimezoneOfTheRequester() {
        user.setTimezone("America/New_York");
        stubPage(List.of());

        service.listMine(userId, null, LocalDate.of(2026, 1, 5), null, 0, 20);

        CriteriaBuilder cb = apply(captureSpec());
        verify(cb).greaterThanOrEqualTo(ArgumentMatchers.<Expression<Instant>>any(), eq(Instant.parse("2026-01-05T05:00:00Z")));
        verify(cb, never()).lessThan(ArgumentMatchers.<Expression<Instant>>any(), any(Instant.class));
    }

    @Test
    void onlyToDateGivesExclusiveUpperBound() {
        stubPage(List.of());

        service.listMine(userId, null, null, LocalDate.of(2026, 3, 10), 0, 20);

        CriteriaBuilder cb = apply(captureSpec());
        verify(cb).lessThan(ArgumentMatchers.<Expression<Instant>>any(), eq(Instant.parse("2026-03-10T17:00:00Z")));
        verify(cb, never()).greaterThanOrEqualTo(ArgumentMatchers.<Expression<Instant>>any(), any(Instant.class));
    }

    @Test
    void listRejectsFromAfterToAndUnknownType() {
        assertValidationError(() -> service.listMine(userId, null, LocalDate.of(2026, 3, 12), LocalDate.of(2026, 3, 11), 0, 20));
        assertValidationError(() -> service.listMine(userId, 7, null, null, 0, 20));
        assertValidationError(() -> service.listAll(userId, 0, null, null, null, 0, 20));
    }

    @Test
    void adminListHasNoOwnerFilterButFiltersByViewedAndType() {
        stubPage(List.of());

        service.listAll(UUID.randomUUID(), 3, false, null, null, 0, 20);

        CriteriaBuilder cb = apply(captureSpec());
        verify(cb, never()).equal(any(), eq(userId));
        verify(cb).equal(any(), eq(FeedbackType.QUIZ));
        verify(cb).equal(any(), eq(false));
    }

    @Test
    void listResolvesDisplayInfoWithOneQueryPerKindNotPerRow() {
        Feedback f1 = stored(UUID.randomUUID(), FeedbackType.FLASHCARD, card.getId(), "1");
        Feedback f2 = stored(UUID.randomUUID(), FeedbackType.FLASHCARD, card.getId(), "2");
        Feedback f3 = stored(UUID.randomUUID(), FeedbackType.GRAMMAR, grammar.getId(), "3");
        Feedback f4 = stored(UUID.randomUUID(), FeedbackType.QUIZ, topicQuiz.getId(), "4");
        Feedback f5 = stored(UUID.randomUUID(), FeedbackType.QUIZ, grammarQuiz.getId(), "5");
        stubPage(List.of(f1, f2, f3, f4, f5));

        PageResponse<FeedbackResponse> page = service.listMine(userId, null, null, null, 0, 20);

        assertThat(page.getItems()).extracting(FeedbackResponse::getContent).containsExactly("1", "2", "3", "4", "5");
        assertThat(page.getItems()).extracting(FeedbackResponse::getItemTitle)
                .containsExactly("beautiful", "beautiful", "Present Simple", "Daily Life", "Present Simple");
        assertThat(page.getTotalElements()).isEqualTo(5);
        verify(userRepository, times(1)).findAllById(anyList());
        verify(flashcardRepository, times(1)).findAllById(anyList());
        verify(quizRepository, times(1)).findAllById(anyList());
        verify(topicRepository, times(1)).findAllById(anyList());
        verify(grammarLessonRepository, times(1)).findAllById(anyList());
        verify(flashcardRepository, never()).findByIdAndDeletedAtIsNull(any());
        verify(quizRepository, never()).findByIdAndDeletedAtIsNull(any());
    }

    @Test
    void emptyListSkipsAllLookups() {
        stubPage(List.of());

        PageResponse<FeedbackResponse> page = service.listMine(userId, null, null, null, 0, 20);

        assertThat(page.getItems()).isEmpty();
        verify(userRepository, never()).findAllById(anyList());
        verify(flashcardRepository, never()).findAllById(anyList());
    }

    // ------------------------------------------------------------------ summary

    @Test
    void summaryCountsPerTypeAndDefaultsToZero() {
        when(feedbackRepository.countByType(userId)).thenReturn(List.of(
                new Object[]{FeedbackType.FLASHCARD, 3L}, new Object[]{FeedbackType.QUIZ, 1L}));

        FeedbackSummaryResponse summary = service.summary(userId);

        assertThat(summary.getFlashcard()).isEqualTo(3);
        assertThat(summary.getGrammar()).isZero();
        assertThat(summary.getQuiz()).isEqualTo(1);
    }

    // ------------------------------------------------------------------ helpers

    private static FeedbackCreateRequest request(Integer type, UUID itemId, String content) {
        FeedbackCreateRequest request = new FeedbackCreateRequest();
        request.setFeedbackFor(type);
        request.setItemId(itemId);
        request.setContent(content);
        return request;
    }

    private Feedback stored(UUID id, FeedbackType type, UUID itemId, String content) {
        Feedback f = new Feedback();
        f.setId(id);
        f.setUserId(userId);
        f.setFeedbackFor(type);
        f.setItemId(itemId);
        f.setContent(content);
        f.setIsViewed(false);
        f.setCreatedAt(Instant.parse("2026-03-10T10:00:00Z"));
        f.setUpdatedAt(f.getCreatedAt());
        return f;
    }

    @SuppressWarnings("unchecked")
    private void stubPage(List<Feedback> items) {
        Page<Feedback> page = new PageImpl<>(items, org.springframework.data.domain.PageRequest.of(0, 20), items.size());
        when(feedbackRepository.findAll(any(Specification.class), any(Pageable.class))).thenReturn(page);
    }

    @SuppressWarnings("unchecked")
    private Specification<Feedback> captureSpec() {
        ArgumentCaptor<Specification<Feedback>> captor = ArgumentCaptor.forClass(Specification.class);
        verify(feedbackRepository).findAll(captor.capture(), any(Pageable.class));
        return captor.getValue();
    }

    @SuppressWarnings("unchecked")
    private Pageable capturePageable() {
        ArgumentCaptor<Pageable> captor = ArgumentCaptor.forClass(Pageable.class);
        verify(feedbackRepository).findAll(any(Specification.class), captor.capture());
        return captor.getValue();
    }

    /** Chạy Specification trên CriteriaBuilder giả để biết nó dựng những điều kiện nào. */
    @SuppressWarnings("unchecked")
    private static CriteriaBuilder apply(Specification<Feedback> spec) {
        CriteriaBuilder cb = mock(CriteriaBuilder.class);
        spec.toPredicate(mock(Root.class), mock(CriteriaQuery.class), cb);
        return cb;
    }

    private static void assertValidationError(org.assertj.core.api.ThrowableAssert.ThrowingCallable call) {
        assertThatThrownBy(call).isInstanceOfSatisfying(BusinessException.class,
                e -> assertThat(e.getErrorCode()).isEqualTo(ErrorCode.VALIDATION_ERROR));
    }

    private static void assertNotFound(org.assertj.core.api.ThrowableAssert.ThrowingCallable call) {
        assertThatThrownBy(call).isInstanceOfSatisfying(BusinessException.class,
                e -> assertThat(e.getErrorCode()).isEqualTo(ErrorCode.NOT_FOUND));
    }
}
