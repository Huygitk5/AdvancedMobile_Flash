package com.flash.content.entity;

import com.flash.common.enums.CefrLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.Type;

import javax.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "grammar_lessons")
@Getter
@Setter
@NoArgsConstructor
public class GrammarLesson {

    @Id
    @Type(type = "uuid-char")
    @Column(columnDefinition = "char")
    private UUID id;

    @Column(nullable = false)
    private String title;

    private String description;

    /** VD: S + am/is/are + V-ing */
    @Column(nullable = false)
    private String structure;

    /** Giải thích chi tiết (Markdown). */
    @Column(columnDefinition = "text")
    private String content;

    @Column(columnDefinition = "text")
    private String usageNotes;

    /** Tên Material icon, Flutter tự map sang IconData. */
    @Column(nullable = false)
    private String iconName;

    @Enumerated(EnumType.STRING)
    @Column(columnDefinition = "enum", nullable = false)
    private CefrLevel level = CefrLevel.A1;

    @Column(columnDefinition = "int")
    private Long coverColor;

    @Column(columnDefinition = "smallint", nullable = false)
    private Integer estimatedMinutes = 10;

    @Column(nullable = false)
    private Integer sortOrder = 0;

    @Column(nullable = false)
    private Boolean isPublished = false;

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
