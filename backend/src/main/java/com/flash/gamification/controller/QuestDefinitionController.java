package com.flash.gamification.controller;

import com.flash.common.ApiResponse;
import com.flash.gamification.dto.QuestDefinitionRequest;
import com.flash.gamification.dto.QuestDefinitionResponse;
import com.flash.gamification.service.QuestDefinitionService;
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

@Tag(name = "Quests (Admin)", description = "Mẫu nhiệm vụ. Nhiệm vụ hôm nay / nhận thưởng ở G4")
@PreAuthorize("hasRole('ADMIN')")
@RestController
@RequestMapping("/v1/quests")
@RequiredArgsConstructor
public class QuestDefinitionController {

    private final QuestDefinitionService service;

    @Operation(summary = "[ADMIN] Danh sách mẫu nhiệm vụ")
    @GetMapping("/definitions")
    public ApiResponse<List<QuestDefinitionResponse>> list() {
        return ApiResponse.ok(service.list());
    }

    @Operation(summary = "[ADMIN] Tạo mẫu nhiệm vụ")
    @PostMapping("/create")
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<QuestDefinitionResponse> create(@Valid @RequestBody QuestDefinitionRequest request) {
        return ApiResponse.ok(service.create(request));
    }

    @Operation(summary = "[ADMIN] Sửa mẫu nhiệm vụ")
    @PutMapping("/update/{id}")
    public ApiResponse<QuestDefinitionResponse> update(@PathVariable UUID id,
                                                       @Valid @RequestBody QuestDefinitionRequest request) {
        return ApiResponse.ok(service.update(id, request));
    }

    @Operation(summary = "[ADMIN] Ngừng giao nhiệm vụ (is_active = false)")
    @DeleteMapping("/delete/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable UUID id) {
        service.deactivate(id);
    }
}
