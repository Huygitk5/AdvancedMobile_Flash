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
@Table(name = "topics")
@Getter
@Setter
@NoArgsConstructor
public class Topic {

    @Id
    @Type(type = "uuid-char")
    @Column(columnDefinition = "char")
    private UUID id;

    @Column(nullable = false)
    private String title;

    private String description;

    @Column(nullable = false)
    private String iconPath;

    @Enumerated(EnumType.STRING)
    @Column(columnDefinition = "enum", nullable = false)
    private CefrLevel level = CefrLevel.A1;

    /** ARGB 0xAARRGGBB, dùng thẳng cho Color(int) bên Flutter. */
    @Column(columnDefinition = "int")
    private Long coverColor;

    @Column(columnDefinition = "smallint", nullable = false)
    private Integer estimatedMinutes = 10;

    /** Counter, cập nhật khi thêm/xoá flashcard. */
    @Column(nullable = false)
    private Integer totalWords = 0;

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
