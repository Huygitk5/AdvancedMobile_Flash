package com.flash.gamification.service;

import com.flash.common.BusinessException;
import com.flash.common.ErrorCode;
import com.flash.gamification.entity.XpSourceType;
import com.flash.gamification.entity.XpTransaction;
import com.flash.gamification.repository.XpTransactionRepository;
import com.flash.stats.entity.DailyStatistic;
import com.flash.stats.service.DailyStatsService;
import com.flash.user.entity.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;

/**
 * Cổng duy nhất được đổi users.current_xp / total_lifetime_xp (DATA_ARCHITECTURE.md §5.3d).
 * Mỗi lần cộng/trừ là một dòng ledger có UNIQUE(user_id, source_type, source_id) nên cùng một
 * sự kiện gửi lại không được cộng lần hai.
 *
 * Người gọi phải đang giữ khoá dòng user (UserRepository.findActiveForUpdate). Nhờ khoá đó,
 * kiểm tra "đã có dòng ledger chưa" rồi mới INSERT là an toàn; UNIQUE key chỉ còn là chốt chặn cuối.
 * Không bắt DuplicateKeyException ở đây vì lỗi flush làm hỏng cả persistence context của transaction.
 */
@Service
@RequiredArgsConstructor
public class XpService {

    private final XpTransactionRepository repository;
    private final DailyStatsService dailyStatsService;

    /**
     * @param statDate ngày (địa phương) của sự kiện để cộng vào daily_statistics.xp_gained; null = không ghi
     * @return số XP thực sự được cộng/trừ (0 nếu sự kiện đã được tính trước đó)
     */
    @Transactional(propagation = Propagation.MANDATORY)
    public int award(User user, int amount, XpSourceType sourceType, String sourceId, LocalDate statDate) {
        return awardCapped(user, amount, sourceType, sourceId, statDate, null, 0);
    }

    /**
     * Như {@link #award} nhưng tổng XP của các dòng có source_id khớp {@code capPattern} (LIKE)
     * không vượt quá {@code cap}. VD: XP từ Know mỗi ngày tối đa 300.
     */
    @Transactional(propagation = Propagation.MANDATORY)
    public int awardCapped(User user, int amount, XpSourceType sourceType, String sourceId, LocalDate statDate,
                           String capPattern, int cap) {
        if (amount == 0 || repository.existsByUserIdAndSourceTypeAndSourceId(user.getId(), sourceType, sourceId)) {
            return 0;
        }
        if (capPattern != null && amount > 0) {
            long used = repository.sumAmountBySourceIdLike(user.getId(), sourceType, capPattern);
            amount = (int) Math.min(amount, Math.max(0, cap - used));
            if (amount == 0) {
                return 0;
            }
        }
        if (user.getCurrentXp() + amount < 0) {
            throw new BusinessException(ErrorCode.INSUFFICIENT_XP);
        }

        user.setCurrentXp(user.getCurrentXp() + amount);
        // Mua đồ chỉ trừ số dư, không đụng XP trọn đời nên không làm tụt hạng
        if (amount > 0 && sourceType != XpSourceType.SHOP_PURCHASE) {
            user.setTotalLifetimeXp(user.getTotalLifetimeXp() + amount);
        }

        XpTransaction tx = new XpTransaction();
        tx.setUserId(user.getId());
        tx.setAmount(amount);
        tx.setBalanceAfter(user.getCurrentXp());
        tx.setSourceType(sourceType);
        tx.setSourceId(sourceId);
        repository.save(tx);

        if (amount > 0 && statDate != null) {
            DailyStatistic stat = dailyStatsService.forDate(user.getId(), statDate);
            stat.setXpGained(stat.getXpGained() + amount);
        }
        return amount;
    }
}
