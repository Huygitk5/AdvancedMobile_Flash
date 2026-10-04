package com.flash.progress.controller;

import com.flash.common.ApiResponse;
import com.flash.progress.dto.LessonCompleteRequest;
import com.flash.progress.dto.LessonCompleteResponse;
import com.flash.progress.service.LessonService;
import com.flash.security.CurrentUser;
import com.flash.security.UserPrincipal;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.validation.Valid;

@Tag(name = "Lessons", description = "Báo hoàn thành bài học (topic hoặc ngữ pháp)")
@RestController
@RequestMapping("/v1/lessons")
@RequiredArgsConstructor
public class LessonController {

    private final LessonService lessonService;

    @Operation(summary = "Báo hoàn thành 1 bài",
            description = "201 khi ghi nhận mới, 200 nếu id đã được gửi trước đó (idempotent)")
    @PostMapping("/complete")
    public ResponseEntity<ApiResponse<LessonCompleteResponse>> complete(@CurrentUser UserPrincipal me,
                                                                        @Valid @RequestBody LessonCompleteRequest request) {
        LessonCompleteResponse result = lessonService.complete(me.getId(), request);
        return ResponseEntity.status(result.isDuplicate() ? HttpStatus.OK : HttpStatus.CREATED).body(ApiResponse.ok(result));
    }
}
