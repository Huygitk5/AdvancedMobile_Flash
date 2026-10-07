package com.flash.sync.entity;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.Type;

import javax.persistence.*;
import java.time.Instant;
import java.util.UUID;

/** Sổ idempotency: mỗi opId (client sinh) chỉ được xử lý 1 lần. */
@Entity
@Table(name = "sync_operations")
@Getter
@Setter
@NoArgsConstructor
public class SyncOperation {

    @Id
    @Type(type = "uuid-char")
    @Column(columnDefinition = "char")
    private UUID opId;

    @Type(type = "uuid-char")
    @Column(columnDefinition = "char", nullable = false)
    private UUID userId;

    @Column(nullable = false)
    private String opType;

    @Enumerated(EnumType.STRING)
    @Column(columnDefinition = "enum", nullable = false)
    private SyncOperationStatus status;

    private String errorCode;

    @Column(columnDefinition = "json")
    private String resultJson;

    @Column(nullable = false)
    private Instant clientCreatedAt;

    @Column(insertable = false, updatable = false)
    private Instant processedAt;
}
