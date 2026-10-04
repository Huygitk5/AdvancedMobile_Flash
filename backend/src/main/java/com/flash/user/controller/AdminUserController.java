package com.flash.user.controller;

import com.flash.common.ApiResponse;
import com.flash.common.PageResponse;
import com.flash.security.CurrentUser;
import com.flash.security.UserPrincipal;
import com.flash.user.dto.AdminCreateUserRequest;
import com.flash.user.dto.AdminUpdateUserRequest;
import com.flash.user.dto.UserResponse;
import com.flash.user.entity.UserStatus;
import com.flash.user.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
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

@Tag(name = "Users (Admin)", description = "Quản lý người dùng, chỉ ADMIN")
@PreAuthorize("hasRole('ADMIN')")
@Validated
@RestController
@RequestMapping("/v1/users")
@RequiredArgsConstructor
public class AdminUserController {

    private final UserService userService;

    @Operation(summary = "Danh sách user (tìm theo email/tên, lọc trạng thái)")
    @GetMapping
    public ApiResponse<PageResponse<UserResponse>> list(@RequestParam(required = false) String keyword,
                                                        @RequestParam(required = false) UserStatus status,
                                                        @RequestParam(defaultValue = "0") @Min(0) int page,
                                                        @RequestParam(defaultValue = "20") @Min(1) @Max(100) int size) {
        PageRequest pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));
        return ApiResponse.ok(PageResponse.of(userService.search(keyword, status, pageable)));
    }

    @Operation(summary = "Tạo user")
    @PostMapping("/create")
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<UserResponse> create(@Valid @RequestBody AdminCreateUserRequest request) {
        return ApiResponse.ok(userService.adminCreate(request));
    }

    @Operation(summary = "Sửa / khoá / đổi quyền user")
    @PutMapping("/update/{id}")
    public ApiResponse<UserResponse> update(@CurrentUser UserPrincipal admin, @PathVariable UUID id,
                                            @Valid @RequestBody AdminUpdateUserRequest request) {
        return ApiResponse.ok(userService.adminUpdate(admin.getId(), id, request));
    }

    @Operation(summary = "Xoá user (soft delete)")
    @DeleteMapping("/delete/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@CurrentUser UserPrincipal admin, @PathVariable UUID id) {
        userService.adminDelete(admin.getId(), id);
    }
}
