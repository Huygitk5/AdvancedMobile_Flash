package com.flash.content.entity;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.Type;

import javax.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "flashcards")
@Getter
@Setter
@NoArgsConstructor
public class Flashcard {

    @Id
    @Type(type = "uuid-char")
    @Column(columnDefinition = "char")
    private UUID id;

    @Type(type = "uuid-char")
    @Column(columnDefinition = "char", nullable = false)
    private UUID topicId;

    @Column(nullable = false)
    private String word;

    @Column(nullable = false)
    private String partOfSpeech;

    @Column(nullable = false)
    private String pronunciation;

    @Column(nullable = false)
    private String meaning;

    @Column(columnDefinition = "text")
    private String example;

    @Column(columnDefinition = "text")
    private String exampleTranslation;

    private String audioUrl;

    private String imageUrl;

    @Column(nullable = false)
    private Integer sortOrder = 0;

    @Version
    private Integer version;

    @Column(insertable = false, updatable = false)
    private Instant createdAt;

    @Column(insertable = false, updatable = false)
    private Instant updatedAt;

    private Instant deletedAt;

    @PrePersist
    void ensureId() {
        if (id == null) {
            id = UUID.randomUUID();
        }
    }
}
