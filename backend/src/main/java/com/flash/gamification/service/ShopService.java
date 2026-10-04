package com.flash.gamification.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.flash.common.BusinessException;
import com.flash.common.ErrorCode;
import com.flash.common.enums.Resolution;
import com.flash.gamification.dto.EquipResult;
import com.flash.gamification.dto.InventoryResponse;
import com.flash.gamification.dto.PurchaseResponse;
import com.flash.gamification.dto.ShopItemResponse;
import com.flash.gamification.entity.RankBoard;
import com.flash.gamification.entity.RewardItem;
import com.flash.gamification.entity.RewardItemType;
import com.flash.gamification.entity.UserInventory;
import com.flash.gamification.entity.XpSourceType;
import com.flash.gamification.repository.RewardItemRepository;
import com.flash.gamification.repository.UserInventoryRepository;
import com.flash.sync.entity.SyncOperation;
import com.flash.sync.entity.SyncOperationStatus;
import com.flash.sync.repository.SyncOperationRepository;
import com.flash.user.entity.User;
import com.flash.user.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.persistence.EntityManager;
import java.time.Instant;
import java.util.ArrayList;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * Cửa hàng (DATA_ARCHITECTURE.md §5.3e). Mua bắt buộc online và chạy trong 1 transaction có khoá dòng users;
 * trang bị / tháo được làm offline nên dùng LWW theo client_updated_at.
 */
@Service
@RequiredArgsConstructor
public class ShopService {

    static final String OP_SHOP_PURCHASE = "SHOP_PURCHASE";

    private final UserService userService;
    private final RewardItemRepository itemRepository;
    private final UserInventoryRepository inventoryRepository;
    private final RewardItemService rewardItemService;
    private final LeaderboardService leaderboardService;
    private final XpService xpService;
    private final SyncOperationRepository syncOperationRepository;
    private final ObjectMapper objectMapper;
    private final EntityManager entityManager;

    @Transactional(readOnly = true)
    public List<ShopItemResponse> items(UUID userId, RewardItemType type) {
        User user = userService.getActiveUser(userId);
        Map<UUID, UserInventory> owned = inventoryRepository.findByUserIdOrderByUnlockedAt(userId).stream()
                .collect(Collectors.toMap(UserInventory::getRewardItemId, Function.identity()));
        Map<RankBoard, Integer> ranks = new EnumMap<>(RankBoard.class);

        return itemRepository.findByIsActiveTrueOrderBySortOrderAscCreatedAtAsc().stream()
                .filter(item -> type == null || item.getItemType() == type)
                .map(item -> {
                    UserInventory inventory = owned.get(item.getId());
                    boolean meetsRank = item.getRequiredRank() <= 0 || isWithinRank(
                            ranks.computeIfAbsent(item.getRankBoard(), b -> leaderboardService.rankOf(b, user)),
                            item.getRequiredRank());
                    return ShopItemResponse.builder()
                            .item(rewardItemService.toResponse(item))
                            .isUnlocked(inventory != null)
                            .isEquipped(inventory != null && inventory.getIsEquipped())
                            .inventoryId(inventory != null ? inventory.getId() : null)
                            .canAfford(user.getCurrentXp() >= item.getXpCost())
                            .meetsRankRequirement(meetsRank)
                            .build();
                })
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<InventoryResponse> inventory(UUID userId) {
        List<UserInventory> inventories = inventoryRepository.findByUserIdOrderByUnlockedAt(userId);
        Map<UUID, RewardItem> items = itemRepository.findAllById(
                        inventories.stream().map(UserInventory::getRewardItemId).collect(Collectors.toSet())).stream()
                .collect(Collectors.toMap(RewardItem::getId, Function.identity()));
        return inventories.stream()
                .map(inv -> InventoryResponse.of(inv, rewardItemService.toResponse(items.get(inv.getRewardItemId()))))
                .collect(Collectors.toList());
    }

    /**
     * Khoá dòng user rồi kiểm tra theo thứ tự: chưa sở hữu (409) → đủ hạng (403) → đủ XP (409).
     * Chỉ trừ current_xp, không trừ total_lifetime_xp nên mua đồ không làm tụt hạng.
     *
     * @param idempotencyKey header Idempotency-Key (= op_id của client). Gửi lại cùng key sau khi đã mua
     *                       thành công thì trả lại đúng kết quả cũ thay vì 409 ALREADY_OWNED.
     */
    @Transactional
    public PurchaseResponse purchase(UUID userId, UUID rewardItemId, UUID idempotencyKey) {
        User user = userService.lockActiveUser(userId);
        if (idempotencyKey != null) {
            Optional<PurchaseResponse> replay = replay(user, idempotencyKey);
            if (replay.isPresent()) {
                return replay.get();
            }
        }

        RewardItem item = itemRepository.findById(rewardItemId)
                .filter(RewardItem::getIsActive)
                .orElseThrow(() -> new BusinessException(ErrorCode.NOT_FOUND, "Không tìm thấy vật phẩm"));
        if (inventoryRepository.existsByUserIdAndRewardItemId(userId, rewardItemId)) {
            throw new BusinessException(ErrorCode.ALREADY_OWNED);
        }
        if (item.getRequiredRank() > 0) {
            Integer rank = leaderboardService.rankOf(item.getRankBoard(), user);
            if (!isWithinRank(rank, item.getRequiredRank())) {
                throw new BusinessException(ErrorCode.RANK_REQUIREMENT_NOT_MET,
                        "Cần nằm trong Top " + item.getRequiredRank() + " (hạng hiện tại: " + rank + ")");
            }
        }
        if (user.getCurrentXp() < item.getXpCost()) {
            throw new BusinessException(ErrorCode.INSUFFICIENT_XP,
                    "Không đủ XP (cần " + item.getXpCost() + ", đang có " + user.getCurrentXp() + ")");
        }

        UserInventory inventory = new UserInventory();
        inventory.setId(UUID.randomUUID());
        inventory.setUserId(userId);
        inventory.setRewardItemId(rewardItemId);
        inventoryRepository.saveAndFlush(inventory);
        entityManager.refresh(inventory);
        if (item.getXpCost() > 0) {
            xpService.award(user, -item.getXpCost(), XpSourceType.SHOP_PURCHASE, inventory.getId().toString(), null);
        }

        PurchaseResponse response = new PurchaseResponse(
                InventoryResponse.of(inventory, rewardItemService.toResponse(item)), user.getCurrentXp());
        if (idempotencyKey != null) {
            remember(userId, idempotencyKey, response);
        }
        return response;
    }

    @Transactional
    public EquipResult equip(UUID userId, UUID inventoryId, Instant clientUpdatedAt) {
        return setEquipped(userId, inventoryId, true, clientUpdatedAt);
    }

    @Transactional
    public EquipResult unequip(UUID userId, UUID inventoryId, Instant clientUpdatedAt) {
        return setEquipped(userId, inventoryId, false, clientUpdatedAt);
    }

    /** LWW: bản có client_updated_at cũ hơn bản trên server thì bị bỏ qua. Trang bị thì tự tháo món cùng loại. */
    private EquipResult setEquipped(UUID userId, UUID inventoryId, boolean equipped, Instant clientUpdatedAt) {
        userService.lockActiveUser(userId);
        Instant at = clientUpdatedAt != null ? clientUpdatedAt : Instant.now();
        UserInventory inventory = inventoryRepository.findByIdAndUserId(inventoryId, userId)
                .orElseThrow(() -> new BusinessException(ErrorCode.NOT_FOUND, "Không tìm thấy vật phẩm trong kho"));
        RewardItem item = itemRepository.findById(inventory.getRewardItemId()).orElseThrow();

        if (inventory.getClientUpdatedAt() != null && at.isBefore(inventory.getClientUpdatedAt())) {
            return new EquipResult(InventoryResponse.of(inventory, rewardItemService.toResponse(item)), List.of(),
                    Resolution.CONFLICT_SERVER_WINS);
        }

        List<InventoryResponse> unequipped = new ArrayList<>();
        if (equipped) {
            for (UserInventory other : inventoryRepository.findEquippedByType(userId, item.getItemType())) {
                if (!other.getId().equals(inventory.getId())) {
                    other.setIsEquipped(false);
                    other.setClientUpdatedAt(at);
                    unequipped.add(InventoryResponse.of(other, null));
                }
            }
        }
        inventory.setIsEquipped(equipped);
        inventory.setClientUpdatedAt(at);
        inventoryRepository.flush();
        return new EquipResult(InventoryResponse.of(inventory, rewardItemService.toResponse(item)), unequipped,
                Resolution.APPLIED);
    }

    private Optional<PurchaseResponse> replay(User user, UUID idempotencyKey) {
        return syncOperationRepository.findById(idempotencyKey).map(op -> {
            if (!op.getUserId().equals(user.getId()) || !OP_SHOP_PURCHASE.equals(op.getOpType())) {
                throw new BusinessException(ErrorCode.CONFLICT, "Idempotency-Key đã được dùng cho thao tác khác");
            }
            if (op.getStatus() == SyncOperationStatus.REJECTED) {
                // Lần mua qua /v1/sync/push với cùng key đã bị từ chối: trả lại đúng lỗi đó
                ErrorCode code = ErrorCode.valueOf(op.getErrorCode());
                throw new BusinessException(code, code.getDefaultMessage());
            }
            UUID inventoryId = readInventoryId(op.getResultJson());
            UserInventory inventory = inventoryRepository.findByIdAndUserId(inventoryId, user.getId()).orElseThrow();
            RewardItem item = itemRepository.findById(inventory.getRewardItemId()).orElseThrow();
            return new PurchaseResponse(InventoryResponse.of(inventory, rewardItemService.toResponse(item)),
                    user.getCurrentXp());
        });
    }

    /** Ghi vào sổ idempotency dùng chung với /v1/sync/push (bảng sync_operations). */
    private void remember(UUID userId, UUID idempotencyKey, PurchaseResponse response) {
        SyncOperation op = new SyncOperation();
        op.setOpId(idempotencyKey);
        op.setUserId(userId);
        op.setOpType(OP_SHOP_PURCHASE);
        op.setStatus(SyncOperationStatus.APPLIED);
        op.setClientCreatedAt(Instant.now());
        try {
            op.setResultJson(objectMapper.writeValueAsString(response));
        } catch (JsonProcessingException e) {
            throw new IllegalStateException(e);
        }
        syncOperationRepository.save(op);
    }

    private UUID readInventoryId(String resultJson) {
        try {
            return UUID.fromString(objectMapper.readTree(resultJson).at("/inventory/id").asText());
        } catch (JsonProcessingException e) {
            throw new IllegalStateException(e);
        }
    }

    private static boolean isWithinRank(Integer rank, int requiredRank) {
        return rank != null && rank <= requiredRank;
    }
}
