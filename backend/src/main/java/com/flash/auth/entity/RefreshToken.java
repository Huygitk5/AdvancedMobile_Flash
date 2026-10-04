package com.flash.auth.entity;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.Type;

import javax.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "refresh_tokens")
@Getter
@Setter
@NoArgsConstructor
public class RefreshToken {

    @Id
    @Type(type = "uuid-char")
    @Column(columnDefinition = "char")
    private UUID id;

    @Type(type = "uuid-char")
    @Column(columnDefinition = "char", nullable = false)
    private UUID userId;

    /** SHA-256 hex của refresh token, không lưu token thô. */
    @Column(columnDefinition = "char", nullable = false)
    private String tokenHash;

    private String deviceId;

    private String userAgent;

    @Column(nullable = false)
    private Instant expiresAt;

    private Instant revokedAt;

    /** Token kế nhiệm khi rotation. */
    @Type(type = "uuid-char")
    @Column(columnDefinition = "char")
    private UUID replacedById;

    @Column(insertable = false, updatable = false)
    private Instant createdAt;

    @PrePersist
    void ensureId() {
        if (id == null) {
            id = UUID.randomUUID();
        }
    }
}
