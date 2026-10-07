package com.flash.progress.controller;

import com.flash.common.ApiResponse;
import com.flash.common.PageResponse;
import com.flash.content.dto.FlashcardResponse;
import com.flash.progress.dto.BookmarkRequest;
import com.flash.progress.dto.BookmarkResult;
import com.flash.progress.dto.NoteResponse;
import com.flash.progress.dto.NoteResult;
import com.flash.progress.dto.NoteUpsertRequest;
import com.flash.progress.dto.ReviewRequest;
import com.flash.progress.dto.ReviewResponse;
import com.flash.progress.service.BookmarkService;
import com.flash.progress.service.NoteService;
import com.flash.progress.service.SrsService;
import com.flash.security.CurrentUser;
import com.flash.security.UserPrincipal;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
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
import java.util.List;
import java.util.UUID;

/** Thao tác học trên từ vựng: ôn SRS, ghi chú, bookmark (DATA_ARCHITECTURE.md §6.5). */
@Tag(name = "Flashcards", description = "Từ vựng, kèm ghi chú / bookmark / SRS của user")
@Validated
@RestController
@RequestMapping("/v1/flashcards")
@RequiredArgsConstructor
public class StudyController {

    private final SrsService srsService;
    private final NoteService noteService;
    private final BookmarkService bookmarkService;

    @Operation(summary = "Gửi một lượt Again/Know",
            description = "Server phát lại log để tính box/dueAt, cộng XP và streak. Gửi lại cùng logId không bị tính hai lần")
    @PostMapping("/review")
    public ApiResponse<ReviewResponse> review(@CurrentUser UserPrincipal me, @Valid @RequestBody ReviewRequest request) {
        return ApiResponse.ok(srsService.review(me.getId(), request));
    }

    @Operation(summary = "Thẻ đến hạn ôn (SRS), hạn sớm nhất trước")
    @GetMapping("/due")
    public ApiResponse<List<FlashcardResponse>> due(@CurrentUser UserPrincipal me,
                                                    @RequestParam(required = false) UUID topicId,
                                                    @RequestParam(defaultValue = "20") @Min(1) @Max(100) int limit) {
        return ApiResponse.ok(srsService.due(me.getId(), topicId, limit));
    }

    // ------------------------------------------------------------------ bookmarks

    @Operation(summary = "Danh sách từ yêu thích")
    @GetMapping("/bookmarks")
    public ApiResponse<PageResponse<FlashcardResponse>> bookmarks(@CurrentUser UserPrincipal me,
                                                                  @RequestParam(defaultValue = "0") @Min(0) int page,
                                                                  @RequestParam(defaultValue = "20") @Min(1) @Max(100) int size) {
        return ApiResponse.ok(bookmarkService.list(me.getId(), page, size));
    }

    @Operation(summary = "Thêm bookmark", description = "201 khi tạo mới, 200 nếu đã có (idempotent)")
    @PostMapping("/bookmarks/create")
    public ResponseEntity<ApiResponse<BookmarkResult>> bookmark(@CurrentUser UserPrincipal me,
                                                                @Valid @RequestBody BookmarkRequest request) {
        BookmarkResult result = bookmarkService.bookmark(me.getId(), request.getFlashcardId(), request.getClientUpdatedAt());
        return ResponseEntity.status(result.isCreated() ? HttpStatus.CREATED : HttpStatus.OK).body(ApiResponse.ok(result));
    }

    @Operation(summary = "Bỏ bookmark (tombstone)")
    @DeleteMapping("/bookmarks/delete/{flashcardId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void unbookmark(@CurrentUser UserPrincipal me, @PathVariable UUID flashcardId) {
        bookmarkService.unbookmark(me.getId(), flashcardId, null);
    }

    // ------------------------------------------------------------------ notes

    @Operation(summary = "Ghi chú của một từ")
    @GetMapping("/notes/get/{flashcardId}")
    public ApiResponse<NoteResponse> getNote(@CurrentUser UserPrincipal me, @PathVariable UUID flashcardId) {
        return ApiResponse.ok(noteService.get(me.getId(), flashcardId));
    }

    @Operation(summary = "Tạo/sửa ghi chú (upsert, Last-Write-Wins)",
            description = "resolution = CONFLICT_SERVER_WINS kèm bản server nếu version lệch và bản client cũ hơn")
    @PutMapping("/notes/update")
    public ApiResponse<NoteResult> upsertNote(@CurrentUser UserPrincipal me, @Valid @RequestBody NoteUpsertRequest request) {
        return ApiResponse.ok(noteService.upsert(me.getId(), request));
    }

    @Operation(summary = "Xoá ghi chú (tombstone)")
    @DeleteMapping("/notes/delete/{flashcardId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteNote(@CurrentUser UserPrincipal me, @PathVariable UUID flashcardId) {
        noteService.delete(me.getId(), flashcardId, null, null);
    }
}
