package com.flash.content;

import org.flywaydb.core.Flyway;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.DriverManagerDataSource;
import org.testcontainers.containers.MySQLContainer;

import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Kiểm tra bộ seed đầy đủ (db/migration + db/seed) trên một MySQL riêng: các test tích hợp khác
 * chỉ nạp seed nhỏ V2 nên không thể kiểm bộ này.
 */
class SeedContentTest {

    private static MySQLContainer<?> mysql;
    private static JdbcTemplate jdbc;

    @BeforeAll
    static void migrate() {
        mysql = new MySQLContainer<>("mysql:8.0")
                .withDatabaseName("flash_seed")
                .withUsername("flash")
                .withPassword("flash")
                .withUrlParam("serverTimezone", "UTC")
                .withUrlParam("characterEncoding", "utf8")
                .withCommand("--character-set-server=utf8mb4", "--collation-server=utf8mb4_0900_ai_ci",
                        "--default-time-zone=+00:00", "--innodb_ft_min_token_size=2");
        mysql.start();
        Flyway.configure()
                .dataSource(mysql.getJdbcUrl(), mysql.getUsername(), mysql.getPassword())
                .locations("classpath:db/migration", "classpath:db/seed")
                .load()
                .migrate();
        jdbc = new JdbcTemplate(new DriverManagerDataSource(mysql.getJdbcUrl(), mysql.getUsername(), mysql.getPassword()));
    }

    @AfterAll
    static void stop() {
        if (mysql != null) {
            mysql.stop();
        }
    }

    @Test
    void everyPublishedTopicHasWordsAndAccurateCounter() {
        List<Map<String, Object>> topics = jdbc.queryForList("SELECT t.id, t.title, t.total_words, "
                + "(SELECT COUNT(*) FROM flashcards f WHERE f.topic_id = t.id AND f.deleted_at IS NULL) AS real_words "
                + "FROM topics t WHERE t.is_published = TRUE AND t.deleted_at IS NULL");
        assertThat(topics).hasSizeGreaterThanOrEqualTo(18);
        for (Map<String, Object> topic : topics) {
            long real = ((Number) topic.get("real_words")).longValue();
            assertThat(real).as("số từ của %s", topic.get("title")).isGreaterThanOrEqualTo(25);
            assertThat(((Number) topic.get("total_words")).longValue()).as("total_words của %s", topic.get("title")).isEqualTo(real);
        }
        assertThat(jdbc.queryForObject("SELECT COUNT(*) FROM flashcards WHERE deleted_at IS NULL", Long.class))
                .isGreaterThanOrEqualTo(500);
    }

    @Test
    void everyWordHasAQuizQuestion() {
        List<String> withoutQuestion = jdbc.queryForList("SELECT CONCAT(t.title, ': ', f.word) FROM flashcards f "
                + "JOIN topics t ON t.id = f.topic_id WHERE f.deleted_at IS NULL AND NOT EXISTS ("
                + "SELECT 1 FROM quiz_questions q JOIN quizzes z ON z.id = q.quiz_id "
                + "WHERE q.flashcard_id = f.id AND q.deleted_at IS NULL AND z.deleted_at IS NULL AND z.is_published = TRUE)",
                String.class);
        assertThat(withoutQuestion).as("từ chưa có câu hỏi kiểm tra").isEmpty();
    }

    @Test
    void topicQuizzesHaveReasonableLength() {
        List<Map<String, Object>> quizzes = jdbc.queryForList("SELECT z.title, COUNT(q.id) AS n FROM quizzes z "
                + "LEFT JOIN quiz_questions q ON q.quiz_id = z.id AND q.deleted_at IS NULL "
                + "WHERE z.quiz_type = 'TOPIC' AND z.deleted_at IS NULL GROUP BY z.id, z.title");
        assertThat(quizzes).isNotEmpty();
        for (Map<String, Object> quiz : quizzes) {
            assertThat(((Number) quiz.get("n")).intValue()).as("%s", quiz.get("title")).isBetween(3, 12);
        }
    }

    @Test
    void everyQuestionHasFourDistinctOptionsAndAValidAnswer() {
        assertThat(jdbc.queryForList("SELECT q.id FROM quiz_questions q LEFT JOIN quiz_question_options o ON o.question_id = q.id "
                + "GROUP BY q.id, q.correct_option_index HAVING COUNT(o.option_index) <> 4 "
                + "OR COUNT(DISTINCT o.option_text) <> 4 OR q.correct_option_index > 3", String.class))
                .as("câu hỏi sai số đáp án / trùng đáp án").isEmpty();
        assertThat(jdbc.queryForList("SELECT q.id FROM quiz_questions q LEFT JOIN quiz_question_options o "
                + "ON o.question_id = q.id AND o.option_index = q.correct_option_index WHERE o.option_text IS NULL", String.class))
                .as("đáp án đúng trỏ vào ô trống").isEmpty();
        // Đáp án đúng không bị dồn vào một vị trí
        List<Integer> distribution = jdbc.queryForList("SELECT COUNT(*) FROM quiz_questions GROUP BY correct_option_index", Integer.class);
        assertThat(distribution).hasSize(4);
    }

    @Test
    void grammarCoversTheEnglishCurriculumWithQuizzes() {
        assertThat(jdbc.queryForObject("SELECT COUNT(*) FROM grammar_lessons WHERE is_published = TRUE AND deleted_at IS NULL", Long.class))
                .isGreaterThanOrEqualTo(40);
        List<Map<String, Object>> lessons = jdbc.queryForList("SELECT g.id, g.title, g.content, "
                + "(SELECT COUNT(*) FROM grammar_examples e WHERE e.grammar_lesson_id = g.id AND e.deleted_at IS NULL) AS examples, "
                + "(SELECT COUNT(*) FROM quizzes z JOIN quiz_questions q ON q.quiz_id = z.id AND q.deleted_at IS NULL "
                + "  WHERE z.grammar_lesson_id = g.id AND z.deleted_at IS NULL AND z.is_published = TRUE) AS questions "
                + "FROM grammar_lessons g WHERE g.is_published = TRUE AND g.deleted_at IS NULL");
        for (Map<String, Object> lesson : lessons) {
            String title = (String) lesson.get("title");
            assertThat((String) lesson.get("content")).as("nội dung %s", title).isNotBlank();
            assertThat(((Number) lesson.get("examples")).intValue()).as("ví dụ %s", title).isGreaterThanOrEqualTo(3);
            assertThat(((Number) lesson.get("questions")).intValue()).as("câu hỏi %s", title).isGreaterThanOrEqualTo(5);
        }
        List<String> titles = jdbc.queryForList("SELECT title FROM grammar_lessons", String.class);
        assertThat(titles).contains("Present Simple", "Past Simple", "Present Perfect", "First Conditional",
                "Second Conditional", "Third Conditional", "Passive Voice", "Reported Speech", "Relative Clauses");
    }
}
