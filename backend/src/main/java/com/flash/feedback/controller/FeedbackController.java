package com.flash.feedback.controller;

import com.flash.common.ApiResponse;
import com.flash.common.PageResponse;
import com.flash.feedback.dto.FeedbackCreateRequest;
import com.flash.feedback.dto.FeedbackResponse;
import com.flash.feedback.dto.FeedbackSummaryResponse;
import com.flash.feedback.dto.FeedbackUpdateRequest;
import com.flash.feedback.dto.FeedbackViewedRequest;
import com.flash.feedback.service.FeedbackService;
import com.flash.security.CurrentUser;
import com.flash.security.UserPrincipal;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
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
import java.time.LocalDate;
import java.util.UUID;

@Tag(name = "Feedbacks", description = "Phản hồi của người dùng về từ vựng / ngữ pháp / bài kiểm tra")
@Validated
@RestController
@RequestMapping("/v1/feedbacks")
@RequiredArgsConstructor
public class FeedbackController {

    private final FeedbackService feedbackService;

    // ------------------------------------------------------------------ user

    @Operation(summary = "Gửi phản hồi về một từ / bài ngữ pháp / bài kiểm tra",
            description = "feedbackFor: 1 = flashcard, 2 = grammar, 3 = quiz. content tối đa 1000 ký tự (sau khi trim). "
                    + "Item phải tồn tại và chưa bị xoá, nếu không trả 404")
    @PostMapping("/create")
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<FeedbackResponse> create(@CurrentUser UserPrincipal me,
                                                @Valid @RequestBody FeedbackCreateRequest request) {
        return ApiResponse.ok(feedbackService.create(me.getId(), request));
    }

    @Operation(summary = "Phản hồi của tôi, mới nhất trước",
            description = "from / to là ngày yyyy-MM-dd (gồm cả ngày to), tính theo múi giờ của user. Mọi tham số đều tuỳ chọn")
    @GetMapping("/me")
    public ApiResponse<PageResponse<FeedbackResponse>> listMine(
            @CurrentUser UserPrincipal me,
            @RequestParam(required = false) Integer feedbackFor,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to,
            @RequestParam(defaultValue = "0") @Min(0) int page,
            @RequestParam(defaultValue = "20") @Min(1) @Max(100) int size) {
        return ApiResponse.ok(feedbackService.listMine(me.getId(), feedbackFor, from, to, page, size));
    }

    @Operation(summary = "Số phản hồi của tôi theo loại", description = "{flashcard, grammar, quiz}")
    @GetMapping("/me/summary")
    public ApiResponse<FeedbackSummaryResponse> summary(@CurrentUser UserPrincipal me) {
        return ApiResponse.ok(feedbackService.summary(me.getId()));
    }

    @Operation(summary = "Sửa nội dung phản hồi của tôi",
            description = "Chỉ khi chưa được admin xem; đã xem trả 409 FEEDBACK_ALREADY_VIEWED, không phải của mình / không có trả 404")
    @PutMapping("/update/{id}")
    public ApiResponse<FeedbackResponse> update(@CurrentUser UserPrincipal me, @PathVariable UUID id,
                                                @Valid @RequestBody FeedbackUpdateRequest request) {
        return ApiResponse.ok(feedbackService.update(me.getId(), id, request.getContent()));
    }

    @Operation(summary = "Xoá phản hồi của tôi",
            description = "Chỉ khi chưa được admin xem; đã xem trả 409 FEEDBACK_ALREADY_VIEWED, không phải của mình / không có trả 404")
    @DeleteMapping("/delete/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@CurrentUser UserPrincipal me, @PathVariable UUID id) {
        feedbackService.delete(me.getId(), id);
    }

    // ------------------------------------------------------------------ admin

    @Operation(summary = "[ADMIN] Phản hồi của mọi user, mới nhất trước",
            description = "Lọc theo loại (feedbackFor), trạng thái xem (isViewed) và ngày yyyy-MM-dd (from / to, gồm cả ngày to). "
                    + "Mọi tham số đều tuỳ chọn")
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping
    public ApiResponse<PageResponse<FeedbackResponse>> listAll(
            @CurrentUser UserPrincipal me,
            @RequestParam(required = false) Integer feedbackFor,
            @RequestParam(required = false) Boolean isViewed,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to,
            @RequestParam(defaultValue = "0") @Min(0) int page,
            @RequestParam(defaultValue = "20") @Min(1) @Max(100) int size) {
        return ApiResponse.ok(feedbackService.listAll(me.getId(), feedbackFor, isViewed, from, to, page, size));
    }

    @Operation(summary = "[ADMIN] Đánh dấu đã xem / chưa xem",
            description = "Đã xem thì user không còn sửa / xoá được phản hồi này")
    @PreAuthorize("hasRole('ADMIN')")
    @PutMapping("/{id}/viewed")
    public ApiResponse<FeedbackResponse> setViewed(@PathVariable UUID id,
                                                   @Valid @RequestBody FeedbackViewedRequest request) {
        return ApiResponse.ok(feedbackService.setViewed(id, request.getIsViewed()));
    }
}
