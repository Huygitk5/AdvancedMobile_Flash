package com.flash.progress.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.util.UUID;

/** Khoá chính phức hợp của {@link UserFlashcardProgress}. */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserFlashcardProgressId implements Serializable {

    private UUID userId;
    private UUID flashcardId;
}
