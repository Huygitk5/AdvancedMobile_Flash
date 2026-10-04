package com.flash.gamification.controller;

import com.flash.common.ApiResponse;
import com.flash.gamification.dto.LeaderboardResponse;
import com.flash.gamification.entity.RankBoard;
import com.flash.gamification.service.LeaderboardService;
import com.flash.security.CurrentUser;
import com.flash.security.UserPrincipal;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.validation.constraints.Max;
import javax.validation.constraints.Min;

@Tag(name = "Leaderboard", description = "Bảng xếp hạng (top N cache 60 giây)")
@Validated
@RestController
@RequestMapping("/v1/leaderboard")
@RequiredArgsConstructor
public class LeaderboardController {

    private final LeaderboardService leaderboardService;

    @Operation(summary = "Top N theo XP trọn đời (totalLifetimeXp)")
    @GetMapping("/xp")
    public ApiResponse<LeaderboardResponse> xp(@CurrentUser UserPrincipal me,
                                               @RequestParam(defaultValue = "10") @Min(1) @Max(100) int limit) {
        return ApiResponse.ok(leaderboardService.leaderboard(RankBoard.XP, me.getId(), limit));
    }

    @Operation(summary = "Top N theo chuỗi ngày học dài nhất (longestStreak)")
    @GetMapping("/streak")
    public ApiResponse<LeaderboardResponse> streak(@CurrentUser UserPrincipal me,
                                                   @RequestParam(defaultValue = "10") @Min(1) @Max(100) int limit) {
        return ApiResponse.ok(leaderboardService.leaderboard(RankBoard.STREAK, me.getId(), limit));
    }
}
