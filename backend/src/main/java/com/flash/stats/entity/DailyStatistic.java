package com.flash.stats.entity;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.Type;

import javax.persistence.*;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

/** Một dòng / user / ngày theo timezone của user. Server là nguồn chân lý. */
@Entity
@Table(name = "daily_statistics")
@Getter
@Setter
@NoArgsConstructor
public class DailyStatistic {

    @Id
    @Type(type = "uuid-char")
    @Column(columnDefinition = "char")
    private UUID id;

    @Type(type = "uuid-char")
    @Column(columnDefinition = "char", nullable = false)
    private UUID userId;

    @Column(nullable = false)
    private LocalDate statDate;

    @Column(nullable = false)
    private Integer wordsLearned = 0;

    @Column(nullable = false)
    private Integer cardsReviewed = 0;

    @Column(nullable = false)
    private Integer xpGained = 0;

    @Column(nullable = false)
    private Integer lessonsCompleted = 0;

    @Column(nullable = false)
    private Integer quizzesCompleted = 0;

    @Column(nullable = false)
    private Integer correctAnswers = 0;

    /** Accuracy = correctAnswers / totalAnswers */
    @Column(nullable = false)
    private Integer totalAnswers = 0;

    @Column(nullable = false)
    private Integer studySeconds = 0;

    @Column(insertable = false, updatable = false)
    private Instant createdAt;

    @Column(insertable = false, updatable = false)
    private Instant updatedAt;

    @PrePersist
    void ensureId() {
        if (id == null) {
            id = UUID.randomUUID();
        }
    }
}
