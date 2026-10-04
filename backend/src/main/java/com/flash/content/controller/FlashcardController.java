package com.flash.content.controller;

import com.flash.common.ApiResponse;
import com.flash.common.PageResponse;
import com.flash.content.dto.FlashcardRequest;
import com.flash.content.dto.FlashcardResponse;
import com.flash.content.service.FlashcardService;
import com.flash.security.CurrentUser;
import com.flash.security.UserPrincipal;
import com.flash.user.entity.UserRole;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
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
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Size;
import java.util.List;
import java.util.UUID;

@Tag(name = "Flashcards", description = "Từ vựng, kèm ghi chú / bookmark / SRS của user")
@Validated
@RestController
@RequestMapping("/v1/flashcards")
@RequiredArgsConstructor
public class FlashcardController {

    private final FlashcardService flashcardService;

    @Operation(summary = "Từ vựng của một chủ đề")
    @GetMapping
    public ApiResponse<List<FlashcardResponse>> listByTopic(@CurrentUser UserPrincipal me,
                                                            @RequestParam UUID topicId) {
        return ApiResponse.ok(flashcardService.listByTopic(me.getId(), topicId, me.getRole() == UserRole.ADMIN));
    }

    @Operation(summary = "Chi tiết một từ (BottomSheet)")
    @GetMapping("/get/{id}")
    public ApiResponse<FlashcardResponse> get(@CurrentUser UserPrincipal me, @PathVariable UUID id) {
        return ApiResponse.ok(flashcardService.get(me.getId(), id, me.getRole() == UserRole.ADMIN));
    }

    @Operation(summary = "Tìm theo từ tiếng Anh hoặc nghĩa tiếng Việt")
    @GetMapping("/search")
    public ApiResponse<PageResponse<FlashcardResponse>> search(@CurrentUser UserPrincipal me,
                                                               @RequestParam @NotBlank @Size(max = 100) String keyword,
                                                               @RequestParam(defaultValue = "0") @Min(0) int page,
                                                               @RequestParam(defaultValue = "20") @Min(1) @Max(100) int size) {
        return ApiResponse.ok(flashcardService.search(me.getId(), keyword, page, size));
    }

    @Operation(summary = "[ADMIN] Thêm từ vào chủ đề",
            description = "Nếu từ đã bị xoá trước đó trong cùng chủ đề thì khôi phục lại")
    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping("/create")
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<FlashcardResponse> create(@Valid @RequestBody FlashcardRequest request) {
        return ApiResponse.ok(flashcardService.create(request));
    }

    @Operation(summary = "[ADMIN] Sửa từ (có thể chuyển sang chủ đề khác)")
    @PreAuthorize("hasRole('ADMIN')")
    @PutMapping("/update/{id}")
    public ApiResponse<FlashcardResponse> update(@PathVariable UUID id, @Valid @RequestBody FlashcardRequest request) {
        return ApiResponse.ok(flashcardService.update(id, request));
    }

    @Operation(summary = "[ADMIN] Xoá từ (soft delete)")
    @PreAuthorize("hasRole('ADMIN')")
    @DeleteMapping("/delete/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable UUID id) {
        flashcardService.delete(id);
    }
}
