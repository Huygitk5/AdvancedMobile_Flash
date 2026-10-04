package com.flash.gamification.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.flash.common.BusinessException;
import com.flash.common.ErrorCode;
import com.flash.gamification.dto.PurchaseResponse;
import com.flash.gamification.entity.RankBoard;
import com.flash.gamification.entity.RewardItem;
import com.flash.gamification.entity.RewardItemType;
import com.flash.gamification.entity.UserInventory;
import com.flash.gamification.entity.XpSourceType;
import com.flash.gamification.repository.RewardItemRepository;
import com.flash.gamification.repository.UserInventoryRepository;
import com.flash.sync.repository.SyncOperationRepository;
import com.flash.user.entity.User;
import com.flash.user.service.UserService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Spy;
import org.mockito.junit.jupiter.MockitoExtension;

import javax.persistence.EntityManager;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/** Thứ tự kiểm tra khi mua: đã sở hữu (409) → hạng (403) → XP (409); thành công thì trừ XP qua ledger. */
@ExtendWith(MockitoExtension.class)
class ShopServiceTest {

    @Mock
    private UserService userService;
    @Mock
    private RewardItemRepository itemRepository;
    @Mock
    private UserInventoryRepository inventoryRepository;
    @Mock
    private RewardItemService rewardItemService;
    @Mock
    private LeaderboardService leaderboardService;
    @Mock
    private XpService xpService;
    @Mock
    private SyncOperationRepository syncOperationRepository;
    @Spy
    private ObjectMapper objectMapper = new ObjectMapper();
    @Mock
    private EntityManager entityManager;

    @InjectMocks
    private ShopService shopService;

    private User user;
    private RewardItem item;

    @BeforeEach
    void setUp() {
        user = new User();
        user.setId(UUID.randomUUID());
        user.setCurrentXp(400);
        item = new RewardItem();
        item.setId(UUID.randomUUID());
        item.setItemType(RewardItemType.BORDER);
        item.setXpCost(500);
        item.setRankBoard(RankBoard.XP);
        when(userService.lockActiveUser(user.getId())).thenReturn(user);
        when(itemRepository.findById(item.getId())).thenReturn(Optional.of(item));
    }

    @Test
    void insufficientXpIsConflict() {
        assertPurchaseFails(ErrorCode.INSUFFICIENT_XP);
        verify(inventoryRepository, never()).saveAndFlush(any());
    }

    @Test
    void notInRequiredRankIsForbidden() {
        item.setXpCost(0);
        item.setRequiredRank(3);
        when(leaderboardService.rankOf(RankBoard.XP, user)).thenReturn(4);

        assertPurchaseFails(ErrorCode.RANK_REQUIREMENT_NOT_MET);
    }

    @Test
    void alreadyOwnedIsCheckedFirst() {
        item.setRequiredRank(3);
        when(inventoryRepository.existsByUserIdAndRewardItemId(user.getId(), item.getId())).thenReturn(true);

        assertPurchaseFails(ErrorCode.ALREADY_OWNED);
        verify(leaderboardService, never()).rankOf(any(), any());
    }

    @Test
    void inactiveItemIsNotFound() {
        item.setIsActive(false);
        assertPurchaseFails(ErrorCode.NOT_FOUND);
    }

    @Test
    void successfulPurchaseDeductsXpThroughLedger() {
        user.setCurrentXp(600);
        item.setRequiredRank(3);
        when(leaderboardService.rankOf(RankBoard.XP, user)).thenReturn(2);

        PurchaseResponse response = shopService.purchase(user.getId(), item.getId(), null);

        verify(inventoryRepository).saveAndFlush(any(UserInventory.class));
        verify(xpService).award(eq(user), eq(-500), eq(XpSourceType.SHOP_PURCHASE), any(), eq(null));
        verify(syncOperationRepository, never()).save(any());
        assertThat(response.getInventory().getRewardItemId()).isEqualTo(item.getId());
    }

    @Test
    void freeItemNeedsNoXp() {
        user.setCurrentXp(0);
        item.setXpCost(0);

        shopService.purchase(user.getId(), item.getId(), null);

        verify(inventoryRepository).saveAndFlush(any(UserInventory.class));
        verify(xpService, never()).award(any(), anyInt(), any(), any(), any());
    }

    private void assertPurchaseFails(ErrorCode expected) {
        assertThatThrownBy(() -> shopService.purchase(user.getId(), item.getId(), null))
                .isInstanceOf(BusinessException.class)
                .extracting("errorCode").isEqualTo(expected);
        verify(xpService, never()).award(any(), anyInt(), any(), any(), any());
    }
}
