package com.flash.progress.dto;

import com.flash.progress.entity.UserFlashcardNote;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.util.UUID;

@Getter
@Builder
public class NoteResponse {

    private final UUID noteId;
    private final UUID flashcardId;
    private final String content;
    private final Integer version;
    private final Instant clientUpdatedAt;

    /** Khác null = ghi chú đã bị xoá (tombstone). */
    private final Instant deletedAt;

    public static NoteResponse from(UserFlashcardNote note) {
        return NoteResponse.builder()
                .noteId(note.getId())
                .flashcardId(note.getFlashcardId())
                .content(note.getContent())
                .version(note.getVersion())
                .clientUpdatedAt(note.getClientUpdatedAt())
                .deletedAt(note.getDeletedAt())
                .build();
    }
}
