package com.flash.feedback.service;

import com.flash.common.BusinessException;
import com.flash.common.ErrorCode;
import com.flash.common.PageResponse;
import com.flash.common.util.Zones;
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
import com.flash.feedback.repository.FeedbackSpecs;
import com.flash.user.entity.User;
import com.flash.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Collection;
import java.util.EnumMap;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * Feedback của user về flashcard / grammar / quiz, và phía admin đánh dấu đã xem.
 * Việc xoá feedback khi item bị xoá nằm ở {@link FeedbackCleanup}.
 */
@Service
@RequiredArgsConstructor
public class FeedbackService {

    public static final int MAX_CONTENT_LENGTH = 1000;

    /** Hiển thị khi item không còn (chỉ xảy ra nếu dữ liệu lệch, VD đang xoá thì có người đọc). */
    static final String MISSING_ITEM_TITLE = "[Nội dung đã bị xoá]";

    private static final Sort NEWEST_FIRST = Sort.by(Sort.Order.desc("createdAt"), Sort.Order.desc("id"));

    private final FeedbackRepository feedbackRepository;
    private final FlashcardRepository flashcardRepository;
    private final GrammarLessonRepository grammarLessonRepository;
    private final QuizRepository quizRepository;
    private final TopicRepository topicRepository;
    private final UserRepository userRepository;

    // ------------------------------------------------------------------ user

    @Transactional
    public FeedbackResponse create(UUID userId, FeedbackCreateRequest request) {
        FeedbackType type = FeedbackType.fromCode(request.getFeedbackFor());
        String content = normalizeContent(request.getContent());
        requireItemExists(type, request.getItemId());

        Feedback feedback = new Feedback();
        feedback.setUserId(userId);
        feedback.setContent(content);
        feedback.setFeedbackFor(type);
        feedback.setItemId(request.getItemId());
        feedback.setIsViewed(false);
        feedbackRepository.save(feedback);
        return toResponses(List.of(feedback)).get(0);
    }

    @Transactional(readOnly = true)
    public PageResponse<FeedbackResponse> listMine(UUID userId, Integer feedbackFor, LocalDate from, LocalDate to,
                                                   int page, int size) {
        return search(userId, userId, feedbackFor, null, from, to, page, size);
    }

    @Transactional(readOnly = true)
    public FeedbackSummaryResponse summary(UUID userId) {
        Map<FeedbackType, Long> counts = new EnumMap<>(FeedbackType.class);
        for (Object[] row : feedbackRepository.countByType(userId)) {
            counts.put((FeedbackType) row[0], (Long) row[1]);
        }
        return new FeedbackSummaryResponse(
                counts.getOrDefault(FeedbackType.FLASHCARD, 0L).intValue(),
                counts.getOrDefault(FeedbackType.GRAMMAR, 0L).intValue(),
                counts.getOrDefault(FeedbackType.QUIZ, 0L).intValue());
    }

    /** Chỉ chủ sở hữu và khi chưa được xem: một câu UPDATE có điều kiện nên không race với admin. */
    @Transactional
    public FeedbackResponse update(UUID userId, UUID id, String rawContent) {
        String content = normalizeContent(rawContent);
        int updated = feedbackRepository.updateContentIfNotViewed(id, userId, content,
                Instant.now().truncatedTo(ChronoUnit.MILLIS));
        if (updated == 0) {
            throw notEditable(id, userId);
        }
        return toResponses(List.of(findOrThrow(id))).get(0);
    }

    @Transactional
    public void delete(UUID userId, UUID id) {
        if (feedbackRepository.deleteIfNotViewed(id, userId) == 0) {
            throw notEditable(id, userId);
        }
    }

    // ------------------------------------------------------------------ admin

    @Transactional(readOnly = true)
    public PageResponse<FeedbackResponse> listAll(UUID adminId, Integer feedbackFor, Boolean isViewed,
                                                  LocalDate from, LocalDate to, int page, int size) {
        return search(adminId, null, feedbackFor, isViewed, from, to, page, size);
    }

    @Transactional
    public FeedbackResponse setViewed(UUID id, boolean viewed) {
        if (feedbackRepository.updateViewed(id, viewed, Instant.now().truncatedTo(ChronoUnit.MILLIS)) == 0) {
            throw new BusinessException(ErrorCode.NOT_FOUND, "Không tìm thấy phản hồi");
        }
        return toResponses(List.of(findOrThrow(id))).get(0);
    }

    // ------------------------------------------------------------------ nội bộ

    /** Update/delete có điều kiện trúng 0 dòng: không có / không phải của mình -> 404, còn lại là đã được xem -> 409. */
    private BusinessException notEditable(UUID id, UUID userId) {
        if (feedbackRepository.existsByIdAndUserId(id, userId)) {
            return new BusinessException(ErrorCode.FEEDBACK_ALREADY_VIEWED);
        }
        return new BusinessException(ErrorCode.NOT_FOUND, "Không tìm thấy phản hồi");
    }

    private Feedback findOrThrow(UUID id) {
        return feedbackRepository.findById(id)
                .orElseThrow(() -> new BusinessException(ErrorCode.NOT_FOUND, "Không tìm thấy phản hồi"));
    }

    private static String normalizeContent(String raw) {
        String content = raw == null ? "" : raw.trim();
        if (content.isEmpty()) {
            throw new BusinessException(ErrorCode.VALIDATION_ERROR, "Nội dung phản hồi không được để trống");
        }
        if (content.length() > MAX_CONTENT_LENGTH) {
            throw new BusinessException(ErrorCode.VALIDATION_ERROR,
                    "Nội dung phản hồi tối đa " + MAX_CONTENT_LENGTH + " ký tự");
        }
        return content;
    }

    /** Item phải còn (chưa xoá mềm) và nơi nó thuộc về cũng còn, vì item của topic/bài đã xoá không còn hiển thị. */
    private void requireItemExists(FeedbackType type, UUID itemId) {
        boolean exists;
        switch (type) {
            case FLASHCARD:
                exists = flashcardRepository.findByIdAndDeletedAtIsNull(itemId)
                        .map(card -> topicRepository.findByIdAndDeletedAtIsNull(card.getTopicId()).isPresent())
                        .orElse(false);
                break;
            case GRAMMAR:
                exists = grammarLessonRepository.findByIdAndDeletedAtIsNull(itemId).isPresent();
                break;
            default:
                exists = quizRepository.findByIdAndDeletedAtIsNull(itemId)
                        .map(this::parentExists)
                        .orElse(false);
                break;
        }
        if (!exists) {
            throw new BusinessException(ErrorCode.NOT_FOUND, "Không tìm thấy nội dung cần phản hồi");
        }
    }

    private boolean parentExists(Quiz quiz) {
        if (quiz.getQuizType() == QuizType.TOPIC) {
            return quiz.getTopicId() != null && topicRepository.findByIdAndDeletedAtIsNull(quiz.getTopicId()).isPresent();
        }
        return quiz.getGrammarLessonId() != null
                && grammarLessonRepository.findByIdAndDeletedAtIsNull(quiz.getGrammarLessonId()).isPresent();
    }

    /**
     * Ngày from/to diễn giải theo múi giờ của người gọi (users.timezone), to tính trọn ngày.
     * requesterId chỉ dùng để lấy múi giờ; ownerId != null thì chỉ lấy feedback của user đó.
     */
    private PageResponse<FeedbackResponse> search(UUID requesterId, UUID ownerId, Integer feedbackFor, Boolean isViewed,
                                                  LocalDate from, LocalDate to, int page, int size) {
        FeedbackType type = feedbackFor == null ? null : FeedbackType.fromCode(feedbackFor);
        if (from != null && to != null && from.isAfter(to)) {
            throw new BusinessException(ErrorCode.VALIDATION_ERROR, "from không được sau to");
        }
        Instant fromInclusive = null;
        Instant toExclusive = null;
        if (from != null || to != null) {
            ZoneId zone = userRepository.findByIdAndDeletedAtIsNull(requesterId)
                    .map(Zones::of).orElse(Zones.DEFAULT_ZONE);
            fromInclusive = from == null ? null : from.atStartOfDay(zone).toInstant();
            toExclusive = to == null ? null : to.plusDays(1).atStartOfDay(zone).toInstant();
        }
        Page<Feedback> result = feedbackRepository.findAll(
                FeedbackSpecs.filter(ownerId, type, isViewed, fromInclusive, toExclusive),
                PageRequest.of(page, size, NEWEST_FIRST));
        return new PageResponse<>(toResponses(result.getContent()), result.getNumber(), result.getSize(),
                result.getTotalElements(), result.getTotalPages());
    }

    /**
     * Ghép thông tin hiển thị không N+1: gom id theo loại, mỗi loại một query IN rồi ghép trong bộ nhớ.
     * Tối đa 5 query: user, flashcard, quiz, rồi topic và grammar (id lấy từ flashcard / quiz).
     */
    private List<FeedbackResponse> toResponses(List<Feedback> feedbacks) {
        if (feedbacks.isEmpty()) {
            return List.of();
        }
        Map<UUID, User> users = byId(userRepository, ids(feedbacks, Feedback::getUserId), User::getId);
        Map<UUID, Flashcard> flashcards = byId(flashcardRepository, itemIds(feedbacks, FeedbackType.FLASHCARD),
                Flashcard::getId);
        Map<UUID, Quiz> quizzes = byId(quizRepository, itemIds(feedbacks, FeedbackType.QUIZ), Quiz::getId);

        List<UUID> topicIds = new ArrayList<>();
        flashcards.values().forEach(c -> topicIds.add(c.getTopicId()));
        quizzes.values().forEach(q -> topicIds.add(q.getTopicId()));
        List<UUID> grammarIds = new ArrayList<>(itemIds(feedbacks, FeedbackType.GRAMMAR));
        quizzes.values().forEach(q -> grammarIds.add(q.getGrammarLessonId()));
        Map<UUID, Topic> topics = byId(topicRepository, topicIds, Topic::getId);
        Map<UUID, GrammarLesson> grammars = byId(grammarLessonRepository, grammarIds, GrammarLesson::getId);

        return feedbacks.stream().map(f -> {
            FeedbackResponse.FeedbackResponseBuilder b = FeedbackResponse.builder()
                    .id(f.getId())
                    .createdBy(creator(f.getUserId(), users.get(f.getUserId())))
                    .createdAt(f.getCreatedAt())
                    .content(f.getContent())
                    .feedbackFor(f.getFeedbackFor().getCode())
                    .itemId(f.getItemId())
                    .isViewed(f.getIsViewed())
                    .itemTitle(MISSING_ITEM_TITLE);
            switch (f.getFeedbackFor()) {
                case FLASHCARD:
                    Flashcard card = flashcards.get(f.getItemId());
                    if (card != null) {
                        Topic topic = topics.get(card.getTopicId());
                        b.itemTitle(card.getWord())
                                .parentTitle(topic != null ? topic.getTitle() : null)
                                .topicId(card.getTopicId());
                    }
                    break;
                case GRAMMAR:
                    GrammarLesson lesson = grammars.get(f.getItemId());
                    b.itemTitle(lesson != null ? lesson.getTitle() : MISSING_ITEM_TITLE)
                            .grammarLessonId(f.getItemId());
                    break;
                default:
                    Quiz quiz = quizzes.get(f.getItemId());
                    if (quiz != null) {
                        String parent = quiz.getQuizType() == QuizType.TOPIC
                                ? titleOf(topics.get(quiz.getTopicId()), Topic::getTitle)
                                : titleOf(grammars.get(quiz.getGrammarLessonId()), GrammarLesson::getTitle);
                        b.itemTitle(parent != null ? parent : MISSING_ITEM_TITLE)
                                .parentTitle(quiz.getTitle())
                                .topicId(quiz.getTopicId())
                                .grammarLessonId(quiz.getGrammarLessonId());
                    }
                    break;
            }
            return b.build();
        }).collect(Collectors.toList());
    }

    private static FeedbackResponse.CreatedBy creator(UUID userId, User user) {
        return user == null ? new FeedbackResponse.CreatedBy(userId, null, null)
                : new FeedbackResponse.CreatedBy(user.getId(), user.getFullName(), user.getEmail());
    }

    private static <T> String titleOf(T entity, Function<T, String> title) {
        return entity == null ? null : title.apply(entity);
    }

    private static List<UUID> ids(List<Feedback> feedbacks, Function<Feedback, UUID> getter) {
        return feedbacks.stream().map(getter).distinct().collect(Collectors.toList());
    }

    private static List<UUID> itemIds(List<Feedback> feedbacks, FeedbackType type) {
        return feedbacks.stream().filter(f -> f.getFeedbackFor() == type).map(Feedback::getItemId)
                .distinct().collect(Collectors.toList());
    }

    /** findAllById một lần (bỏ qua null / trùng; rỗng thì không query). */
    private static <T> Map<UUID, T> byId(CrudRepository<T, UUID> repository, Collection<UUID> ids,
                                         Function<T, UUID> idOf) {
        List<UUID> distinct = ids.stream().filter(Objects::nonNull).distinct().collect(Collectors.toList());
        if (distinct.isEmpty()) {
            return Map.of();
        }
        Map<UUID, T> result = new HashMap<>();
        repository.findAllById(distinct).forEach(e -> result.put(idOf.apply(e), e));
        return result;
    }
}
