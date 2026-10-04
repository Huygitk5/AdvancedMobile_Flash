package com.flash.progress.entity;

import com.flash.common.enums.ProgressStatus;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.Type;

import javax.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "user_topic_progress")
@IdClass(UserTopicProgressId.class)
@Getter
@Setter
@NoArgsConstructor
public class UserTopicProgress {

    @Id
    @Type(type = "uuid-char")
    @Column(columnDefinition = "char")
    private UUID userId;

    @Id
    @Type(type = "uuid-char")
    @Column(columnDefinition = "char")
    private UUID topicId;

    /** Số flashcard đã thuộc (is_learned) trong topic. */
    @Column(nullable = false)
    private Integer learnedWords = 0;

    @Enumerated(EnumType.STRING)
    @Column(columnDefinition = "enum", nullable = false)
    private ProgressStatus status = ProgressStatus.NOT_STARTED;

    private Instant lastStudiedAt;

    private Instant completedAt;

    @Version
    private Integer version;

    @Column(insertable = false, updatable = false)
    private Instant createdAt;

    @Column(insertable = false, updatable = false)
    private Instant updatedAt;
}
