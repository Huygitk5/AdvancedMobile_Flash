package com.flash.content.controller;

import com.flash.common.ApiResponse;
import com.flash.common.PageResponse;
import com.flash.common.enums.ProgressFilter;
import com.flash.content.dto.GrammarDetailResponse;
import com.flash.content.dto.GrammarRequest;
import com.flash.content.dto.GrammarResponse;
import com.flash.content.service.GrammarService;
import com.flash.security.CurrentUser;
import com.flash.security.UserPrincipal;
import com.flash.user.entity.UserRole;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import javax.validation.Valid;
import javax.validation.constraints.Max;
import javax.validation.constraints.Min;
import java.util.UUID;

@Tag(name = "Grammar", description = "Chủ điểm ngữ pháp")
@Validated
@RestController
@RequestMapping("/v1/grammar")
@RequiredArgsConstructor
public class GrammarController {

    private final GrammarService grammarService;

    @Operation(summary = "Danh sách chủ điểm kèm tiến độ của user",
            description = "status: ALL | NOT_STARTED | IN_PROGRESS | COMPLETED")
    @GetMapping
    public ApiResponse<PageResponse<GrammarResponse>> list(@CurrentUser UserPrincipal me,
                                                           @RequestParam(required = false) String keyword,
                                                           @RequestParam(defaultValue = "ALL") ProgressFilter status,
                                                           @RequestParam(defaultValue = "false") boolean includeUnpublished,
                                                           @RequestParam(defaultValue = "0") @Min(0) int page,
                                                           @RequestParam(defaultValue = "50") @Min(1) @Max(100) int size) {
        boolean showDrafts = includeUnpublished && me.getRole() == UserRole.ADMIN;
        return ApiResponse.ok(grammarService.list(me.getId(), keyword, status, showDrafts, PageRequest.of(page, size)));
    }

    @Operation(summary = "Chi tiết: cấu trúc, giải thích, ví dụ, quiz luyện tập")
    @GetMapping("/get/{id}")
    public ApiResponse<GrammarDetailResponse> get(@CurrentUser UserPrincipal me, @PathVariable UUID id) {
        return ApiResponse.ok(grammarService.get(me.getId(), id, me.getRole() == UserRole.ADMIN));
    }

    @Operation(summary = "[ADMIN] Tạo chủ điểm (kèm ví dụ)")
    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping("/create")
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<GrammarDetailResponse> create(@Valid @RequestBody GrammarRequest request) {
        return ApiResponse.ok(grammarService.create(request));
    }

    @Operation(summary = "[ADMIN] Sửa chủ điểm (examples thay toàn bộ)")
    @PreAuthorize("hasRole('ADMIN')")
    @PutMapping("/update/{id}")
    public ApiResponse<GrammarDetailResponse> update(@PathVariable UUID id, @Valid @RequestBody GrammarRequest request) {
        return ApiResponse.ok(grammarService.update(id, request));
    }

    @Operation(summary = "[ADMIN] Xoá chủ điểm (soft delete)")
    @PreAuthorize("hasRole('ADMIN')")
    @DeleteMapping("/delete/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable UUID id) {
        grammarService.delete(id);
    }
}
