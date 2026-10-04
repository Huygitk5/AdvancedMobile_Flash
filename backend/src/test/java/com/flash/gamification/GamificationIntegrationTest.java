package com.flash.gamification;

import com.fasterxml.jackson.databind.JsonNode;
import com.flash.support.IntegrationTestBase;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder;

import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Nghiệp vụ server-authoritative của G4 (DATA_ARCHITECTURE.md §5.2, §5.3) chạy trên MySQL thật,
 * dùng nội dung seed V2. Mỗi test tự đăng ký user riêng.
 */
class GamificationIntegrationTest extends IntegrationTestBase {

    private static final ZoneId VN = ZoneId.of("Asia/Ho_Chi_Minh");

    private static final String DAILY_LIFE = "10000000-0000-0000-0000-000000000001";
    private static final String PRESENT_SIMPLE = "20000000-0000-0000-0000-000000000001";
    private static final String BEAUTIFUL = "30000000-0000-0000-0000-000000000001";
    private static final String OPPORTUNITY = "30000000-0000-0000-0000-000000000002";
    private static final String DAILY_LIFE_QUIZ = "40000000-0000-0000-0000-000000000001";
    private static final String Q1 = "41000000-0000-0000-0000-000000000001";
    private static final String Q2 = "41000000-0000-0000-0000-000000000002";
    private static final String Q3 = "41000000-0000-0000-0000-000000000003";
    private static final String QUEST_PERFECT_QUIZ = "50000000-0000-0000-0000-000000000002";
    private static final String QUEST_KEEP_STREAK = "50000000-0000-0000-0000-000000000003";
    private static final String BORDER_FREE = "60000000-0000-0000-0000-000000000001";
    private static final String BORDER_500 = "60000000-0000-0000-0000-000000000002";
    private static final String BORDER_TOP3 = "60000000-0000-0000-0000-000000000004";

    @Autowired
    private JdbcTemplate jdbc;

    // ------------------------------------------------------------------ SRS + XP

    @Test
    void sameReviewSentTwiceAwardsXpOnlyOnce() throws Exception {
        JsonNode auth = register(uniqueEmail());
        String token = bearer(auth);
        String userId = auth.at("/user/id").asText();
        Instant at = LocalDate.now(VN).minusDays(1).atTime(10, 0).atZone(VN).toInstant();
        String logId = UUID.randomUUID().toString();

        JsonNode first = review(token, logId, BEAUTIFUL, "KNOW", at);
        assertThat(first.get("xpAwarded").asInt()).isEqualTo(2);
        assertThat(first.get("duplicate").asBoolean()).isFalse();
        assertThat(first.at("/progress/box").asInt()).isEqualTo(1);
        assertThat(Instant.parse(first.at("/progress/dueAt").asText())).isEqualTo(at.plusSeconds(86_400));
        assertThat(first.at("/user/currentXp").asInt()).isEqualTo(2);
        assertThat(first.at("/user/streakDays").asInt()).isEqualTo(1);

        // Retry (mất mạng sau khi server đã xử lý): không cộng gì thêm
        JsonNode retry = review(token, logId, BEAUTIFUL, "KNOW", at);
        assertThat(retry.get("duplicate").asBoolean()).isTrue();
        assertThat(retry.get("xpAwarded").asInt()).isZero();
        assertThat(retry.at("/user/currentXp").asInt()).isEqualTo(2);

        // Know lần hai cùng thẻ trong cùng ngày: SRS vẫn tiến nhưng XP "know" chỉ tính lần đầu trong ngày
        JsonNode second = review(token, UUID.randomUUID().toString(), BEAUTIFUL, "KNOW", at.plusSeconds(300));
        assertThat(second.at("/progress/box").asInt()).isEqualTo(2);
        assertThat(second.get("xpAwarded").asInt()).isZero();

        assertThat(jdbc.queryForObject("SELECT COUNT(*) FROM flashcard_review_logs WHERE user_id = ?", Integer.class, userId))
                .isEqualTo(2);
        assertLedgerMatchesBalance(userId);
    }

    @Test
    void cardBecomesLearnedAtBoxThreeAndUpdatesTopicProgress() throws Exception {
        JsonNode auth = register(uniqueEmail());
        String token = bearer(auth);
        LocalDate today = LocalDate.now(VN);
        Instant d1 = today.minusDays(3).atTime(9, 0).atZone(VN).toInstant();
        Instant d2 = today.minusDays(2).atTime(9, 0).atZone(VN).toInstant();
        Instant d3 = today.minusDays(1).atTime(9, 0).atZone(VN).toInstant();

        review(token, UUID.randomUUID().toString(), BEAUTIFUL, "KNOW", d1);
        review(token, UUID.randomUUID().toString(), BEAUTIFUL, "KNOW", d2);
        JsonNode third = review(token, UUID.randomUUID().toString(), BEAUTIFUL, "KNOW", d3);

        assertThat(third.at("/progress/isLearned").asBoolean()).isTrue();
        assertThat(third.get("xpAwarded").asInt()).isEqualTo(2 + 5);
        assertThat(third.at("/user/currentXp").asInt()).isEqualTo(3 * 2 + 5);
        assertThat(third.at("/user/totalWordsLearned").asInt()).isEqualTo(1);
        assertThat(third.at("/user/streakDays").asInt()).isEqualTo(3);

        // Daily Life chỉ có 1 từ => thuộc hết là hoàn thành topic
        JsonNode topics = getData(token, "/v1/topics?status=COMPLETED").get("items");
        assertThat(topics).hasSize(1);
        assertThat(topics.at("/0/id").asText()).isEqualTo(DAILY_LIFE);
        assertThat(topics.at("/0/progress").asDouble()).isEqualTo(1.0);

        // Đã ôn xong thì chưa đến hạn; dời hạn về quá khứ thì xuất hiện trong /due
        assertThat(getData(token, "/v1/flashcards/due")).isEmpty();
        jdbc.update("UPDATE user_flashcard_progress SET due_at = UTC_TIMESTAMP(3) - INTERVAL 1 MINUTE WHERE user_id = ?",
                auth.at("/user/id").asText());
        JsonNode due = getData(token, "/v1/flashcards/due?topicId=" + DAILY_LIFE);
        assertThat(due).hasSize(1);
        assertThat(due.at("/0/srsBox").asInt()).isEqualTo(3);
    }

    // ------------------------------------------------------------------ streak

    /** 23:30 và 00:30 giờ Việt Nam cùng một ngày UTC nhưng là hai ngày địa phương khác nhau. */
    @Test
    void streakFollowsUserTimezoneNotUtc() throws Exception {
        LocalDate day = LocalDate.now(VN).minusDays(3);
        Instant lateNight = day.atTime(23, 30).atZone(VN).toInstant();
        Instant earlyMorning = day.plusDays(1).atTime(0, 30).atZone(VN).toInstant();
        assertThat(lateNight.atZone(ZoneId.of("UTC")).toLocalDate())
                .isEqualTo(earlyMorning.atZone(ZoneId.of("UTC")).toLocalDate());

        String vnUser = bearer(register(uniqueEmail()));
        assertThat(review(vnUser, UUID.randomUUID().toString(), BEAUTIFUL, "KNOW", lateNight).at("/user/streakDays").asInt())
                .isEqualTo(1);
        assertThat(review(vnUser, UUID.randomUUID().toString(), OPPORTUNITY, "KNOW", earlyMorning).at("/user/streakDays").asInt())
                .isEqualTo(2);

        // Sự kiện offline của ngày trước đó đến muộn: lấp vào đầu chuỗi => tính lại thành 3
        Instant dayBefore = day.minusDays(1).atTime(12, 0).atZone(VN).toInstant();
        JsonNode late = review(vnUser, UUID.randomUUID().toString(), BEAUTIFUL, "AGAIN", dayBefore);
        assertThat(late.at("/user/streakDays").asInt()).isEqualTo(3);
        assertThat(late.at("/user/longestStreak").asInt()).isEqualTo(3);

        // Cùng hai thời điểm với user ở UTC: chỉ là một ngày
        JsonNode utcAuth = register(uniqueEmail());
        jdbc.update("UPDATE users SET timezone = 'UTC' WHERE id = ?", utcAuth.at("/user/id").asText());
        String utcUser = bearer(utcAuth);
        review(utcUser, UUID.randomUUID().toString(), BEAUTIFUL, "KNOW", lateNight);
        assertThat(review(utcUser, UUID.randomUUID().toString(), OPPORTUNITY, "KNOW", earlyMorning).at("/user/streakDays").asInt())
                .isEqualTo(1);
    }

    @Test
    void implausibleEventTimeUpdatesSrsButGivesNoXpOrStreak() throws Exception {
        String token = bearer(register(uniqueEmail()));
        JsonNode old = review(token, UUID.randomUUID().toString(), BEAUTIFUL, "KNOW", Instant.now().minusSeconds(8 * 86_400));
        assertThat(old.at("/progress/box").asInt()).isEqualTo(1);
        assertThat(old.get("xpAwarded").asInt()).isZero();
        assertThat(old.at("/user/streakDays").asInt()).isZero();

        JsonNode future = review(token, UUID.randomUUID().toString(), OPPORTUNITY, "KNOW", Instant.now().plusSeconds(3600));
        assertThat(future.get("xpAwarded").asInt()).isZero();
    }

    // ------------------------------------------------------------------ lessons

    @Test
    void lessonCompletionIsIdempotent() throws Exception {
        JsonNode auth = register(uniqueEmail());
        String token = bearer(auth);
        String id = UUID.randomUUID().toString();
        Map<String, Object> body = lesson(id, "TOPIC", DAILY_LIFE, null);

        JsonNode first = dataOf(send(post("/v1/lessons/complete"), token, body).andExpect(status().isCreated()));
        assertThat(first.get("xpAwarded").asInt()).isEqualTo(10);
        assertThat(first.at("/todayLessons/done").asInt()).isEqualTo(1);
        assertThat(first.at("/user/completedLessons").asInt()).isEqualTo(1);

        JsonNode retry = dataOf(send(post("/v1/lessons/complete"), token, body).andExpect(status().isOk()));
        assertThat(retry.get("duplicate").asBoolean()).isTrue();
        assertThat(retry.get("xpAwarded").asInt()).isZero();
        assertThat(retry.at("/todayLessons/done").asInt()).isEqualTo(1);
        assertThat(retry.at("/user/currentXp").asInt()).isEqualTo(10);

        // Chủ điểm ngữ pháp không có quiz: đọc xong là hoàn thành
        send(post("/v1/lessons/complete"), token, lesson(UUID.randomUUID().toString(), "GRAMMAR", null, PRESENT_SIMPLE))
                .andExpect(status().isCreated());
        JsonNode grammar = getData(token, "/v1/grammar/get/" + PRESENT_SIMPLE);
        assertThat(grammar.get("status").asText()).isEqualTo("COMPLETED");
        assertThat(grammar.get("progress").asDouble()).isEqualTo(1.0);

        // Sai kiểu bài
        send(post("/v1/lessons/complete"), token, lesson(UUID.randomUUID().toString(), "TOPIC", null, PRESENT_SIMPLE))
                .andExpect(status().isBadRequest());
        JsonNode home = getData(token, "/v1/home/summary");
        assertThat(home.at("/todayLessons/done").asInt()).isEqualTo(2);
    }

    // ------------------------------------------------------------------ quiz

    @Test
    void quizIsGradedByServerAndXpOnlyForFirstAttemptOfTheDay() throws Exception {
        JsonNode auth = register(uniqueEmail());
        String token = bearer(auth);

        String attemptId = UUID.randomUUID().toString();
        Map<String, Object> perfect = quiz(attemptId, 30, answer(Q1, 0), answer(Q2, 3), answer(Q3, 0));
        JsonNode result = dataOf(send(post("/v1/quizzes/submit"), token, perfect).andExpect(status().isCreated()));
        assertThat(result.get("correctAnswers").asInt()).isEqualTo(3);
        assertThat(result.get("scorePercent").asInt()).isEqualTo(100);
        assertThat(result.get("passed").asBoolean()).isTrue();
        assertThat(result.get("wrongQuestionIds")).isEmpty();
        assertThat(result.get("xpAwarded").asInt()).isEqualTo(3 * 2 + 10);

        send(post("/v1/quizzes/submit"), token, perfect)
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.duplicate").value(true));

        // Lần làm thứ hai trong ngày: 1 sai, 1 bỏ qua; không cộng XP
        String secondId = UUID.randomUUID().toString();
        JsonNode second = dataOf(send(post("/v1/quizzes/submit"), token,
                quiz(secondId, 30, answer(Q1, 0), answer(Q2, 1), answer(Q3, null))).andExpect(status().isCreated()));
        assertThat(second.get("correctAnswers").asInt()).isEqualTo(1);
        assertThat(second.get("wrongAnswers").asInt()).isEqualTo(2);
        assertThat(second.get("scorePercent").asInt()).isEqualTo(33);
        assertThat(second.get("xpAwarded").asInt()).isZero();
        assertThat(texts(second.get("wrongQuestionIds"))).containsExactlyInAnyOrder(Q2, Q3);

        JsonNode review = getData(token, "/v1/quizzes/attempts/get/" + secondId + "/review");
        assertThat(review).hasSize(3);
        assertThat(review.at("/1/id").asText()).isEqualTo(Q2);
        assertThat(review.at("/1/userIndex").asInt()).isEqualTo(1);
        assertThat(review.at("/1/correctIndex").asInt()).isEqualTo(3);
        assertThat(review.at("/2/userIndex").asInt()).isEqualTo(-1);
        assertThat(getData(token, "/v1/quizzes/attempts?quizId=" + DAILY_LIFE_QUIZ).get("totalElements").asInt()).isEqualTo(2);

        // Thiếu câu / làm quá nhanh => 422
        send(post("/v1/quizzes/submit"), token, quiz(UUID.randomUUID().toString(), 30, answer(Q1, 0), answer(Q2, 3)))
                .andExpect(status().isUnprocessableEntity());
        send(post("/v1/quizzes/submit"), token,
                quiz(UUID.randomUUID().toString(), 2, answer(Q1, 0), answer(Q2, 3), answer(Q3, 0)))
                .andExpect(status().isUnprocessableEntity());

        // Người khác không xem được bài làm
        mockMvc.perform(get("/v1/quizzes/attempts/get/" + attemptId).header("Authorization", bearer(register(uniqueEmail()))))
                .andExpect(status().isNotFound());

        JsonNode stats = getData(token, "/v1/users/me/statistics?range=WEEK");
        assertThat(stats.get("daily")).hasSize(7);
        JsonNode today = stats.at("/daily/6");
        assertThat(today.get("date").asText()).isEqualTo(LocalDate.now(VN).toString());
        assertThat(today.get("quizzesCompleted").asInt()).isEqualTo(2);
        assertThat(today.get("totalAnswers").asInt()).isEqualTo(6);
        assertThat(stats.get("accuracy").asDouble()).isEqualTo(4.0 / 6);
        assertThat(stats.get("streakDays").asInt()).isEqualTo(1);
        assertLedgerMatchesBalance(auth.at("/user/id").asText());
    }

    // ------------------------------------------------------------------ quests

    @Test
    void questCanOnlyBeClaimedOnceAfterServerSeesItCompleted() throws Exception {
        String token = bearer(register(uniqueEmail()));

        JsonNode today = getData(token, "/v1/quests/today");
        String perfectQuestId = questId(today, QUEST_PERFECT_QUIZ);
        assertThat(perfectQuestId).isNotNull();
        // Gọi lại không giao trùng
        assertThat(getData(token, "/v1/quests/today").get("quests")).hasSize(today.get("quests").size());

        send(post("/v1/quests/claim/" + perfectQuestId), token, Map.of())
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code").value("QUEST_NOT_COMPLETED"))
                .andExpect(jsonPath("$.message").value("Tiến độ 0/1"));

        send(post("/v1/quizzes/submit"), token, quiz(UUID.randomUUID().toString(), 30,
                answer(Q1, 0), answer(Q2, 3), answer(Q3, 0))).andExpect(status().isCreated());
        JsonNode after = getData(token, "/v1/quests/today");
        assertThat(quest(after, QUEST_PERFECT_QUIZ).get("current").asInt()).isEqualTo(1);
        assertThat(quest(after, QUEST_KEEP_STREAK).get("current").asInt()).isEqualTo(1);
        assertThat(after.get("totalXp").asInt()).isEqualTo(16);

        JsonNode claimed = dataOf(send(post("/v1/quests/claim/" + perfectQuestId), token, Map.of())
                .andExpect(status().isOk()));
        assertThat(claimed.get("xpAwarded").asInt()).isEqualTo(100);
        assertThat(claimed.get("currentXp").asInt()).isEqualTo(116);
        assertThat(claimed.get("totalLifetimeXp").asLong()).isEqualTo(116);

        send(post("/v1/quests/claim/" + perfectQuestId), token, Map.of())
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("ALREADY_CLAIMED"));
        send(post("/v1/quests/claim/" + perfectQuestId), bearer(register(uniqueEmail())), Map.of())
                .andExpect(status().isNotFound());
    }

    // ------------------------------------------------------------------ shop

    @Test
    void purchaseChecksXpRankAndOwnershipAndIsIdempotent() throws Exception {
        JsonNode auth = register(uniqueEmail());
        String token = bearer(auth);
        String userId = auth.at("/user/id").asText();

        send(post("/v1/shop/purchase"), token, Map.of("rewardItemId", BORDER_500))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("INSUFFICIENT_XP"));

        // Đủ XP nhưng không nằm trong Top 3 (3 user khác có XP trọn đời rất cao)
        for (int i = 0; i < 3; i++) {
            jdbc.update("UPDATE users SET total_lifetime_xp = 1000000 WHERE id = ?",
                    register(uniqueEmail()).at("/user/id").asText());
        }
        jdbc.update("UPDATE users SET current_xp = 5000 WHERE id = ?", userId);
        send(post("/v1/shop/purchase"), token, Map.of("rewardItemId", BORDER_TOP3))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.code").value("RANK_REQUIREMENT_NOT_MET"));

        // Idempotency-Key: gửi lại sau khi đã mua thành công => cùng kết quả, không 409
        String key = UUID.randomUUID().toString();
        String inventoryId = dataOf(send(post("/v1/shop/purchase").header("Idempotency-Key", key), token,
                Map.of("rewardItemId", BORDER_FREE)).andExpect(status().isCreated())).at("/inventory/id").asText();
        send(post("/v1/shop/purchase").header("Idempotency-Key", key), token, Map.of("rewardItemId", BORDER_FREE))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.data.inventory.id").value(inventoryId));
        send(post("/v1/shop/purchase"), token, Map.of("rewardItemId", BORDER_FREE))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("ALREADY_OWNED"));

        JsonNode bought = dataOf(send(post("/v1/shop/purchase"), token, Map.of("rewardItemId", BORDER_500))
                .andExpect(status().isCreated()));
        assertThat(bought.get("currentXp").asInt()).isEqualTo(4500);
        String borderId = bought.at("/inventory/id").asText();
        JsonNode me = getData(token, "/v1/users/me");
        assertThat(me.get("totalLifetimeXp").asLong()).as("mua đồ không làm giảm XP trọn đời").isZero();
        assertThat(jdbc.queryForObject("SELECT amount FROM xp_transactions WHERE user_id = ? AND source_type = 'SHOP_PURCHASE'",
                Integer.class, userId)).isEqualTo(-500);

        // Trang bị viền mới tự tháo viền cũ cùng loại
        Instant t = Instant.now().minusSeconds(60);
        send(put("/v1/shop/equip/" + inventoryId), token, Map.of("clientUpdatedAt", t.toString())).andExpect(status().isOk());
        JsonNode equipped = dataOf(send(put("/v1/shop/equip/" + borderId), token, Map.of("clientUpdatedAt", t.plusSeconds(10).toString()))
                .andExpect(status().isOk()));
        assertThat(equipped.at("/inventory/isEquipped").asBoolean()).isTrue();
        assertThat(equipped.at("/unequipped/0/id").asText()).isEqualTo(inventoryId);

        JsonNode items = getData(token, "/v1/shop/items?type=BORDER");
        assertThat(item(items, BORDER_500).get("isEquipped").asBoolean()).isTrue();
        assertThat(item(items, BORDER_FREE).get("isEquipped").asBoolean()).isFalse();
        assertThat(item(items, BORDER_TOP3).get("meetsRankRequirement").asBoolean()).isFalse();
        assertThat(item(items, BORDER_TOP3).get("borderColors")).hasSize(3);

        // Lệnh trang bị cũ hơn (thiết bị offline gửi lên muộn) thua
        send(put("/v1/shop/equip/" + inventoryId), token, Map.of("clientUpdatedAt", t.minusSeconds(30).toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.resolution").value("CONFLICT_SERVER_WINS"))
                .andExpect(jsonPath("$.data.inventory.isEquipped").value(false));
        assertThat(getData(token, "/v1/shop/inventory")).hasSize(2);
    }

    // ------------------------------------------------------------------ notes & bookmarks

    @Test
    void notesUseLastWriteWinsWithVersion() throws Exception {
        String token = bearer(register(uniqueEmail()));
        Instant t = Instant.now().minusSeconds(3600);
        String noteId = UUID.randomUUID().toString();

        JsonNode created = upsertNote(token, noteId, "v1", null, t);
        assertThat(created.get("resolution").asText()).isEqualTo("APPLIED");
        assertThat(created.at("/note/noteId").asText()).isEqualTo(noteId);
        int v0 = created.at("/note/version").asInt();

        JsonNode updated = upsertNote(token, noteId, "v2", v0, t.plusSeconds(60));
        assertThat(updated.get("resolution").asText()).isEqualTo("APPLIED");
        assertThat(updated.at("/note/version").asInt()).isEqualTo(v0 + 1);

        // Máy khác sửa dựa trên version cũ và sửa sớm hơn => server thắng, trả bản server
        JsonNode stale = upsertNote(token, noteId, "bản cũ", v0, t.plusSeconds(30));
        assertThat(stale.get("resolution").asText()).isEqualTo("CONFLICT_SERVER_WINS");
        assertThat(stale.at("/note/content").asText()).isEqualTo("v2");

        // Version cũ nhưng sửa muộn hơn => client thắng
        JsonNode newer = upsertNote(token, noteId, "mới nhất", v0, t.plusSeconds(120));
        assertThat(newer.get("resolution").asText()).isEqualTo("APPLIED");
        assertThat(getData(token, "/v1/flashcards/get/" + BEAUTIFUL).get("note").asText()).isEqualTo("mới nhất");

        mockMvc.perform(delete("/v1/flashcards/notes/delete/" + BEAUTIFUL).header("Authorization", token))
                .andExpect(status().isNoContent());
        mockMvc.perform(get("/v1/flashcards/notes/get/" + BEAUTIFUL).header("Authorization", token))
                .andExpect(status().isNotFound());
    }

    @Test
    void bookmarksAreTombstonedAndOlderWritesLose() throws Exception {
        JsonNode auth = register(uniqueEmail());
        String token = bearer(auth);

        send(post("/v1/flashcards/bookmarks/create"), token, Map.of("flashcardId", BEAUTIFUL))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.data.isBookmarked").value(true));
        send(post("/v1/flashcards/bookmarks/create"), token, Map.of("flashcardId", BEAUTIFUL))
                .andExpect(status().isOk());
        JsonNode list = getData(token, "/v1/flashcards/bookmarks");
        assertThat(list.get("totalElements").asInt()).isEqualTo(1);
        assertThat(list.at("/items/0/word").asText()).isEqualTo("beautiful");

        mockMvc.perform(delete("/v1/flashcards/bookmarks/delete/" + BEAUTIFUL).header("Authorization", token))
                .andExpect(status().isNoContent());
        assertThat(getData(token, "/v1/flashcards/bookmarks").get("totalElements").asInt()).isZero();
        assertThat(jdbc.queryForObject("SELECT COUNT(*) FROM user_bookmarks WHERE user_id = ? AND deleted_at IS NOT NULL",
                Integer.class, auth.at("/user/id").asText())).isEqualTo(1);

        // Thao tác bookmark từ thiết bị offline, xảy ra trước lần bỏ bookmark => thua
        send(post("/v1/flashcards/bookmarks/create"), token,
                Map.of("flashcardId", BEAUTIFUL, "clientUpdatedAt", Instant.now().minusSeconds(3600).toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.resolution").value("CONFLICT_SERVER_WINS"))
                .andExpect(jsonPath("$.data.isBookmarked").value(false));
    }

    // ------------------------------------------------------------------ leaderboard

    @Test
    void leaderboardReportsMyRankAndScore() throws Exception {
        String token = bearer(register(uniqueEmail()));
        review(token, UUID.randomUUID().toString(), BEAUTIFUL, "KNOW", Instant.now().minusSeconds(60));

        JsonNode board = getData(token, "/v1/leaderboard/xp?limit=5");
        assertThat(board.get("items").size()).isBetween(1, 5);
        assertThat(board.at("/items/0/rank").asInt()).isEqualTo(1);
        assertThat(board.at("/me/score").asLong()).isEqualTo(2);
        assertThat(board.at("/me/rank").asInt()).isPositive();

        JsonNode streak = getData(token, "/v1/leaderboard/streak");
        assertThat(streak.at("/me/score").asLong()).isEqualTo(1);
    }

    // ------------------------------------------------------------------ helpers

    private void assertLedgerMatchesBalance(String userId) {
        Integer ledger = jdbc.queryForObject("SELECT COALESCE(SUM(amount), 0) FROM xp_transactions WHERE user_id = ?",
                Integer.class, userId);
        Integer balance = jdbc.queryForObject("SELECT current_xp FROM users WHERE id = ?", Integer.class, userId);
        assertThat(ledger).as("SUM(xp_transactions.amount) == users.current_xp").isEqualTo(balance);
    }

    private JsonNode review(String token, String logId, String flashcardId, String rating, Instant at) throws Exception {
        Map<String, Object> body = Map.of("logId", logId, "flashcardId", flashcardId, "rating", rating,
                "responseTimeMs", 1500, "reviewedAt", at.toString());
        return dataOf(send(post("/v1/flashcards/review"), token, body).andExpect(status().isOk()));
    }

    private JsonNode upsertNote(String token, String noteId, String content, Integer baseVersion, Instant at) throws Exception {
        Map<String, Object> body = new HashMap<>();
        body.put("noteId", noteId);
        body.put("flashcardId", BEAUTIFUL);
        body.put("content", content);
        body.put("baseVersion", baseVersion);
        body.put("clientUpdatedAt", at.toString());
        return dataOf(send(put("/v1/flashcards/notes/update"), token, body).andExpect(status().isOk()));
    }

    private static Map<String, Object> lesson(String id, String type, String topicId, String grammarLessonId) {
        Map<String, Object> body = new HashMap<>();
        body.put("id", id);
        body.put("lessonType", type);
        body.put("topicId", topicId);
        body.put("grammarLessonId", grammarLessonId);
        body.put("cardsReviewed", 5);
        body.put("durationSeconds", 300);
        body.put("completedAt", Instant.now().toString());
        return body;
    }

    @SafeVarargs
    private static Map<String, Object> quiz(String attemptId, int seconds, Map<String, Object>... answers) {
        Instant now = Instant.now();
        return Map.of("attemptId", attemptId, "quizId", DAILY_LIFE_QUIZ,
                "startedAt", now.minusSeconds(seconds).toString(), "submittedAt", now.toString(),
                "timeTakenSeconds", seconds, "answers", Arrays.asList(answers));
    }

    private static Map<String, Object> answer(String questionId, Integer selected) {
        Map<String, Object> answer = new HashMap<>();
        answer.put("questionId", questionId);
        answer.put("selectedOptionIndex", selected);
        return answer;
    }

    private static JsonNode quest(JsonNode today, String definitionId) {
        for (JsonNode q : today.get("quests")) {
            if (q.get("questDefinitionId").asText().equals(definitionId)) {
                return q;
            }
        }
        throw new AssertionError("Không có nhiệm vụ " + definitionId);
    }

    private static String questId(JsonNode today, String definitionId) {
        return quest(today, definitionId).get("id").asText();
    }

    private static JsonNode item(JsonNode items, String id) {
        for (JsonNode i : items) {
            if (i.get("id").asText().equals(id)) {
                return i;
            }
        }
        throw new AssertionError("Không có vật phẩm " + id);
    }

    private static List<String> texts(JsonNode array) {
        List<String> result = new ArrayList<>();
        array.forEach(n -> result.add(n.asText()));
        return result;
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
