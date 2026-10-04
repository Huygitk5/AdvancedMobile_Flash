package com.flash.content;

import com.fasterxml.jackson.databind.JsonNode;
import com.flash.support.IntegrationTestBase;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;

import java.time.LocalDate;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.hasItem;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Dùng dữ liệu seed V2 (mock_data.dart). Trạng thái học của user được chèn thẳng bằng SQL
 * vì API ghi tiến độ / ghi chú / bookmark thuộc G4.
 * Nội dung admin tạo trong test để ở trạng thái nháp, để không làm lệch danh sách seed của test khác.
 */
class ContentIntegrationTest extends IntegrationTestBase {

    private static final String DAILY_LIFE = "10000000-0000-0000-0000-000000000001";
    private static final String TRAVEL = "10000000-0000-0000-0000-000000000002";
    private static final String PRESENT_CONTINUOUS = "20000000-0000-0000-0000-000000000002";
    private static final String BEAUTIFUL = "30000000-0000-0000-0000-000000000001";
    private static final String DAILY_LIFE_QUIZ = "40000000-0000-0000-0000-000000000001";
    private static final String QUEST_LEARN_WORDS = "50000000-0000-0000-0000-000000000001";
    private static final List<String> SEEDED_TOPICS = List.of("Daily Life", "Travel", "Food & Drink", "Technology", "Business");

    @Autowired
    private JdbcTemplate jdbc;

    // ------------------------------------------------------------------ topics

    @Test
    void topicsListWithProgressAndFilters() throws Exception {
        JsonNode auth = register(uniqueEmail());
        String token = bearer(auth);
        String userId = auth.at("/user/id").asText();

        JsonNode all = getData(token, "/v1/topics");
        assertThat(titles(all.get("items"))).containsExactlyElementsOf(SEEDED_TOPICS);
        assertThat(all.at("/items/0/status").asText()).isEqualTo("NOT_STARTED");
        assertThat(all.at("/items/0/progress").asDouble()).isZero();
        assertThat(all.at("/items/0/isPublished").isMissingNode()).isTrue();

        assertThat(titles(getData(token, "/v1/topics?keyword=TRA").get("items"))).containsExactly("Travel");

        jdbc.update("INSERT INTO user_topic_progress (user_id, topic_id, learned_words, status, last_studied_at) "
                + "VALUES (?, ?, 1, 'IN_PROGRESS', UTC_TIMESTAMP(3))", userId, DAILY_LIFE);

        JsonNode inProgress = getData(token, "/v1/topics?status=IN_PROGRESS").get("items");
        assertThat(titles(inProgress)).containsExactly("Daily Life");
        assertThat(inProgress.at("/0/progress").asDouble()).isEqualTo(1.0);
        assertThat(inProgress.at("/0/learnedWords").asInt()).isEqualTo(1);

        JsonNode notStarted = getData(token, "/v1/topics?status=NOT_STARTED").get("items");
        assertThat(titles(notStarted)).containsExactly("Travel", "Food & Drink", "Technology", "Business");
        assertThat(getData(token, "/v1/topics?status=COMPLETED").get("totalElements").asInt()).isZero();
    }

    // ------------------------------------------------------------------ flashcards

    @Test
    void flashcardsIncludeNoteBookmarkAndSrsOfCurrentUserOnly() throws Exception {
        JsonNode auth = register(uniqueEmail());
        String token = bearer(auth);
        String userId = auth.at("/user/id").asText();
        String otherToken = bearer(register(uniqueEmail()));

        JsonNode before = getData(token, "/v1/flashcards?topicId=" + DAILY_LIFE);
        assertThat(before).hasSize(1);
        assertThat(before.at("/0/word").asText()).isEqualTo("beautiful");
        assertThat(before.at("/0/meaning").asText()).isEqualTo("đẹp, xinh đẹp");
        assertThat(before.at("/0/isBookmarked").asBoolean()).isFalse();
        assertThat(before.at("/0/srsBox").asInt()).isZero();
        assertThat(before.at("/0/note").isMissingNode()).isTrue();

        jdbc.update("INSERT INTO user_flashcard_notes (id, user_id, flashcard_id, content, client_updated_at) "
                + "VALUES (?, ?, ?, 'beauty = vẻ đẹp', UTC_TIMESTAMP(3))", UUID.randomUUID().toString(), userId, BEAUTIFUL);
        jdbc.update("INSERT INTO user_bookmarks (user_id, flashcard_id, client_updated_at) VALUES (?, ?, UTC_TIMESTAMP(3))",
                userId, BEAUTIFUL);
        jdbc.update("INSERT INTO user_flashcard_progress (user_id, flashcard_id, box, is_learned, last_rating) "
                + "VALUES (?, ?, 3, TRUE, 'KNOW')", userId, BEAUTIFUL);

        JsonNode card = getData(token, "/v1/flashcards/get/" + BEAUTIFUL);
        assertThat(card.get("note").asText()).isEqualTo("beauty = vẻ đẹp");
        assertThat(card.get("noteVersion").asInt()).isZero();
        assertThat(card.get("isBookmarked").asBoolean()).isTrue();
        assertThat(card.get("srsBox").asInt()).isEqualTo(3);
        assertThat(card.get("isLearned").asBoolean()).isTrue();
        assertThat(card.get("lastRating").asText()).isEqualTo("KNOW");

        // Ghi chú / bookmark là của riêng từng user
        JsonNode otherView = getData(otherToken, "/v1/flashcards/get/" + BEAUTIFUL);
        assertThat(otherView.get("isBookmarked").asBoolean()).isFalse();
        assertThat(otherView.has("note")).isFalse();

        mockMvc.perform(get("/v1/flashcards").param("topicId", UUID.randomUUID().toString()).header("Authorization", token))
                .andExpect(status().isNotFound());
    }

    @Test
    void searchByEnglishWordOrVietnameseMeaning() throws Exception {
        String token = bearer(register(uniqueEmail()));

        assertThat(words(search(token, "beau"))).containsExactly("beautiful");
        assertThat(words(search(token, "BEAUTIFUL"))).containsExactly("beautiful");
        assertThat(words(search(token, "cơ hội"))).containsExactly("opportunity");
        assertThat(words(search(token, "đẹp"))).containsExactly("beautiful");
        assertThat(search(token, "khongtontai")).isEmpty();
        // Chỉ toàn toán tử FULLTEXT: không lỗi cú pháp, trả rỗng
        assertThat(search(token, "+-*()")).isEmpty();
    }

    // ------------------------------------------------------------------ grammar & quiz

    @Test
    void grammarListAndDetail() throws Exception {
        String token = bearer(register(uniqueEmail()));

        JsonNode list = getData(token, "/v1/grammar").get("items");
        assertThat(titles(list)).containsExactly(
                "Present Simple", "Present Continuous", "Past Simple", "Present Perfect", "Conditional");
        assertThat(list.at("/0/structure").asText()).isEqualTo("S + V(s/es)");
        assertThat(list.at("/0/coverColor").asLong()).isEqualTo(0xFFE1BEE7L);

        JsonNode detail = getData(token, "/v1/grammar/get/" + PRESENT_CONTINUOUS);
        assertThat(detail.get("title").asText()).isEqualTo("Present Continuous");
        assertThat(detail.get("structure").asText()).isEqualTo("S + am/is/are + V-ing");
        assertThat(detail.get("iconName").asText()).isEqualTo("access_alarm");
        assertThat(detail.get("status").asText()).isEqualTo("NOT_STARTED");
        assertThat(detail.get("examples")).hasSize(2);
        assertThat(detail.at("/examples/0/highlight").asText()).isEqualTo("is doing");
    }

    @Test
    void quizListAndDetailForOfflinePlay() throws Exception {
        String token = bearer(register(uniqueEmail()));

        JsonNode quizzes = getData(token, "/v1/quizzes?topicId=" + DAILY_LIFE);
        assertThat(quizzes).hasSize(1);
        assertThat(quizzes.at("/0/questionCount").asInt()).isEqualTo(3);

        JsonNode detail = getData(token, "/v1/quizzes/get/" + DAILY_LIFE_QUIZ);
        JsonNode questions = detail.get("questions");
        assertThat(questions).hasSize(3);
        assertThat(questions.at("/1/questionText").asText()).isEqualTo("The weather is very ______ today.");
        assertThat(questions.at("/1/options")).hasSize(4);
        assertThat(questions.at("/1/options/3").asText()).isEqualTo("nice");
        assertThat(questions.at("/1/correctAnswerIndex").asInt()).isEqualTo(3);
        assertThat(questions.at("/1/topicId").asText()).isEqualTo(DAILY_LIFE);
        assertThat(questions.at("/1/explanation").asText()).contains("nice");
    }

    // ------------------------------------------------------------------ home

    @Test
    void homeSummaryForNewUserThenAfterStudying() throws Exception {
        JsonNode auth = register(uniqueEmail());
        String token = bearer(auth);
        String userId = auth.at("/user/id").asText();

        JsonNode fresh = getData(token, "/v1/home/summary");
        assertThat(fresh.get("streakDays").asInt()).isZero();
        assertThat(fresh.at("/todayLessons/done").asInt()).isZero();
        assertThat(fresh.at("/todayLessons/goal").asInt()).isEqualTo(5);
        assertThat(fresh.has("continueLesson")).isFalse();
        assertThat(fresh.has("todayChallenge")).isFalse();
        // User mới trình độ A1: ưu tiên bài A1, xen kẽ từ vựng / ngữ pháp
        JsonNode recommended = fresh.get("recommended");
        assertThat(titles(recommended)).containsExactly("Daily Life", "Present Simple", "Food & Drink");
        assertThat(recommended.at("/0/type").asText()).isEqualTo("vocabulary");
        assertThat(recommended.at("/1/type").asText()).isEqualTo("grammar");

        jdbc.update("INSERT INTO user_topic_progress (user_id, topic_id, learned_words, status, last_studied_at) "
                + "VALUES (?, ?, 0, 'IN_PROGRESS', UTC_TIMESTAMP(3))", userId, TRAVEL);
        jdbc.update("INSERT INTO lesson_completions (id, user_id, lesson_type, topic_id, cards_reviewed, completed_at) "
                + "VALUES (?, ?, 'TOPIC', ?, 10, UTC_TIMESTAMP(3))", UUID.randomUUID().toString(), userId, TRAVEL);
        LocalDate today = LocalDate.now(ZoneId.of("Asia/Ho_Chi_Minh"));
        jdbc.update("INSERT INTO user_quests (id, user_id, quest_definition_id, period_start, current_value, "
                        + "target_value, xp_reward) VALUES (?, ?, ?, ?, 12, 20, 50)",
                UUID.randomUUID().toString(), userId, QUEST_LEARN_WORDS, today.toString());

        JsonNode after = getData(token, "/v1/home/summary");
        assertThat(after.at("/todayLessons/done").asInt()).isEqualTo(1);
        assertThat(after.at("/continueLesson/title").asText()).isEqualTo("Travel");
        assertThat(after.at("/continueLesson/type").asText()).isEqualTo("vocabulary");
        assertThat(after.at("/todayChallenge/title").asText()).isEqualTo("Học 20 Flashcard mới");
        assertThat(after.at("/todayChallenge/current").asInt()).isEqualTo(12);
        assertThat(after.at("/todayChallenge/target").asInt()).isEqualTo(20);
        assertThat(after.at("/todayChallenge/isClaimed").asBoolean()).isFalse();
    }

    // ------------------------------------------------------------------ admin

    @Test
    void adminTopicAndFlashcardCrudKeepsWordCountInSync() throws Exception {
        String userToken = bearer(register(uniqueEmail()));
        String admin = bearer(registerAdmin());

        sendJson(post("/v1/topics/create"), userToken, topicBody("Không được tạo"))
                .andExpect(status().isForbidden());

        String topicA = dataOf(sendJson(post("/v1/topics/create"), admin, topicBody("Draft A"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.data.isPublished").value(false))).get("id").asText();
        String topicB = dataOf(sendJson(post("/v1/topics/create"), admin, topicBody("Draft B"))
                .andExpect(status().isCreated())).get("id").asText();

        // Bản nháp: user thường không thấy, admin thấy
        mockMvc.perform(get("/v1/topics/get/" + topicA).header("Authorization", userToken)).andExpect(status().isNotFound());
        assertThat(totalWords(admin, topicA)).isZero();

        String cardId = dataOf(sendJson(post("/v1/flashcards/create"), admin, cardBody(topicA, "apple"))
                .andExpect(status().isCreated())).get("id").asText();
        assertThat(totalWords(admin, topicA)).isEqualTo(1);

        sendJson(post("/v1/flashcards/create"), admin, cardBody(topicA, "Apple"))
                .andExpect(status().isConflict());

        mockMvc.perform(delete("/v1/flashcards/delete/" + cardId).header("Authorization", admin))
                .andExpect(status().isNoContent());
        assertThat(totalWords(admin, topicA)).isZero();

        // Tạo lại đúng từ đã xoá => khôi phục dòng cũ thay vì vướng UNIQUE(topic_id, word)
        sendJson(post("/v1/flashcards/create"), admin, cardBody(topicA, "apple"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.data.id").value(cardId));
        assertThat(totalWords(admin, topicA)).isEqualTo(1);

        // Chuyển sang topic khác => đếm lại cả hai
        sendJson(put("/v1/flashcards/update/" + cardId), admin, cardBody(topicB, "apple"))
                .andExpect(status().isOk());
        assertThat(totalWords(admin, topicA)).isZero();
        assertThat(totalWords(admin, topicB)).isEqualTo(1);

        mockMvc.perform(delete("/v1/topics/delete/" + topicA).header("Authorization", admin))
                .andExpect(status().isNoContent());
        mockMvc.perform(get("/v1/topics/get/" + topicA).header("Authorization", admin)).andExpect(status().isNotFound());
    }

    @Test
    void adminGrammarAndQuizCrud() throws Exception {
        String admin = bearer(registerAdmin());

        Map<String, Object> grammar = new HashMap<>();
        grammar.put("title", "Future Simple (nháp)");
        grammar.put("structure", "S + will + V");
        grammar.put("iconName", "schedule");
        grammar.put("examples", List.of(
                Map.of("sentence", "I will call you.", "translation", "Tôi sẽ gọi cho bạn.", "highlight", "will call"),
                Map.of("sentence", "It will rain.")));
        JsonNode created = dataOf(sendJson(post("/v1/grammar/create"), admin, grammar).andExpect(status().isCreated()));
        String grammarId = created.get("id").asText();
        assertThat(created.get("examples")).hasSize(2);

        grammar.put("examples", List.of(Map.of("sentence", "She will come.")));
        JsonNode updated = dataOf(sendJson(put("/v1/grammar/update/" + grammarId), admin, grammar).andExpect(status().isOk()));
        assertThat(updated.get("examples")).hasSize(1);
        assertThat(updated.at("/examples/0/sentence").asText()).isEqualTo("She will come.");

        Map<String, Object> quiz = new HashMap<>();
        quiz.put("title", "Future Simple Quiz");
        quiz.put("quizType", "GRAMMAR");
        quiz.put("grammarLessonId", grammarId);
        quiz.put("questions", List.of(question("I ___ you tomorrow.", 0)));
        JsonNode quizData = dataOf(sendJson(post("/v1/quizzes/create"), admin, quiz).andExpect(status().isCreated()));
        String quizId = quizData.at("/quiz/id").asText();
        assertThat(quizData.at("/quiz/questionCount").asInt()).isEqualTo(1);

        quiz.put("questions", List.of(question("Q1 ___", 1), question("Q2 ___", 2)));
        sendJson(put("/v1/quizzes/update/" + quizId), admin, quiz)
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.quiz.questionCount").value(2))
                .andExpect(jsonPath("$.data.questions[1].correctAnswerIndex").value(2));

        // Chỉ 3 đáp án => lỗi validation
        Map<String, Object> badOptions = new HashMap<>(quiz);
        badOptions.put("questions", List.of(Map.of("questionText", "x", "options", List.of("a", "b", "c"), "correctOptionIndex", 0)));
        sendJson(post("/v1/quizzes/create"), admin, badOptions)
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_ERROR"));

        // Quiz TOPIC mà không có topicId
        Map<String, Object> missingTopic = new HashMap<>(quiz);
        missingTopic.put("quizType", "TOPIC");
        sendJson(post("/v1/quizzes/create"), admin, missingTopic)
                .andExpect(status().isBadRequest());
    }

    @Test
    void adminQuestDefinitionsAndRewardItems() throws Exception {
        String admin = bearer(registerAdmin());
        String suffix = UUID.randomUUID().toString().substring(0, 6).toUpperCase().replace("-", "");

        mockMvc.perform(get("/v1/quests/definitions").header("Authorization", admin))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data[*].code", hasItem("DAILY_LEARN_20_WORDS")));

        Map<String, Object> quest = Map.of("code", "QUIZ_" + suffix, "title", "Làm 3 bài kiểm tra",
                "questType", "COMPLETE_QUIZ", "targetValue", 3, "xpReward", 30, "iconName", "quiz");
        String questId = dataOf(sendJson(post("/v1/quests/create"), admin, quest).andExpect(status().isCreated()))
                .get("id").asText();
        sendJson(post("/v1/quests/create"), admin, quest).andExpect(status().isConflict());
        mockMvc.perform(delete("/v1/quests/delete/" + questId).header("Authorization", admin))
                .andExpect(status().isNoContent());
        JsonNode definitions = getData(admin, "/v1/quests/definitions");
        boolean deactivated = false;
        for (JsonNode d : definitions) {
            if (d.get("id").asText().equals(questId)) {
                deactivated = !d.get("isActive").asBoolean();
            }
        }
        assertThat(deactivated).isTrue();

        Map<String, Object> border = Map.of("code", "BORDER_" + suffix, "name", "Đại dương", "itemType", "BORDER",
                "xpCost", 800, "borderColors", List.of(4278255615L, 4278190335L));
        sendJson(post("/v1/shop/items/create"), admin, border)
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.data.borderColors[0]").value(4278255615L))
                .andExpect(jsonPath("$.data.requiredRank").value(0));

        Map<String, Object> noColors = Map.of("code", "BORDER_X" + suffix, "name", "Thiếu màu", "itemType", "BORDER");
        sendJson(post("/v1/shop/items/create"), admin, noColors).andExpect(status().isBadRequest());

        mockMvc.perform(get("/v1/shop/items/definitions").header("Authorization", admin))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data[*].code", hasItem("BORDER_VUA_TRO_CHOI")))
                .andExpect(jsonPath("$.data[*].code", hasItem("BORDER_" + suffix)));
    }

    // ------------------------------------------------------------------ helpers

    private JsonNode getData(String token, String url) throws Exception {
        return dataOf(mockMvc.perform(get(url).header("Authorization", token)).andExpect(status().isOk()));
    }

    private JsonNode dataOf(org.springframework.test.web.servlet.ResultActions actions) throws Exception {
        return body(actions.andReturn()).get("data");
    }

    private org.springframework.test.web.servlet.ResultActions sendJson(
            org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder request,
            String token, Object body) throws Exception {
        return mockMvc.perform(request.header("Authorization", token)
                .contentType(MediaType.APPLICATION_JSON)
                .content(json(body)));
    }

    private JsonNode search(String token, String keyword) throws Exception {
        return dataOf(mockMvc.perform(get("/v1/flashcards/search").param("keyword", keyword)
                .header("Authorization", token)).andExpect(status().isOk())).get("items");
    }

    private int totalWords(String adminToken, String topicId) throws Exception {
        return getData(adminToken, "/v1/topics/get/" + topicId).get("totalWords").asInt();
    }

    private static Map<String, Object> topicBody(String title) {
        return Map.of("title", title, "iconPath", "📦");
    }

    private static Map<String, Object> cardBody(String topicId, String word) {
        return Map.of("topicId", topicId, "word", word, "partOfSpeech", "n.",
                "pronunciation", "/ˈæp.əl/", "meaning", "quả táo");
    }

    private static Map<String, Object> question(String text, int correct) {
        return Map.of("questionText", text, "options", List.of("will call", "call", "called", "calling"),
                "correctOptionIndex", correct, "explanation", "Giải thích");
    }

    private static List<String> titles(JsonNode items) {
        List<String> result = new ArrayList<>();
        items.forEach(item -> result.add(item.get("title").asText()));
        return result;
    }

    private static List<String> words(JsonNode items) {
        List<String> result = new ArrayList<>();
        items.forEach(item -> result.add(item.get("word").asText()));
        return result;
    }
}
