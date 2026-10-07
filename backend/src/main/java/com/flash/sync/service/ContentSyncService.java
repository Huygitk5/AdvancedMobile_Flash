package com.flash.sync.service;

import com.flash.content.entity.Flashcard;
import com.flash.content.entity.GrammarExample;
import com.flash.content.entity.GrammarLesson;
import com.flash.content.entity.Quiz;
import com.flash.content.entity.QuizQuestion;
import com.flash.content.entity.QuizQuestionOption;
import com.flash.content.entity.Topic;
import com.flash.content.repository.QuizQuestionOptionRepository;
import com.flash.gamification.dto.QuestDefinitionResponse;
import com.flash.gamification.entity.QuestDefinition;
import com.flash.gamification.entity.RewardItem;
import com.flash.gamification.service.RewardItemService;
import com.flash.sync.dto.ContentChanges;
import com.flash.sync.dto.SyncPullResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.persistence.EntityManager;
import java.time.Instant;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.function.Function;
import java.util.function.Predicate;
import java.util.stream.Collectors;

/**
 * GET /v1/sync/content: delta nội dung học (dùng chung cho mọi user).
 * <p>
 * Client chỉ giữ nội dung đang hiển thị: topic / chủ điểm đã xuất bản và chưa xoá; quiz đã xuất bản có cha
 * đang hiển thị; thẻ / ví dụ / câu hỏi chưa xoá có cha đang hiển thị. Dòng đã đổi mà không còn hiển thị
 * thì nằm trong {@code deleted}.
 * <p>
 * Ẩn rồi xuất bản lại một topic chỉ đổi updated_at của topic chứ không đổi các thẻ bên dưới (client đã xoá
 * chúng theo cascade), nên cha nào có trong delta thì gửi kèm toàn bộ con đang hiển thị của nó.
 */
@Service
@RequiredArgsConstructor
public class ContentSyncService {

    private final DeltaReader deltaReader;
    private final EntityManager entityManager;
    private final QuizQuestionOptionRepository optionRepository;
    private final RewardItemService rewardItemService;

    @Transactional(readOnly = true)
    public SyncPullResponse<ContentChanges> pull(Instant since, int limit) {
        DeltaWindow window = new DeltaWindow(since, limit, Instant.now());
        Set<UUID> visibleTopics = ids("select t.id from Topic t where t.isPublished = true and t.deletedAt is null");
        Set<UUID> visibleLessons = ids("select g.id from GrammarLesson g where g.isPublished = true and g.deletedAt is null");
        Set<UUID> visibleQuizzes = entityManager.createQuery(
                        "select q from Quiz q where q.isPublished = true and q.deletedAt is null", Quiz.class)
                .getResultList().stream()
                .filter(q -> q.getTopicId() != null ? visibleTopics.contains(q.getTopicId())
                        : visibleLessons.contains(q.getGrammarLessonId()))
                .map(Quiz::getId)
                .collect(Collectors.toSet());

        Partition<Topic> topics = partition(
                deltaReader.read(window, Topic.class, null, Map.of(), Topic::getUpdatedAt),
                Topic::getId, t -> visibleTopics.contains(t.getId()));
        Partition<GrammarLesson> lessons = partition(
                deltaReader.read(window, GrammarLesson.class, null, Map.of(), GrammarLesson::getUpdatedAt),
                GrammarLesson::getId, g -> visibleLessons.contains(g.getId()));
        Set<UUID> shownTopics = idsOf(topics.visible, Topic::getId);
        Set<UUID> shownLessons = idsOf(lessons.visible, GrammarLesson::getId);

        Partition<Quiz> quizzes = partition(merge(Quiz::getId,
                        deltaReader.read(window, Quiz.class, null, Map.of(), Quiz::getUpdatedAt),
                        childrenOf(Quiz.class, "topicId", shownTopics),
                        childrenOf(Quiz.class, "grammarLessonId", shownLessons)),
                Quiz::getId, q -> visibleQuizzes.contains(q.getId()));
        Partition<Flashcard> flashcards = partition(merge(Flashcard::getId,
                        deltaReader.read(window, Flashcard.class, null, Map.of(), Flashcard::getUpdatedAt),
                        childrenOf(Flashcard.class, "topicId", shownTopics)),
                Flashcard::getId, f -> f.getDeletedAt() == null && visibleTopics.contains(f.getTopicId()));
        Partition<GrammarExample> examples = partition(merge(GrammarExample::getId,
                        deltaReader.read(window, GrammarExample.class, null, Map.of(), GrammarExample::getUpdatedAt),
                        childrenOf(GrammarExample.class, "grammarLessonId", shownLessons)),
                GrammarExample::getId, e -> e.getDeletedAt() == null && visibleLessons.contains(e.getGrammarLessonId()));
        Partition<QuizQuestion> questions = partition(merge(QuizQuestion::getId,
                        deltaReader.read(window, QuizQuestion.class, null, Map.of(), QuizQuestion::getUpdatedAt),
                        childrenOf(QuizQuestion.class, "quizId", idsOf(quizzes.visible, Quiz::getId))),
                QuizQuestion::getId, q -> q.getDeletedAt() == null && visibleQuizzes.contains(q.getQuizId()));

        ContentChanges changes = ContentChanges.builder()
                .topics(map(topics.visible, ContentChanges.TopicRow::from))
                .flashcards(map(flashcards.visible, ContentChanges.FlashcardRow::from))
                .grammarLessons(map(lessons.visible, ContentChanges.GrammarLessonRow::from))
                .grammarExamples(map(examples.visible, ContentChanges.GrammarExampleRow::from))
                .quizzes(map(quizzes.visible, ContentChanges.QuizRow::from))
                .quizQuestions(withOptions(questions.visible))
                .questDefinitions(map(deltaReader.read(window, QuestDefinition.class, null, Map.of(),
                        QuestDefinition::getUpdatedAt), QuestDefinitionResponse::from))
                .rewardItems(map(deltaReader.read(window, RewardItem.class, null, Map.of(),
                        RewardItem::getUpdatedAt), rewardItemService::toResponse))
                .deleted(ContentChanges.Deleted.builder()
                        .topics(topics.hidden)
                        .flashcards(flashcards.hidden)
                        .grammarLessons(lessons.hidden)
                        .grammarExamples(examples.hidden)
                        .quizzes(quizzes.hidden)
                        .quizQuestions(questions.hidden)
                        .build())
                .build();
        return new SyncPullResponse<>(window.cursor(), window.isHasMore(), changes);
    }

    /** Con chưa bị xoá của các cha có trong delta. */
    private <T> List<T> childrenOf(Class<T> type, String parentField, Set<UUID> parentIds) {
        if (parentIds.isEmpty()) {
            return List.of();
        }
        return entityManager.createQuery("select e from " + type.getSimpleName() + " e where e.deletedAt is null and e."
                        + parentField + " in :parents", type)
                .setParameter("parents", parentIds)
                .getResultList();
    }

    private List<ContentChanges.QuizQuestionRow> withOptions(List<QuizQuestion> questions) {
        if (questions.isEmpty()) {
            return List.of();
        }
        Map<UUID, List<String>> options = optionRepository.findByQuestionIdInOrderByQuestionIdAscOptionIndexAsc(
                        idsOf(questions, QuizQuestion::getId)).stream()
                .collect(Collectors.groupingBy(QuizQuestionOption::getQuestionId,
                        Collectors.mapping(QuizQuestionOption::getOptionText, Collectors.toList())));
        return questions.stream()
                .map(q -> ContentChanges.QuizQuestionRow.from(q, options.getOrDefault(q.getId(), List.of())))
                .collect(Collectors.toList());
    }

    private Set<UUID> ids(String jpql) {
        return Set.copyOf(entityManager.createQuery(jpql, UUID.class).getResultList());
    }

    @SafeVarargs
    private static <T> List<T> merge(Function<T, UUID> id, List<T>... sources) {
        Map<UUID, T> byId = new LinkedHashMap<>();
        for (List<T> source : sources) {
            source.forEach(row -> byId.putIfAbsent(id.apply(row), row));
        }
        return new ArrayList<>(byId.values());
    }

    private static <T> Partition<T> partition(List<T> rows, Function<T, UUID> id, Predicate<T> visible) {
        Partition<T> result = new Partition<>();
        for (T row : rows) {
            if (visible.test(row)) {
                result.visible.add(row);
            } else {
                result.hidden.add(id.apply(row));
            }
        }
        return result;
    }

    private static <T> Set<UUID> idsOf(List<T> rows, Function<T, UUID> id) {
        return rows.stream().map(id).collect(Collectors.toSet());
    }

    private static <T, R> List<R> map(List<T> rows, Function<T, R> mapper) {
        return rows.stream().map(mapper).collect(Collectors.toList());
    }

    private static final class Partition<T> {
        private final List<T> visible = new ArrayList<>();
        private final List<UUID> hidden = new ArrayList<>();
    }
}
