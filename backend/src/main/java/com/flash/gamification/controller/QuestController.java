package com.flash.gamification.controller;

import com.flash.common.ApiResponse;
import com.flash.gamification.dto.ClaimQuestResponse;
import com.flash.gamification.dto.TodayQuestsResponse;
import com.flash.gamification.service.QuestService;
import com.flash.security.CurrentUser;
import com.flash.security.UserPrincipal;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@Tag(name = "Quests", description = "Nhiệm vụ hôm nay và nhận thưởng")
@RestController
@RequestMapping("/v1/quests")
@RequiredArgsConstructor
public class QuestController {

    private final QuestService questService;

    @Operation(summary = "Nhiệm vụ của chu kỳ hiện tại (server tự giao nếu chưa có) và số dư XP")
    @GetMapping("/today")
    public ApiResponse<TodayQuestsResponse> today(@CurrentUser UserPrincipal me) {
        return ApiResponse.ok(questService.today(me.getId()));
    }

    @Operation(summary = "Nhận thưởng nhiệm vụ",
            description = "409 ALREADY_CLAIMED nếu đã nhận, 422 QUEST_NOT_COMPLETED nếu tiến độ (do server tính) chưa đủ")
    @PostMapping("/claim/{userQuestId}")
    public ApiResponse<ClaimQuestResponse> claim(@CurrentUser UserPrincipal me, @PathVariable UUID userQuestId) {
        return ApiResponse.ok(questService.claim(me.getId(), userQuestId));
    }
}
