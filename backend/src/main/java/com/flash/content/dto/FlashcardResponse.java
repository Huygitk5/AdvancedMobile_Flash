package com.flash.content.dto;

import com.flash.content.entity.Flashcard;
import com.flash.progress.entity.SrsRating;
import com.flash.progress.entity.UserBookmark;
import com.flash.progress.entity.UserFlashcardNote;
import com.flash.progress.entity.UserFlashcardProgress;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.util.UUID;

/** Khớp model Flashcard bên Flutter, kèm ghi chú / bookmark / SRS của user hiện tại. */
@Getter
@Builder
public class FlashcardResponse {

    private final UUID id;
    private final UUID topicId;
    private final String word;
    private final String partOfSpeech;
    private final String pronunciation;
    private final String meaning;
    private final String example;
    private final String exampleTranslation;
    private final String audioUrl;
    private final String imageUrl;
    private final Integer sortOrder;

    // --- Trạng thái của user (null với response cho admin) ---
    private final String note;
    private final Integer noteVersion;
    private final Boolean isBookmarked;
    private final Integer srsBox;
    private final Boolean isLearned;
    private final SrsRating lastRating;
    private final Instant dueAt;

    public static FlashcardResponse of(Flashcard card, UserFlashcardProgress progress,
                                       UserFlashcardNote note, UserBookmark bookmark) {
        return base(card)
                .note(note != null ? note.getContent() : null)
                .noteVersion(note != null ? note.getVersion() : null)
                .isBookmarked(bookmark != null)
                .srsBox(progress != null ? progress.getBox() : 0)
                .isLearned(progress != null && progress.getIsLearned())
                .lastRating(progress != null ? progress.getLastRating() : null)
                .dueAt(progress != null ? progress.getDueAt() : null)
                .build();
    }

    /** Dùng cho API admin: chỉ nội dung, không có trạng thái user. */
    public static FlashcardResponse content(Flashcard card) {
        return base(card).build();
    }

    /** Dòng kết quả của FlashcardRepository.WITH_USER_STATE. */
    public static FlashcardResponse fromRow(Object[] row) {
        return of((Flashcard) row[0], (UserFlashcardProgress) row[1], (UserFlashcardNote) row[2], (UserBookmark) row[3]);
    }

    private static FlashcardResponseBuilder base(Flashcard card) {
        return FlashcardResponse.builder()
                .id(card.getId())
                .topicId(card.getTopicId())
                .word(card.getWord())
                .partOfSpeech(card.getPartOfSpeech())
                .pronunciation(card.getPronunciation())
                .meaning(card.getMeaning())
                .example(card.getExample())
                .exampleTranslation(card.getExampleTranslation())
                .audioUrl(card.getAudioUrl())
                .imageUrl(card.getImageUrl())
                .sortOrder(card.getSortOrder());
    }
}
