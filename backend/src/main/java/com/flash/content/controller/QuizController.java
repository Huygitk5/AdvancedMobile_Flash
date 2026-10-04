package com.flash.content.controller;

import com.flash.common.ApiResponse;
import com.flash.content.dto.QuizDetailResponse;
import com.flash.content.dto.QuizRequest;
import com.flash.content.dto.QuizResponse;
import com.flash.content.service.QuizService;
import com.flash.security.CurrentUser;
import com.flash.security.UserPrincipal;
import com.flash.user.entity.UserRole;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
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
import java.util.List;
import java.util.UUID;

@Tag(name = "Quizzes", description = "Đề kiểm tra, nộp bài, lịch sử làm bài")
@RestController
@RequestMapping("/v1/quizzes")
@RequiredArgsConstructor
public class QuizController {

    private final QuizService quizService;

    @Operation(summary = "Danh sách quiz, lọc theo topicId hoặc grammarLessonId")
    @GetMapping
    public ApiResponse<List<QuizResponse>> list(@CurrentUser UserPrincipal me,
                                                @RequestParam(required = false) UUID topicId,
                                                @RequestParam(required = false) UUID grammarLessonId,
                                                @RequestParam(defaultValue = "false") boolean includeUnpublished) {
        boolean showDrafts = includeUnpublished && me.getRole() == UserRole.ADMIN;
        return ApiResponse.ok(quizService.list(topicId, grammarLessonId, showDrafts));
    }

    @Operation(summary = "Đề bài: câu hỏi, 4 đáp án, đáp án đúng, giải thích (để làm offline)")
    @GetMapping("/get/{id}")
    public ApiResponse<QuizDetailResponse> get(@CurrentUser UserPrincipal me, @PathVariable UUID id) {
        return ApiResponse.ok(quizService.get(id, me.getRole() == UserRole.ADMIN));
    }

    @Operation(summary = "[ADMIN] Tạo quiz (kèm câu hỏi)")
    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping("/create")
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<QuizDetailResponse> create(@Valid @RequestBody QuizRequest request) {
        return ApiResponse.ok(quizService.create(request));
    }

    @Operation(summary = "[ADMIN] Sửa quiz (questions thay toàn bộ)")
    @PreAuthorize("hasRole('ADMIN')")
    @PutMapping("/update/{id}")
    public ApiResponse<QuizDetailResponse> update(@PathVariable UUID id, @Valid @RequestBody QuizRequest request) {
        return ApiResponse.ok(quizService.update(id, request));
    }

    @Operation(summary = "[ADMIN] Xoá quiz (soft delete)")
    @PreAuthorize("hasRole('ADMIN')")
    @DeleteMapping("/delete/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable UUID id) {
        quizService.delete(id);
    }
}
