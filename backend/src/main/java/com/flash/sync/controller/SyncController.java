package com.flash.sync.controller;

import com.flash.common.ApiResponse;
import com.flash.security.CurrentUser;
import com.flash.security.UserPrincipal;
import com.flash.sync.dto.ContentChanges;
import com.flash.sync.dto.SyncPullResponse;
import com.flash.sync.dto.SyncPushRequest;
import com.flash.sync.dto.SyncPushResponse;
import com.flash.sync.dto.UserDataChanges;
import com.flash.sync.service.ContentSyncService;
import com.flash.sync.service.SyncPullService;
import com.flash.sync.service.SyncPushService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.validation.Valid;
import javax.validation.constraints.Max;
import javax.validation.constraints.Min;
import java.time.Instant;

/** Đồng bộ offline-first (DATA_ARCHITECTURE.md §5, §6.11). Giới hạn 30 request/phút/user. */
@Tag(name = "Sync", description = "Đẩy hàng đợi offline lên server, kéo delta dữ liệu user và nội dung")
@Validated
@RestController
@RequestMapping("/v1/sync")
@RequiredArgsConstructor
public class SyncController {

    /** Body mẫu cho Swagger UI: id của nội dung seed V2; opId / logId nên đổi mỗi lần thử để không bị DUPLICATE. */
    private static final String PUSH_EXAMPLE = """
            {
              "deviceId": "swagger",
              "clientSentAt": "2026-10-05T08:15:30.000Z",
              "operations": [
                {"opId": "0b6e7c1a-0000-4000-8000-000000000001", "opType": "FLASHCARD_REVIEW", "createdAt": "2026-10-05T08:10:05.120Z",
                 "payload": {"logId": "a1000000-0000-4000-8000-000000000001", "flashcardId": "30000000-0000-0000-0000-000000000001",
                             "rating": "KNOW", "responseTimeMs": 1800, "reviewedAt": "2026-10-05T08:10:05.120Z"}},
                {"opId": "0b6e7c1a-0000-4000-8000-000000000002", "opType": "NOTE_UPSERT", "createdAt": "2026-10-05T08:11:00.000Z",
                 "payload": {"noteId": "b1000000-0000-4000-8000-000000000001", "flashcardId": "30000000-0000-0000-0000-000000000001",
                             "content": "beautiful = đẹp", "baseVersion": null, "clientUpdatedAt": "2026-10-05T08:11:00.000Z"}},
                {"opId": "0b6e7c1a-0000-4000-8000-000000000003", "opType": "BOOKMARK_SET", "createdAt": "2026-10-05T08:12:00.000Z",
                 "payload": {"flashcardId": "30000000-0000-0000-0000-000000000002", "bookmarked": true,
                             "clientUpdatedAt": "2026-10-05T08:12:00.000Z"}}
              ]
            }
            """;

    private final SyncPushService pushService;
    private final SyncPullService pullService;
    private final ContentSyncService contentSyncService;

    @Operation(summary = "Gửi một lô thao tác offline (tối đa 50 op)",
            description = "Mỗi op chạy trong transaction riêng, đúng thứ tự gửi lên. status từng op: APPLIED, DUPLICATE "
                    + "(opId đã xử lý, trả lại kết quả cũ), CONFLICT_SERVER_WINS, REJECTED (client bỏ op, rollback local), "
                    + "FAILED (lỗi tạm thời, giữ op và gửi lại sau)")
    @PostMapping("/push")
    public ApiResponse<SyncPushResponse> push(
            @CurrentUser UserPrincipal me,
            @io.swagger.v3.oas.annotations.parameters.RequestBody(content = @Content(
                    examples = @ExampleObject(name = "3 op", value = PUSH_EXAMPLE)))
            @Valid @RequestBody SyncPushRequest request) {
        return ApiResponse.ok(pushService.push(me.getId(), request));
    }

    @Operation(summary = "Delta dữ liệu của user từ since (gồm tombstone)",
            description = "Bỏ since ở lần đồng bộ đầu tiên. hasMore = true thì gọi tiếp ngay với cursor trả về")
    @GetMapping("/pull")
    public ApiResponse<SyncPullResponse<UserDataChanges>> pull(
            @CurrentUser UserPrincipal me,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) Instant since,
            @RequestParam(defaultValue = "500") @Min(1) @Max(1000) int limit) {
        return ApiResponse.ok(pullService.pull(me.getId(), orEpoch(since), limit));
    }

    @Operation(summary = "Delta nội dung học (topic, flashcard, ngữ pháp, quiz, quest, vật phẩm) từ since",
            description = "deleted chứa id nội dung đã xoá / bỏ xuất bản để client xoá khỏi cache")
    @GetMapping("/content")
    public ApiResponse<SyncPullResponse<ContentChanges>> content(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) Instant since,
            @RequestParam(defaultValue = "500") @Min(1) @Max(1000) int limit) {
        return ApiResponse.ok(contentSyncService.pull(orEpoch(since), limit));
    }

    private static Instant orEpoch(Instant since) {
        return since != null ? since : Instant.EPOCH;
    }
}
