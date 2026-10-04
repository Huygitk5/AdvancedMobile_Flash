package com.flash.gamification.controller;

import com.flash.common.ApiResponse;
import com.flash.gamification.dto.RewardItemRequest;
import com.flash.gamification.dto.RewardItemResponse;
import com.flash.gamification.service.RewardItemService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import javax.validation.Valid;
import java.util.List;
import java.util.UUID;

@Tag(name = "Shop (Admin)", description = "Vật phẩm cửa hàng. Mua / trang bị ở G4")
@PreAuthorize("hasRole('ADMIN')")
@RestController
@RequestMapping("/v1/shop/items")
@RequiredArgsConstructor
public class RewardItemAdminController {

    private final RewardItemService service;

    @Operation(summary = "[ADMIN] Toàn bộ vật phẩm (kể cả đã gỡ)")
    @GetMapping("/definitions")
    public ApiResponse<List<RewardItemResponse>> list() {
        return ApiResponse.ok(service.list());
    }

    @Operation(summary = "[ADMIN] Tạo vật phẩm")
    @PostMapping("/create")
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<RewardItemResponse> create(@Valid @RequestBody RewardItemRequest request) {
        return ApiResponse.ok(service.create(request));
    }

    @Operation(summary = "[ADMIN] Sửa vật phẩm")
    @PutMapping("/update/{id}")
    public ApiResponse<RewardItemResponse> update(@PathVariable UUID id, @Valid @RequestBody RewardItemRequest request) {
        return ApiResponse.ok(service.update(id, request));
    }

    @Operation(summary = "[ADMIN] Gỡ vật phẩm khỏi cửa hàng (is_active = false)")
    @DeleteMapping("/delete/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable UUID id) {
        service.deactivate(id);
    }
}
