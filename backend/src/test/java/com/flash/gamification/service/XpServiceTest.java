package com.flash.gamification.service;

import com.flash.common.BusinessException;
import com.flash.common.ErrorCode;
import com.flash.gamification.entity.XpSourceType;
import com.flash.gamification.entity.XpTransaction;
import com.flash.gamification.repository.XpTransactionRepository;
import com.flash.stats.entity.DailyStatistic;
import com.flash.stats.service.DailyStatsService;
import com.flash.user.entity.User;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class XpServiceTest {

    private static final LocalDate DAY = LocalDate.of(2026, 10, 1);

    @Mock
    private XpTransactionRepository repository;

    @Mock
    private DailyStatsService dailyStatsService;

    @InjectMocks
    private XpService xpService;

    private User user;
    private DailyStatistic stat;

    @BeforeEach
    void setUp() {
        user = new User();
        user.setId(UUID.randomUUID());
        user.setCurrentXp(100);
        user.setTotalLifetimeXp(1000L);
        stat = new DailyStatistic();
    }

    @Test
    void awardWritesLedgerAndUpdatesBalanceLifetimeAndDailyXp() {
        when(dailyStatsService.forDate(user.getId(), DAY)).thenReturn(stat);

        int awarded = xpService.award(user, 10, XpSourceType.LESSON_COMPLETE, "lesson-1", DAY);

        assertThat(awarded).isEqualTo(10);
        assertThat(user.getCurrentXp()).isEqualTo(110);
        assertThat(user.getTotalLifetimeXp()).isEqualTo(1010L);
        assertThat(stat.getXpGained()).isEqualTo(10);
        ArgumentCaptor<XpTransaction> tx = ArgumentCaptor.forClass(XpTransaction.class);
        verify(repository).save(tx.capture());
        assertThat(tx.getValue().getBalanceAfter()).isEqualTo(110);
        assertThat(tx.getValue().getSourceId()).isEqualTo("lesson-1");
    }

    @Test
    void sameSourceIsNeverAwardedTwice() {
        when(repository.existsByUserIdAndSourceTypeAndSourceId(user.getId(), XpSourceType.FLASHCARD_REVIEW, "know:x"))
                .thenReturn(true);

        int awarded = xpService.award(user, 2, XpSourceType.FLASHCARD_REVIEW, "know:x", DAY);

        assertThat(awarded).isZero();
        assertThat(user.getCurrentXp()).isEqualTo(100);
        verify(repository, never()).save(any());
    }

    @Test
    void dailyCapLimitsAmount() {
        when(repository.sumAmountBySourceIdLike(user.getId(), XpSourceType.FLASHCARD_REVIEW, "know:%:" + DAY))
                .thenReturn(299L);
        when(dailyStatsService.forDate(user.getId(), DAY)).thenReturn(stat);

        int awarded = xpService.awardCapped(user, 2, XpSourceType.FLASHCARD_REVIEW, "know:a:" + DAY, DAY,
                "know:%:" + DAY, 300);
        assertThat(awarded).isEqualTo(1);

        when(repository.sumAmountBySourceIdLike(user.getId(), XpSourceType.FLASHCARD_REVIEW, "know:%:" + DAY))
                .thenReturn(300L);
        assertThat(xpService.awardCapped(user, 2, XpSourceType.FLASHCARD_REVIEW, "know:b:" + DAY, DAY,
                "know:%:" + DAY, 300)).isZero();
    }

    @Test
    void purchaseDeductsBalanceButNotLifetimeXp() {
        int awarded = xpService.award(user, -60, XpSourceType.SHOP_PURCHASE, "inv-1", null);

        assertThat(awarded).isEqualTo(-60);
        assertThat(user.getCurrentXp()).isEqualTo(40);
        assertThat(user.getTotalLifetimeXp()).isEqualTo(1000L);
        verify(dailyStatsService, never()).forDate(any(), any());
    }

    @Test
    void balanceNeverGoesNegative() {
        assertThatThrownBy(() -> xpService.award(user, -101, XpSourceType.SHOP_PURCHASE, "inv-2", null))
                .isInstanceOf(BusinessException.class)
                .extracting("errorCode").isEqualTo(ErrorCode.INSUFFICIENT_XP);
        assertThat(user.getCurrentXp()).isEqualTo(100);
    }

    @Test
    void zeroAmountIsIgnored() {
        assertThat(xpService.award(user, 0, XpSourceType.QUIZ, "quiz:x", DAY)).isZero();
        verify(repository, never()).save(any());
    }
}
