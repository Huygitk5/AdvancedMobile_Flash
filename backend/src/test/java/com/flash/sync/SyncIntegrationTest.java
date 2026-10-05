package com.flash.sync;

import com.fasterxml.jackson.databind.JsonNode;
import com.flash.support.IntegrationTestBase;
import com.flash.sync.service.SyncOperationCleanupJob;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder;

import java.sql.Timestamp;
import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/** /v1/sync/push, /pull, /content (DATA_ARCHITECTURE.md §6.11) trên MySQL thật với nội dung seed V2. */
class SyncIntegrationTest extends IntegrationTestBase {

    private static final String DAILY_LIFE = "10000000-0000-0000-0000-000000000001";
    private static final String BEAUTIFUL = "30000000-0000-0000-0000-000000000001";
    private static final String OPPORTUNITY = "30000000-0000-0000-0000-000000000002";
    private static final String QUEST_LEARN_20 = "50000000-0000-0000-0000-000000000001";
    private static final String BORDER_FREE = "60000000-0000-0000-0000-000000000001";
    private static final String BORDER_500 = "60000000-0000-0000-0000-000000000002";

    @Autowired
    private JdbcTemplate jdbc;

    @Autowired
    private SyncOperationCleanupJob cleanupJob;

    // ------------------------------------------------------------------ push

    /** DoD G5: review → APPLIED, ghi chú xung đột → CONFLICT_SERVER_WINS, quest chưa xong → REJECTED; gửi lại → toàn DUPLICATE. */
    @Test
    void pushBatchThenResendIsAllDuplicate() throws Exception {
        JsonNode auth = register(uniqueEmail());
        String token = bearer(auth);
        String userId = auth.at("/user/id").asText();
        Instant now = Instant.now();

        // Thiết bị khác đã sửa ghi chú lúc "now"; thiết bị này sửa offline từ 1 giờ trước, dựa trên version cũ
        String noteId = UUID.randomUUID().toString();
        Map<String, Object> serverNote = new HashMap<>();
        serverNote.put("noteId", noteId);
        serverNote.put("flashcardId", BEAUTIFUL);
        serverNote.put("content", "bản từ máy tính bảng");
        serverNote.put("clientUpdatedAt", now.toString());
        send(put("/v1/flashcards/notes/update"), token, serverNote).andExpect(status().isOk());
        String learn20 = questId(getData(token, "/v1/quests/today"), QUEST_LEARN_20);

        Map<String, Object> staleNote = new HashMap<>();
        staleNote.put("noteId", noteId);
        staleNote.put("flashcardId", BEAUTIFUL);
        staleNote.put("content", "apple = táo");
        staleNote.put("baseVersion", 99);
        staleNote.put("clientUpdatedAt", now.minus(Duration.ofHours(1)).toString());

        List<Map<String, Object>> ops = List.of(
                op("FLASHCARD_REVIEW", review(BEAUTIFUL, "KNOW", now.minusSeconds(60))),
                op("NOTE_UPSERT", staleNote),
                op("QUEST_CLAIM", Map.of("userQuestId", learn20, "claimedAt", now.toString())));

        JsonNode first = push(token, now, ops);
        JsonNode results = first.get("results");
        assertThat(statuses(results)).containsExactly("APPLIED", "CONFLICT_SERVER_WINS", "REJECTED");
        assertThat(results.at("/0/data/xpAwarded").asInt()).isEqualTo(7);
        assertThat(results.at("/0/data/progress/box").asInt()).isEqualTo(1);
        assertThat(results.at("/1/data/note/content").asText()).isEqualTo("bản từ máy tính bảng");
        assertThat(results.at("/2/errorCode").asText()).isEqualTo("QUEST_NOT_COMPLETED");
        assertThat(results.at("/2/message").asText()).isEqualTo("Tiến độ 1/20");
        assertThat(first.at("/user/currentXp").asInt()).isEqualTo(7);
        assertThat(first.at("/user/streakDays").asInt()).isEqualTo(1);

        // Mất mạng trước khi nhận response => gửi lại nguyên lô
        JsonNode retry = push(token, Instant.now(), ops);
        assertThat(statuses(retry.get("results"))).containsExactly("DUPLICATE", "DUPLICATE", "DUPLICATE");
        assertThat(retry.at("/results/0/data/progress/box").asInt()).isEqualTo(1);
        assertThat(retry.at("/results/1/data/resolution").asText()).isEqualTo("CONFLICT_SERVER_WINS");
        assertThat(retry.at("/results/2/errorCode").asText()).isEqualTo("QUEST_NOT_COMPLETED");
        assertThat(retry.at("/user/currentXp").asInt()).isEqualTo(7);

        assertThat(jdbc.queryForObject("SELECT COUNT(*) FROM flashcard_review_logs WHERE user_id = ?", Integer.class, userId))
                .isEqualTo(1);
        assertThat(jdbc.queryForObject("SELECT COALESCE(SUM(amount), 0) FROM xp_transactions WHERE user_id = ?",
                Integer.class, userId)).isEqualTo(7);
        assertThat(jdbc.queryForList("SELECT status FROM sync_operations WHERE user_id = ? ORDER BY status",
                String.class, userId)).containsExactly("APPLIED", "APPLIED", "REJECTED");
    }

    /** Máy chậm 1 ngày: giờ trong lô được cộng clockOffset nên review "hôm qua" theo máy thực ra là vừa xong. */
    @Test
    void clockOffsetIsAppliedToEveryTimestamp() throws Exception {
        JsonNode auth = register(uniqueEmail());
        String token = bearer(auth);
        Instant deviceNow = Instant.now().minus(Duration.ofDays(1));
        Instant reviewedOnDevice = deviceNow.minusSeconds(30);

        JsonNode response = push(token, deviceNow, List.of(op("FLASHCARD_REVIEW", review(BEAUTIFUL, "KNOW", reviewedOnDevice))));

        long offsetMs = response.get("clockOffsetMs").asLong();
        assertThat(offsetMs).isBetween(Duration.ofDays(1).toMillis(), Duration.ofDays(1).plusMinutes(1).toMillis());
        Timestamp stored = jdbc.queryForObject("SELECT reviewed_at FROM flashcard_review_logs WHERE user_id = ?",
                Timestamp.class, auth.at("/user/id").asText());
        // DATETIME(3) làm tròn tới ms
        assertThat(Duration.between(reviewedOnDevice.plusMillis(offsetMs), stored.toInstant()).abs())
                .isLessThan(Duration.ofMillis(5));
        assertThat(Duration.between(stored.toInstant(), Instant.now()).abs()).isLessThan(Duration.ofMinutes(1));
    }

    @Test
    void invalidOpsAreRejectedWithoutBlockingTheRest() throws Exception {
        String token = bearer(register(uniqueEmail()));
        Instant now = Instant.now();

        JsonNode response = push(token, now, List.of(
                op("TELEPORT", Map.of("x", 1)),
                op("FLASHCARD_REVIEW", Map.of("flashcardId", BEAUTIFUL, "rating", "KNOW")),
                op("FLASHCARD_REVIEW", review(UUID.randomUUID().toString(), "KNOW", now)),
                op("BOOKMARK_SET", Map.of("flashcardId", OPPORTUNITY, "bookmarked", true, "clientUpdatedAt", now.toString()))));

        JsonNode results = response.get("results");
        assertThat(statuses(results)).containsExactly("REJECTED", "REJECTED", "REJECTED", "APPLIED");
        assertThat(results.at("/0/errorCode").asText()).isEqualTo("BAD_REQUEST");
        assertThat(results.at("/1/errorCode").asText()).isEqualTo("VALIDATION_ERROR");
        assertThat(results.at("/1/message").asText()).contains("logId").contains("reviewedAt");
        assertThat(results.at("/2/errorCode").asText()).isEqualTo("NOT_FOUND");
        assertThat(results.at("/3/data/isBookmarked").asBoolean()).isTrue();
    }

    @Test
    void batchOver50OpsIsRejectedAsWhole() throws Exception {
        String token = bearer(register(uniqueEmail()));
        List<Map<String, Object>> ops = new ArrayList<>();
        for (int i = 0; i < 51; i++) {
            ops.add(op("BOOKMARK_SET", Map.of("flashcardId", BEAUTIFUL, "bookmarked", i % 2 == 0)));
        }
        send(post("/v1/sync/push"), token, Map.of("clientSentAt", Instant.now().toString(), "operations", ops))
                .andExpect(status().isBadRequest());
    }

    /** opId của SHOP_PURCHASE cũng là Idempotency-Key: REST và sync dùng chung sổ sync_operations. */
    @Test
    void shopPurchaseSharesIdempotencyWithRestEndpoint() throws Exception {
        String token = bearer(register(uniqueEmail()));
        Map<String, Object> purchase = op("SHOP_PURCHASE", Map.of("rewardItemId", BORDER_FREE));

        JsonNode pushed = push(token, Instant.now(), List.of(purchase));
        assertThat(statuses(pushed.get("results"))).containsExactly("APPLIED");
        String inventoryId = pushed.at("/results/0/data/inventory/id").asText();

        JsonNode viaRest = dataOf(send(post("/v1/shop/purchase").header("Idempotency-Key", purchase.get("opId")), token,
                Map.of("rewardItemId", BORDER_FREE)).andExpect(status().isCreated()));
        assertThat(viaRest.at("/inventory/id").asText()).isEqualTo(inventoryId);

        // Không đủ XP qua sync => REJECTED; gửi lại cùng key qua REST nhận đúng lỗi đó
        Map<String, Object> tooExpensive = op("SHOP_PURCHASE", Map.of("rewardItemId", BORDER_500));
        JsonNode rejected = push(token, Instant.now(), List.of(tooExpensive));
        assertThat(rejected.at("/results/0/errorCode").asText()).isEqualTo("INSUFFICIENT_XP");
        send(post("/v1/shop/purchase").header("Idempotency-Key", tooExpensive.get("opId")), token,
                Map.of("rewardItemId", BORDER_500)).andExpect(status().isConflict());
    }

    @Test
    void profileAndSettingsUseLastWriteWins() throws Exception {
        JsonNode auth = register(uniqueEmail());
        String token = bearer(auth);
        Instant now = Instant.now();
        int version = auth.at("/user/version").asInt();

        JsonNode first = push(token, now, List.of(
                op("PROFILE_UPDATE", Map.of("slogan", "Mới nhất", "baseVersion", version, "clientUpdatedAt", now.toString())),
                op("SETTINGS_UPDATE", Map.of("isDarkMode", true, "clientUpdatedAt", now.toString()))));
        assertThat(statuses(first.get("results"))).containsExactly("APPLIED", "APPLIED");

        // Thiết bị offline lâu ngày gửi thay đổi cũ hơn với version cũ: server giữ bản mới
        Instant older = now.minus(Duration.ofHours(2));
        JsonNode stale = push(token, Instant.now(), List.of(
                op("PROFILE_UPDATE", Map.of("slogan", "Cũ", "baseVersion", version, "clientUpdatedAt", older.toString())),
                op("SETTINGS_UPDATE", Map.of("isDarkMode", false, "clientUpdatedAt", older.toString()))));
        assertThat(statuses(stale.get("results"))).containsExactly("CONFLICT_SERVER_WINS", "CONFLICT_SERVER_WINS");
        assertThat(stale.at("/results/0/data/user/slogan").asText()).isEqualTo("Mới nhất");
        assertThat(stale.at("/results/1/data/settings/isDarkMode").asBoolean()).isTrue();
    }

    // ------------------------------------------------------------------ pull

    @Test
    void pullReturnsUserDeltaWithTombstonesAndCursor() throws Exception {
        String token = bearer(register(uniqueEmail()));
        Instant now = Instant.now();
        push(token, now, List.of(
                op("FLASHCARD_REVIEW", review(BEAUTIFUL, "KNOW", now.minusSeconds(60))),
                op("BOOKMARK_SET", Map.of("flashcardId", OPPORTUNITY, "bookmarked", true, "clientUpdatedAt", now.minusSeconds(20).toString())),
                op("BOOKMARK_SET", Map.of("flashcardId", OPPORTUNITY, "bookmarked", false, "clientUpdatedAt", now.minusSeconds(10).toString()))));

        JsonNode full = getData(token, "/v1/sync/pull");
        assertThat(full.get("hasMore").asBoolean()).isFalse();
        JsonNode changes = full.get("changes");
        assertThat(changes.at("/userFlashcardProgress/0/flashcardId").asText()).isEqualTo(BEAUTIFUL);
        assertThat(changes.at("/userBookmarks/0/flashcardId").asText()).isEqualTo(OPPORTUNITY);
        assertThat(changes.at("/userBookmarks/0/deletedAt").isMissingNode()).isFalse();
        assertThat(changes.at("/userTopicProgress/0/topicId").asText()).isEqualTo(DAILY_LIFE);
        assertThat(changes.get("userQuests")).isNotEmpty();
        assertThat(changes.get("dailyStatistics")).hasSize(1);
        assertThat(changes.at("/user/currentXp").asInt()).isEqualTo(7);
        assertThat(changes.at("/settings/appLanguage").asText()).isEqualTo("vi");

        // Cursor lùi 2 giây so với lúc truy vấn
        Instant cursor = Instant.parse(full.get("cursor").asText());
        assertThat(cursor).isBefore(Instant.now().minusSeconds(1));

        // Không có gì mới kể từ một thời điểm trong tương lai: danh sách rỗng, user vẫn có
        JsonNode empty = getData(token, "/v1/sync/pull?since=" + dbNow().plusSeconds(60));
        assertThat(empty.at("/changes/userFlashcardProgress")).isEmpty();
        assertThat(empty.at("/changes/settings").isMissingNode()).isTrue();
        assertThat(empty.at("/changes/user/id").isMissingNode()).isFalse();
    }

    @Test
    void pullPagesThroughWithHasMore() throws Exception {
        String token = bearer(register(uniqueEmail()));
        Instant now = Instant.now();
        push(token, now, List.of(op("FLASHCARD_REVIEW", review(BEAUTIFUL, "KNOW", now.minusSeconds(120)))));
        Thread.sleep(20);
        push(token, Instant.now(), List.of(op("FLASHCARD_REVIEW", review(OPPORTUNITY, "AGAIN", now.minusSeconds(60)))));

        Set<String> cards = new HashSet<>();
        String since = Instant.EPOCH.toString();
        int pages = 0;
        boolean hasMore = true;
        while (hasMore) {
            JsonNode page = getData(token, "/v1/sync/pull?limit=1&since=" + since);
            page.at("/changes/userFlashcardProgress").forEach(p -> cards.add(p.get("flashcardId").asText()));
            hasMore = page.get("hasMore").asBoolean();
            since = page.get("cursor").asText();
            assertThat(++pages).isLessThan(50);
        }
        assertThat(pages).isGreaterThan(1);
        assertThat(cards).containsExactlyInAnyOrder(BEAUTIFUL, OPPORTUNITY);
    }

    @Test
    void contentPullReportsPublishedAndDeletedContent() throws Exception {
        String admin = bearer(registerAdmin());
        String user = bearer(register(uniqueEmail()));

        JsonNode all = getData(user, "/v1/sync/content");
        assertThat(ids(all.at("/changes/topics"))).contains(DAILY_LIFE);
        assertThat(ids(all.at("/changes/flashcards"))).contains(BEAUTIFUL);
        assertThat(all.at("/changes/quizQuestions/0/options")).hasSize(4);
        assertThat(all.at("/changes/rewardItems")).isNotEmpty();
        assertThat(all.at("/changes/questDefinitions")).isNotEmpty();

        Instant since = dbNow();
        String topicId = dataOf(send(post("/v1/topics/create"), admin, Map.of("title", "Sync topic", "iconPath", "x.png",
                "isPublished", true)).andExpect(status().isCreated())).get("id").asText();
        String cardId = dataOf(send(post("/v1/flashcards/create"), admin, Map.of("topicId", topicId, "word", "sync",
                "partOfSpeech", "verb", "pronunciation", "/sɪŋk/", "meaning", "đồng bộ"))
                .andExpect(status().isCreated())).get("id").asText();

        JsonNode added = getData(user, "/v1/sync/content?since=" + since);
        assertThat(ids(added.at("/changes/topics"))).contains(topicId);
        assertThat(ids(added.at("/changes/flashcards"))).contains(cardId);

        // Bỏ xuất bản topic: topic vào deleted; xuất bản lại thì thẻ bên dưới được gửi kèm dù thẻ không đổi
        Instant beforeHide = dbNow();
        send(put("/v1/topics/update/" + topicId), admin, Map.of("title", "Sync topic", "iconPath", "x.png",
                "isPublished", false)).andExpect(status().isOk());
        JsonNode hidden = getData(user, "/v1/sync/content?since=" + beforeHide);
        assertThat(texts(hidden.at("/changes/deleted/topics"))).contains(topicId);
        assertThat(ids(hidden.at("/changes/topics"))).doesNotContain(topicId);

        Thread.sleep(50);
        Instant beforeShow = dbNow();
        send(put("/v1/topics/update/" + topicId), admin, Map.of("title", "Sync topic", "iconPath", "x.png",
                "isPublished", true)).andExpect(status().isOk());
        JsonNode shown = getData(user, "/v1/sync/content?since=" + beforeShow);
        assertThat(ids(shown.at("/changes/topics"))).contains(topicId);
        assertThat(ids(shown.at("/changes/flashcards"))).contains(cardId);

        Instant beforeDelete = dbNow();
        mockMvc.perform(delete("/v1/flashcards/delete/" + cardId).header("Authorization", admin))
                .andExpect(status().isNoContent());
        JsonNode deleted = getData(user, "/v1/sync/content?since=" + beforeDelete);
        assertThat(texts(deleted.at("/changes/deleted/flashcards"))).contains(cardId);
    }

    // ------------------------------------------------------------------ rate limit, cleanup

    @Test
    void syncEndpointsAreRateLimitedPerUser() throws Exception {
        String token = bearer(register(uniqueEmail()));
        // Cửa sổ đếm theo phút: tránh để 31 request rơi vào 2 phút khác nhau
        long secondOfMinute = Instant.now().getEpochSecond() % 60;
        if (secondOfMinute > 50) {
            Thread.sleep((61 - secondOfMinute) * 1000);
        }
        for (int i = 0; i < 30; i++) {
            mockMvc.perform(get("/v1/sync/pull?since=" + Instant.now()).header("Authorization", token))
                    .andExpect(status().isOk());
        }
        mockMvc.perform(get("/v1/sync/content").header("Authorization", token))
                .andExpect(status().isTooManyRequests());

        // User khác không bị ảnh hưởng
        String other = bearer(register(uniqueEmail()));
        mockMvc.perform(get("/v1/sync/pull").header("Authorization", other)).andExpect(status().isOk());
    }

    @Test
    void cleanupJobDeletesOperationsOlderThan30Days() throws Exception {
        String userId = register(uniqueEmail()).at("/user/id").asText();
        String oldOp = UUID.randomUUID().toString();
        String recentOp = UUID.randomUUID().toString();
        String insert = "INSERT INTO sync_operations (op_id, user_id, op_type, status, client_created_at, processed_at) "
                + "VALUES (?, ?, 'BOOKMARK_SET', 'APPLIED', UTC_TIMESTAMP(3), UTC_TIMESTAMP(3) - INTERVAL ? DAY)";
        jdbc.update(insert, oldOp, userId, 31);
        jdbc.update(insert, recentOp, userId, 29);

        cleanupJob.purgeOldOperations();

        assertThat(jdbc.queryForList("SELECT op_id FROM sync_operations WHERE user_id = ?", String.class, userId))
                .containsExactly(recentOp);
    }

    // ------------------------------------------------------------------ helpers

    /** Giờ của MySQL (đồng hồ VM chạy Docker có thể lệch vài giây so với JVM). */
    private Instant dbNow() {
        return jdbc.queryForObject("SELECT UTC_TIMESTAMP(3)", Timestamp.class).toInstant();
    }

    private JsonNode push(String token, Instant clientSentAt, List<Map<String, Object>> ops) throws Exception {
        Map<String, Object> body = Map.of("deviceId", "device-1", "clientSentAt", clientSentAt.toString(), "operations", ops);
        return dataOf(send(post("/v1/sync/push"), token, body).andExpect(status().isOk()));
    }

    private static Map<String, Object> op(String type, Map<String, Object> payload) {
        return Map.of("opId", UUID.randomUUID().toString(), "opType", type, "createdAt", Instant.now().toString(),
                "payload", payload);
    }

    private static Map<String, Object> review(String flashcardId, String rating, Instant at) {
        return Map.of("logId", UUID.randomUUID().toString(), "flashcardId", flashcardId, "rating", rating,
                "responseTimeMs", 1500, "reviewedAt", at.toString());
    }

    private static List<String> statuses(JsonNode results) {
        List<String> list = new ArrayList<>();
        results.forEach(r -> list.add(r.get("status").asText()));
        return list;
    }

    private static List<String> ids(JsonNode rows) {
        List<String> list = new ArrayList<>();
        rows.forEach(r -> list.add(r.get("id").asText()));
        return list;
    }

    private static List<String> texts(JsonNode array) {
        List<String> list = new ArrayList<>();
        array.forEach(n -> list.add(n.asText()));
        return list;
    }

    private static String questId(JsonNode today, String definitionId) {
        for (JsonNode q : today.get("quests")) {
            if (q.get("questDefinitionId").asText().equals(definitionId)) {
                return q.get("id").asText();
            }
        }
        throw new AssertionError("Không có nhiệm vụ " + definitionId);
    }

    private JsonNode getData(String token, String url) throws Exception {
        return dataOf(mockMvc.perform(get(url).header("Authorization", token)).andExpect(status().isOk()));
    }

    private JsonNode dataOf(ResultActions actions) throws Exception {
        return body(actions.andReturn()).get("data");
    }

    private ResultActions send(MockHttpServletRequestBuilder request, String token, Object body) throws Exception {
        return mockMvc.perform(request.header("Authorization", token)
                .contentType(MediaType.APPLICATION_JSON)
                .content(json(body)));
    }
}
