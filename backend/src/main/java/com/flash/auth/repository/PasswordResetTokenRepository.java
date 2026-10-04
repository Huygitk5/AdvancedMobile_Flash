package com.flash.auth.repository;

import com.flash.auth.entity.PasswordResetToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import javax.persistence.LockModeType;
import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface PasswordResetTokenRepository extends JpaRepository<PasswordResetToken, UUID> {

    Optional<PasswordResetToken> findFirstByUserIdOrderByCreatedAtDesc(UUID userId);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select t from PasswordResetToken t where t.userId = :userId and t.usedAt is null "
            + "and t.expiresAt > :now order by t.createdAt desc")
    List<PasswordResetToken> findActiveForUpdate(@Param("userId") UUID userId, @Param("now") Instant now);

    /** Mỗi tài khoản chỉ có 1 OTP còn hiệu lực: vô hiệu hoá các mã cũ khi gửi mã mới. */
    @Modifying
    @Query("update PasswordResetToken t set t.usedAt = :now where t.userId = :userId and t.usedAt is null")
    int invalidateActive(@Param("userId") UUID userId, @Param("now") Instant now);
}
