package com.flash.progress.entity;

import com.flash.common.enums.ProgressStatus;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.Type;

import javax.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "user_grammar_progress")
@IdClass(UserGrammarProgressId.class)
@Getter
@Setter
@NoArgsConstructor
public class UserGrammarProgress {

    @Id
    @Type(type = "uuid-char")
    @Column(columnDefinition = "char")
    private UUID userId;

    @Id
    @Type(type = "uuid-char")
    @Column(columnDefinition = "char")
    private UUID grammarLessonId;

    /** 0.0000 .. 1.0000 */
    @Column(columnDefinition = "decimal", precision = 5, scale = 4, nullable = false)
    private BigDecimal progress = BigDecimal.ZERO;

    @Enumerated(EnumType.STRING)
    @Column(columnDefinition = "enum", nullable = false)
    private ProgressStatus status = ProgressStatus.NOT_STARTED;

    @Column(columnDefinition = "tinyint")
    private Integer bestScorePercent;

    private Instant lastStudiedAt;

    private Instant completedAt;

    @Version
    private Integer version;

    @Column(insertable = false, updatable = false)
    private Instant createdAt;

    @Column(insertable = false, updatable = false)
    private Instant updatedAt;
}
