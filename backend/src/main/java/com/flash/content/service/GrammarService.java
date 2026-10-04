package com.flash.content.service;

import com.flash.common.PageResponse;
import com.flash.common.enums.CefrLevel;
import com.flash.common.enums.ProgressFilter;
import com.flash.content.dto.GrammarDetailResponse;
import com.flash.content.dto.GrammarExampleResponse;
import com.flash.content.dto.GrammarRequest;
import com.flash.content.dto.GrammarResponse;
import com.flash.content.entity.GrammarExample;
import com.flash.content.entity.GrammarLesson;
import com.flash.content.entity.Quiz;
import com.flash.content.repository.GrammarExampleRepository;
import com.flash.content.repository.GrammarLessonRepository;
import com.flash.content.repository.QuizRepository;
import com.flash.progress.entity.UserGrammarProgress;
import com.flash.progress.repository.UserGrammarProgressRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.Instant;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class GrammarService {

    private final GrammarLessonRepository grammarLessonRepository;
    private final GrammarExampleRepository exampleRepository;
    private final UserGrammarProgressRepository progressRepository;
    private final QuizRepository quizRepository;
    private final ContentLookup contentLookup;

    @Transactional(readOnly = true)
    public PageResponse<GrammarResponse> list(UUID userId, String keyword, ProgressFilter filter,
                                              boolean includeUnpublished, Pageable pageable) {
        String normalizedKeyword = StringUtils.hasText(keyword) ? keyword.trim() : null;
        return PageResponse.of(grammarLessonRepository.searchWithProgress(userId, normalizedKeyword,
                        includeUnpublished, filter.isAll(), filter.statuses(), filter.includesMissingProgress(), pageable)
                .map(row -> GrammarResponse.of((GrammarLesson) row[0], (UserGrammarProgress) row[1], includeUnpublished)));
    }

    @Transactional(readOnly = true)
    public GrammarDetailResponse get(UUID userId, UUID id, boolean isAdmin) {
        GrammarLesson lesson = contentLookup.grammar(id, isAdmin);
        UserGrammarProgress progress = progressRepository.findByUserIdAndGrammarLessonId(userId, id).orElse(null);
        return detail(lesson, progress, isAdmin);
    }

    @Transactional
    public GrammarDetailResponse create(GrammarRequest request) {
        GrammarLesson lesson = new GrammarLesson();
        apply(lesson, request);
        grammarLessonRepository.save(lesson);
        replaceExamples(lesson.getId(), request.getExamples());
        return detail(lesson, null, true);
    }

    @Transactional
    public GrammarDetailResponse update(UUID id, GrammarRequest request) {
        GrammarLesson lesson = contentLookup.grammar(id, true);
        apply(lesson, request);
        grammarLessonRepository.saveAndFlush(lesson);
        replaceExamples(id, request.getExamples());
        return detail(lesson, null, true);
    }

    @Transactional
    public void delete(UUID id) {
        contentLookup.grammar(id, true).setDeletedAt(Instant.now());
    }

    private GrammarDetailResponse detail(GrammarLesson lesson, UserGrammarProgress progress, boolean forAdmin) {
        List<GrammarExampleResponse> examples = exampleRepository
                .findByGrammarLessonIdAndDeletedAtIsNullOrderBySortOrder(lesson.getId()).stream()
                .map(GrammarExampleResponse::from)
                .collect(Collectors.toList());
        UUID quizId = quizRepository
                .findFirstByGrammarLessonIdAndIsPublishedTrueAndDeletedAtIsNullOrderByCreatedAt(lesson.getId())
                .map(Quiz::getId)
                .orElse(null);
        return new GrammarDetailResponse(GrammarResponse.of(lesson, progress, forAdmin),
                lesson.getContent(), lesson.getUsageNotes(), examples, quizId);
    }

    /** Xoá mềm ví dụ cũ (để client đồng bộ biết) rồi thêm danh sách mới theo đúng thứ tự gửi lên. */
    private void replaceExamples(UUID lessonId, List<GrammarRequest.Example> examples) {
        exampleRepository.softDeleteByLesson(lessonId, Instant.now());
        int order = 1;
        for (GrammarRequest.Example item : examples) {
            GrammarExample example = new GrammarExample();
            example.setGrammarLessonId(lessonId);
            example.setSentence(item.getSentence().trim());
            example.setTranslation(item.getTranslation());
            example.setHighlight(item.getHighlight());
            example.setSortOrder(order++);
            exampleRepository.save(example);
        }
    }

    private static void apply(GrammarLesson lesson, GrammarRequest request) {
        lesson.setTitle(request.getTitle().trim());
        lesson.setDescription(request.getDescription());
        lesson.setStructure(request.getStructure().trim());
        lesson.setContent(request.getContent());
        lesson.setUsageNotes(request.getUsageNotes());
        lesson.setIconName(request.getIconName().trim());
        lesson.setLevel(request.getLevel() != null ? request.getLevel() : CefrLevel.A1);
        lesson.setCoverColor(request.getCoverColor());
        lesson.setEstimatedMinutes(request.getEstimatedMinutes() != null ? request.getEstimatedMinutes() : 10);
        lesson.setSortOrder(request.getSortOrder() != null ? request.getSortOrder() : 0);
        lesson.setIsPublished(Boolean.TRUE.equals(request.getIsPublished()));
    }
}
