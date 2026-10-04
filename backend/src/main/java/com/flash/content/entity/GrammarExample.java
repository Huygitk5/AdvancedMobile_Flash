package com.flash.content.entity;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.Type;

import javax.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "grammar_examples")
@Getter
@Setter
@NoArgsConstructor
public class GrammarExample {

    @Id
    @Type(type = "uuid-char")
    @Column(columnDefinition = "char")
    private UUID id;

    @Type(type = "uuid-char")
    @Column(columnDefinition = "char", nullable = false)
    private UUID grammarLessonId;

    @Column(columnDefinition = "text", nullable = false)
    private String sentence;

    @Column(columnDefinition = "text")
    private String translation;

    /** Cụm cần tô đậm trong câu, VD: "is playing". */
    private String highlight;

    @Column(nullable = false)
    private Integer sortOrder = 0;

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
