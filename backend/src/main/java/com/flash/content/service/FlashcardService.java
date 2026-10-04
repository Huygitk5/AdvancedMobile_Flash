package com.flash.content.service;

import com.flash.common.BusinessException;
import com.flash.common.ErrorCode;
import com.flash.common.PageResponse;
import com.flash.content.dto.FlashcardRequest;
import com.flash.content.dto.FlashcardResponse;
import com.flash.content.entity.Flashcard;
import com.flash.content.repository.FlashcardRepository;
import com.flash.content.repository.TopicRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FlashcardService {

    /** Ký tự toán tử của FULLTEXT BOOLEAN MODE, bỏ đi để từ khoá của user không phá cú pháp. */
    private static final String FULLTEXT_OPERATORS = "[+\\-<>()~*\"@]";

    private final FlashcardRepository flashcardRepository;
    private final TopicRepository topicRepository;
    private final ContentLookup contentLookup;

    @Transactional(readOnly = true)
    public List<FlashcardResponse> listByTopic(UUID userId, UUID topicId, boolean isAdmin) {
        contentLookup.topic(topicId, isAdmin);
        return flashcardRepository.findByTopicWithUserState(topicId, userId).stream()
                .map(FlashcardResponse::fromRow)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public FlashcardResponse get(UUID userId, UUID id, boolean isAdmin) {
        Object[] row = flashcardRepository.findByIdsWithUserState(List.of(id), userId).stream()
                .findFirst()
                .orElseThrow(() -> new BusinessException(ErrorCode.NOT_FOUND, "Không tìm thấy từ vựng"));
        contentLookup.topic(((Flashcard) row[0]).getTopicId(), isAdmin);
        return FlashcardResponse.fromRow(row);
    }

    /** Tìm theo từ tiếng Anh hoặc nghĩa tiếng Việt, trong các topic đã xuất bản. */
    @Transactional(readOnly = true)
    public PageResponse<FlashcardResponse> search(UUID userId, String keyword, int page, int size) {
        String raw = keyword.trim();
        String terms = Arrays.stream(raw.replaceAll(FULLTEXT_OPERATORS, " ").split("\\s+"))
                .filter(w -> !w.isEmpty())
                .map(w -> "+" + w + "*")
                .collect(Collectors.joining(" "));
        if (terms.isEmpty()) {
            return new PageResponse<>(Collections.emptyList(), page, size, 0, 0);
        }
        String prefix = escapeLike(raw) + "%";

        long total = flashcardRepository.countSearch(terms, prefix);
        List<UUID> ids = flashcardRepository.searchIds(terms, prefix, raw, size, (long) page * size).stream()
                .map(UUID::fromString)
                .collect(Collectors.toList());
        if (ids.isEmpty()) {
            return new PageResponse<>(Collections.emptyList(), page, size, total, totalPages(total, size));
        }

        // Lấy trạng thái user cho các id tìm được, rồi giữ đúng thứ tự xếp hạng của câu tìm kiếm
        Map<UUID, FlashcardResponse> byId = flashcardRepository.findByIdsWithUserState(ids, userId).stream()
                .map(FlashcardResponse::fromRow)
                .collect(Collectors.toMap(FlashcardResponse::getId, Function.identity()));
        List<FlashcardResponse> items = ids.stream().map(byId::get).filter(r -> r != null).collect(Collectors.toList());
        return new PageResponse<>(items, page, size, total, totalPages(total, size));
    }

    /**
     * Tạo từ mới. Nếu từ này từng bị xoá mềm trong cùng topic thì khôi phục dòng cũ,
     * vì UNIQUE(topic_id, word) vẫn tính cả dòng đã xoá.
     */
    @Transactional
    public FlashcardResponse create(FlashcardRequest request) {
        contentLookup.topic(request.getTopicId(), true);
        String word = request.getWord().trim();
        Flashcard card = flashcardRepository.findByTopicIdAndWord(request.getTopicId(), word)
                .map(existing -> {
                    if (existing.getDeletedAt() == null) {
                        throw new BusinessException(ErrorCode.CONFLICT, "Từ \"" + word + "\" đã có trong chủ đề này");
                    }
                    existing.setDeletedAt(null);
                    return existing;
                })
                .orElseGet(Flashcard::new);
        apply(card, request);
        flashcardRepository.save(card);
        topicRepository.recountTotalWords(card.getTopicId());
        return FlashcardResponse.content(card);
    }

    @Transactional
    public FlashcardResponse update(UUID id, FlashcardRequest request) {
        Flashcard card = flashcardRepository.findByIdAndDeletedAtIsNull(id)
                .orElseThrow(() -> new BusinessException(ErrorCode.NOT_FOUND, "Không tìm thấy từ vựng"));
        contentLookup.topic(request.getTopicId(), true);
        UUID oldTopicId = card.getTopicId();
        apply(card, request);
        flashcardRepository.saveAndFlush(card);
        topicRepository.recountTotalWords(card.getTopicId());
        if (!oldTopicId.equals(card.getTopicId())) {
            topicRepository.recountTotalWords(oldTopicId);
        }
        return FlashcardResponse.content(card);
    }

    @Transactional
    public void delete(UUID id) {
        Flashcard card = flashcardRepository.findByIdAndDeletedAtIsNull(id)
                .orElseThrow(() -> new BusinessException(ErrorCode.NOT_FOUND, "Không tìm thấy từ vựng"));
        card.setDeletedAt(Instant.now());
        topicRepository.recountTotalWords(card.getTopicId());
    }

    private static void apply(Flashcard card, FlashcardRequest request) {
        card.setTopicId(request.getTopicId());
        card.setWord(request.getWord().trim());
        card.setPartOfSpeech(request.getPartOfSpeech().trim());
        card.setPronunciation(request.getPronunciation().trim());
        card.setMeaning(request.getMeaning().trim());
        card.setExample(request.getExample());
        card.setExampleTranslation(request.getExampleTranslation());
        card.setAudioUrl(request.getAudioUrl());
        card.setImageUrl(request.getImageUrl());
        card.setSortOrder(request.getSortOrder() != null ? request.getSortOrder() : 0);
    }

    private static String escapeLike(String value) {
        return value.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_");
    }

    private static int totalPages(long total, int size) {
        return (int) ((total + size - 1) / size);
    }
}
