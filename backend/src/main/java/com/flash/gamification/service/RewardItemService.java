package com.flash.gamification.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.flash.common.BusinessException;
import com.flash.common.ErrorCode;
import com.flash.gamification.dto.RewardItemRequest;
import com.flash.gamification.dto.RewardItemResponse;
import com.flash.gamification.entity.RankBoard;
import com.flash.gamification.entity.RewardItem;
import com.flash.gamification.entity.RewardItemType;
import com.flash.gamification.repository.RewardItemRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

/** Quản lý vật phẩm cửa hàng. Mua / trang bị nằm ở ShopService (G4). */
@Service
@RequiredArgsConstructor
public class RewardItemService {

    private static final TypeReference<List<Long>> COLOR_LIST = new TypeReference<>() {
    };

    private final RewardItemRepository repository;
    private final ObjectMapper objectMapper;

    @Transactional(readOnly = true)
    public List<RewardItemResponse> list() {
        return repository.findAllByOrderBySortOrderAscCreatedAtAsc().stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public RewardItemResponse create(RewardItemRequest request) {
        if (repository.existsByCode(request.getCode())) {
            throw new BusinessException(ErrorCode.CONFLICT, "Mã vật phẩm " + request.getCode() + " đã tồn tại");
        }
        RewardItem item = new RewardItem();
        apply(item, request);
        repository.save(item);
        return toResponse(item);
    }

    @Transactional
    public RewardItemResponse update(UUID id, RewardItemRequest request) {
        RewardItem item = find(id);
        if (repository.existsByCodeAndIdNot(request.getCode(), id)) {
            throw new BusinessException(ErrorCode.CONFLICT, "Mã vật phẩm " + request.getCode() + " đã tồn tại");
        }
        apply(item, request);
        repository.saveAndFlush(item);
        return toResponse(item);
    }

    /** Không xoá dòng (user_inventories đang tham chiếu), chỉ gỡ khỏi cửa hàng. */
    @Transactional
    public void deactivate(UUID id) {
        find(id).setIsActive(false);
    }

    public RewardItemResponse toResponse(RewardItem item) {
        return RewardItemResponse.builder()
                .id(item.getId())
                .code(item.getCode())
                .name(item.getName())
                .description(item.getDescription())
                .itemType(item.getItemType())
                .xpCost(item.getXpCost())
                .borderColors(readColors(item.getBorderColors()))
                .imageUrl(item.getImageUrl())
                .requiredRank(item.getRequiredRank())
                .rankBoard(item.getRankBoard())
                .isActive(item.getIsActive())
                .sortOrder(item.getSortOrder())
                .build();
    }

    private RewardItem find(UUID id) {
        return repository.findById(id)
                .orElseThrow(() -> new BusinessException(ErrorCode.NOT_FOUND, "Không tìm thấy vật phẩm"));
    }

    private void apply(RewardItem item, RewardItemRequest request) {
        boolean hasColors = request.getBorderColors() != null && !request.getBorderColors().isEmpty();
        if (request.getItemType() == RewardItemType.BORDER && !hasColors) {
            throw new BusinessException(ErrorCode.VALIDATION_ERROR, "Viền (BORDER) cần borderColors");
        }
        item.setCode(request.getCode());
        item.setName(request.getName().trim());
        item.setDescription(request.getDescription());
        item.setItemType(request.getItemType());
        item.setXpCost(request.getXpCost() != null ? request.getXpCost() : 0);
        item.setBorderColors(hasColors ? writeColors(request.getBorderColors()) : null);
        item.setImageUrl(request.getImageUrl());
        item.setRequiredRank(request.getRequiredRank() != null ? request.getRequiredRank() : 0);
        item.setRankBoard(request.getRankBoard() != null ? request.getRankBoard() : RankBoard.XP);
        item.setIsActive(request.getIsActive() == null || request.getIsActive());
        item.setSortOrder(request.getSortOrder() != null ? request.getSortOrder() : 0);
    }

    private String writeColors(List<Long> colors) {
        try {
            return objectMapper.writeValueAsString(colors);
        } catch (JsonProcessingException e) {
            throw new IllegalStateException(e);
        }
    }

    private List<Long> readColors(String json) {
        if (json == null) {
            return null;
        }
        try {
            return objectMapper.readValue(json, COLOR_LIST);
        } catch (JsonProcessingException e) {
            throw new IllegalStateException("border_colors không phải JSON hợp lệ: " + json, e);
        }
    }
}
