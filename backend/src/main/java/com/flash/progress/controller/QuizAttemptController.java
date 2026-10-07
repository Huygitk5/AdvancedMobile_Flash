package com.flash.progress.controller;

import com.flash.common.ApiResponse;
import com.flash.common.PageResponse;
import com.flash.progress.dto.QuizResultResponse;
import com.flash.progress.dto.QuizReviewItemResponse;
import com.flash.progress.dto.QuizSubmitRequest;
import com.flash.progress.service.QuizAttemptService;
import com.flash.security.CurrentUser;
import com.flash.security.UserPrincipal;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.validation.Valid;
import javax.validation.constraints.Max;
import javax.validation.constraints.Min;
import java.util.List;
import java.util.UUID;

@Tag(name = "Quizzes", description = "Đề kiểm tra, nộp bài, lịch sử làm bài")
@Validated
@RestController
@RequestMapping("/v1/quizzes")
@RequiredArgsConstructor
public class QuizAttemptController {

    private final QuizAttemptService quizAttemptService;

    @Operation(summary = "Nộp bài (server chấm)",
            description = "201 khi chấm mới, 200 nếu attemptId đã nộp (idempotent), 422 thiếu câu / thời gian không hợp lệ")
    @PostMapping("/submit")
    public ResponseEntity<ApiResponse<QuizResultResponse>> submit(@CurrentUser UserPrincipal me,
                                                                  @Valid @RequestBody QuizSubmitRequest request) {
        QuizResultResponse result = quizAttemptService.submit(me.getId(), request);
        HttpStatus status = Boolean.TRUE.equals(result.getDuplicate()) ? HttpStatus.OK : HttpStatus.CREATED;
        return ResponseEntity.status(status).body(ApiResponse.ok(result));
    }

    @Operation(summary = "Lịch sử làm bài, mới nhất trước")
    @GetMapping("/attempts")
    public ApiResponse<PageResponse<QuizResultResponse>> attempts(@CurrentUser UserPrincipal me,
                                                                  @RequestParam(required = false) UUID quizId,
                                                                  @RequestParam(defaultValue = "0") @Min(0) int page,
                                                                  @RequestParam(defaultValue = "20") @Min(1) @Max(100) int size) {
        return ApiResponse.ok(quizAttemptService.attempts(me.getId(), quizId, page, size));
    }

    @Operation(summary = "Kết quả một lần làm bài (QuizResultScreen)")
    @GetMapping("/attempts/get/{attemptId}")
    public ApiResponse<QuizResultResponse> attempt(@CurrentUser UserPrincipal me, @PathVariable UUID attemptId) {
        return ApiResponse.ok(quizAttemptService.attempt(me.getId(), attemptId));
    }

    @Operation(summary = "Xem lại bài làm (QuizReviewScreen)")
    @GetMapping("/attempts/get/{attemptId}/review")
    public ApiResponse<List<QuizReviewItemResponse>> review(@CurrentUser UserPrincipal me, @PathVariable UUID attemptId) {
        return ApiResponse.ok(quizAttemptService.review(me.getId(), attemptId));
    }
}
