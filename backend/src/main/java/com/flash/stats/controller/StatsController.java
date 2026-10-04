package com.flash.stats.controller;

import com.flash.common.ApiResponse;
import com.flash.security.CurrentUser;
import com.flash.security.UserPrincipal;
import com.flash.stats.dto.StatisticsResponse;
import com.flash.stats.dto.StatsRange;
import com.flash.stats.service.StatsService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "Users", description = "Hồ sơ, mật khẩu, cài đặt của người dùng hiện tại")
@RestController
@RequestMapping("/v1/users")
@RequiredArgsConstructor
public class StatsController {

    private final StatsService statsService;

    @Operation(summary = "Thống kê học tập (ProgressScreen)",
            description = "WEEK/MONTH trả đủ 7/30 ngày (ngày không học = 0); accuracy = correctAnswers / totalAnswers")
    @GetMapping("/me/statistics")
    public ApiResponse<StatisticsResponse> statistics(@CurrentUser UserPrincipal me,
                                                      @RequestParam(defaultValue = "WEEK") StatsRange range) {
        return ApiResponse.ok(statsService.statistics(me.getId(), range));
    }
}
