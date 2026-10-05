package com.flash.admin.controller;

import com.flash.admin.dto.AdminOverviewResponse;
import com.flash.admin.service.AdminOverviewService;
import com.flash.common.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "Admin", description = "Số liệu tổng quan cho quản trị viên")
@PreAuthorize("hasRole('ADMIN')")
@RestController
@RequestMapping("/v1/admin")
@RequiredArgsConstructor
public class AdminOverviewController {

    private final AdminOverviewService service;

    @Operation(summary = "Tổng quan hệ thống",
            description = "students chỉ đếm tài khoản role USER; quản trị viên được đếm riêng ở admins")
    @GetMapping("/overview")
    public ApiResponse<AdminOverviewResponse> overview() {
        return ApiResponse.ok(service.overview());
    }
}
