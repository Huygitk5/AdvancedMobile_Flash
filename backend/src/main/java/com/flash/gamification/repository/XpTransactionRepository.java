package com.flash.gamification.repository;

import com.flash.gamification.entity.XpSourceType;
import com.flash.gamification.entity.XpTransaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.UUID;

public interface XpTransactionRepository extends JpaRepository<XpTransaction, Long> {

    boolean existsByUserIdAndSourceTypeAndSourceId(UUID userId, XpSourceType sourceType, String sourceId);

    /** Tổng XP đã cộng cho các nguồn có source_id khớp mẫu LIKE, dùng cho giới hạn XP/ngày. */
    @Query("select coalesce(sum(x.amount), 0) from XpTransaction x "
            + "where x.userId = :userId and x.sourceType = :sourceType and x.sourceId like :pattern")
    long sumAmountBySourceIdLike(@Param("userId") UUID userId, @Param("sourceType") XpSourceType sourceType,
                                 @Param("pattern") String pattern);

    @Query("select coalesce(sum(x.amount), 0) from XpTransaction x where x.userId = :userId")
    long sumAmount(@Param("userId") UUID userId);
}
