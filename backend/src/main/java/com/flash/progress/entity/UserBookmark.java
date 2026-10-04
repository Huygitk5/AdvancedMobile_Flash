package com.flash.progress.entity;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.Type;

import javax.persistence.*;
import java.time.Instant;
import java.util.UUID;

/** Bỏ bookmark = set deletedAt (tombstone), bookmark lại = xoá deletedAt. */
@Entity
@Table(name = "user_bookmarks")
@IdClass(UserBookmarkId.class)
@Getter
@Setter
@NoArgsConstructor
public class UserBookmark {

    @Id
    @Type(type = "uuid-char")
    @Column(columnDefinition = "char")
    private UUID userId;

    @Id
    @Type(type = "uuid-char")
    @Column(columnDefinition = "char")
    private UUID flashcardId;

    @Version
    private Integer version;

    @Column(nullable = false)
    private Instant clientUpdatedAt;

    @Column(insertable = false, updatable = false)
    private Instant createdAt;

    @Column(insertable = false, updatable = false)
    private Instant updatedAt;

    private Instant deletedAt;
}
