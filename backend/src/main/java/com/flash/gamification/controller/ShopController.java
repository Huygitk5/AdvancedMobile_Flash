package com.flash.gamification.controller;

import com.flash.common.ApiResponse;
import com.flash.gamification.dto.EquipRequest;
import com.flash.gamification.dto.EquipResult;
import com.flash.gamification.dto.InventoryResponse;
import com.flash.gamification.dto.PurchaseRequest;
import com.flash.gamification.dto.PurchaseResponse;
import com.flash.gamification.dto.ShopItemResponse;
import com.flash.gamification.entity.RewardItemType;
import com.flash.gamification.service.ShopService;
import com.flash.security.CurrentUser;
import com.flash.security.UserPrincipal;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import javax.validation.Valid;
import java.util.List;
import java.util.UUID;

@Tag(name = "Shop", description = "Cửa hàng, kho đồ, trang bị")
@RestController
@RequestMapping("/v1/shop")
@RequiredArgsConstructor
public class ShopController {

    private final ShopService shopService;

    @Operation(summary = "Danh mục vật phẩm kèm isUnlocked / isEquipped / canAfford / meetsRankRequirement")
    @GetMapping("/items")
    public ApiResponse<List<ShopItemResponse>> items(@CurrentUser UserPrincipal me,
                                                     @RequestParam(required = false) RewardItemType type) {
        return ApiResponse.ok(shopService.items(me.getId(), type));
    }

    @Operation(summary = "Kho đồ của user")
    @GetMapping("/inventory")
    public ApiResponse<List<InventoryResponse>> inventory(@CurrentUser UserPrincipal me) {
        return ApiResponse.ok(shopService.inventory(me.getId()));
    }

    @Operation(summary = "Mua vật phẩm (chỉ online)",
            description = "409 INSUFFICIENT_XP / ALREADY_OWNED, 403 RANK_REQUIREMENT_NOT_MET. "
                    + "Gửi lại cùng Idempotency-Key sau khi đã mua thì nhận lại đúng kết quả cũ")
    @PostMapping("/purchase")
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<PurchaseResponse> purchase(@CurrentUser UserPrincipal me,
                                                  @Valid @RequestBody PurchaseRequest request,
                                                  @RequestHeader(value = "Idempotency-Key", required = false) UUID idempotencyKey) {
        return ApiResponse.ok(shopService.purchase(me.getId(), request.getRewardItemId(), idempotencyKey));
    }

    @Operation(summary = "Trang bị (tự tháo món cùng loại)", description = "Last-Write-Wins theo clientUpdatedAt")
    @PutMapping("/equip/{inventoryId}")
    public ApiResponse<EquipResult> equip(@CurrentUser UserPrincipal me, @PathVariable UUID inventoryId,
                                          @RequestBody(required = false) EquipRequest request) {
        return ApiResponse.ok(shopService.equip(me.getId(), inventoryId, request != null ? request.getClientUpdatedAt() : null));
    }

    @Operation(summary = "Tháo vật phẩm", description = "Last-Write-Wins theo clientUpdatedAt")
    @PutMapping("/unequip/{inventoryId}")
    public ApiResponse<EquipResult> unequip(@CurrentUser UserPrincipal me, @PathVariable UUID inventoryId,
                                            @RequestBody(required = false) EquipRequest request) {
        return ApiResponse.ok(shopService.unequip(me.getId(), inventoryId, request != null ? request.getClientUpdatedAt() : null));
    }
}
