package com.flash.home.controller;

import com.flash.common.ApiResponse;
import com.flash.home.dto.HomeSummaryResponse;
import com.flash.home.service.HomeService;
import com.flash.security.CurrentUser;
import com.flash.security.UserPrincipal;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "Home")
@RestController
@RequestMapping("/v1/home")
@RequiredArgsConstructor
public class HomeController {

    private final HomeService homeService;

    @Operation(summary = "Dữ liệu HomeScreen: streak, tiến độ ngày, bài đang học, gợi ý, thử thách hôm nay")
    @GetMapping("/summary")
    public ApiResponse<HomeSummaryResponse> summary(@CurrentUser UserPrincipal me) {
        return ApiResponse.ok(homeService.summary(me.getId()));
    }
}
