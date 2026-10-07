-- =====================================================================
-- AdvancedMobile_Flash - Server schema
-- Target : MySQL 8.0.16+ (InnoDB, utf8mb4, CHECK constraints enforced)
-- Conventions:
--   * PK  : CHAR(36) UUID (client có thể tự sinh id khi offline -> không đụng độ)
--           Ngoại lệ: bảng ledger/log nội bộ server dùng BIGINT AUTO_INCREMENT.
--   * Time: DATETIME(3) lưu UTC (JDBC: serverTimezone=UTC), ms precision.
--   * Sync: version (optimistic lock, tăng mỗi lần ghi), client_updated_at (LWW),
--           updated_at (delta pull cursor), deleted_at (soft delete / tombstone).
--   * Lưu ý MySQL: cột tham gia FK có ON DELETE CASCADE/SET NULL KHÔNG được
--     dùng trong CHECK constraint -> các ràng buộc kiểu "đúng 1 trong 2 FK"
--     được enforce ở tầng service.
-- =====================================================================

CREATE DATABASE IF NOT EXISTS flash_db
  CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE flash_db;

-- =====================================================================
-- 1. AUTH & IDENTITY DOMAIN
-- =====================================================================

CREATE TABLE users (
  id                  CHAR(36)        NOT NULL,
  email               VARCHAR(255)    NOT NULL,
  password_hash       VARCHAR(100)    NULL COMMENT 'BCrypt; NULL nếu chỉ đăng nhập Google',
  full_name           VARCHAR(100)    NOT NULL,
  avatar_url          VARCHAR(500)    NULL,
  level               ENUM('A1','A2','B1','B2','C1','C2') NOT NULL DEFAULT 'A1',
  slogan              VARCHAR(255)    NOT NULL DEFAULT 'Học, học nữa, học mãi!',
  -- Gamification counters (server-authoritative, chỉ service XP được ghi)
  current_xp          INT UNSIGNED    NOT NULL DEFAULT 0 COMMENT 'Số dư XP, bị trừ khi mua đồ',
  target_xp           INT UNSIGNED    NOT NULL DEFAULT 100,
  total_lifetime_xp   BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Tổng XP trọn đời, không bao giờ giảm',
  streak_days         INT UNSIGNED    NOT NULL DEFAULT 0,
  longest_streak      INT UNSIGNED    NOT NULL DEFAULT 0,
  last_active_date    DATE            NULL COMMENT 'Ngày học gần nhất theo timezone của user',
  -- Denormalized counters (cache có chủ đích, xem mục 2.3)
  total_words_learned INT UNSIGNED    NOT NULL DEFAULT 0,
  completed_lessons   INT UNSIGNED    NOT NULL DEFAULT 0,
  timezone            VARCHAR(64)     NOT NULL DEFAULT 'Asia/Ho_Chi_Minh',
  role                ENUM('USER','ADMIN') NOT NULL DEFAULT 'USER',
  status              ENUM('PENDING_VERIFY','ACTIVE','LOCKED') NOT NULL DEFAULT 'ACTIVE',
  email_verified_at   DATETIME(3)     NULL,
  version             INT UNSIGNED    NOT NULL DEFAULT 0,
  client_updated_at   DATETIME(3)     NULL COMMENT 'Thời điểm client sửa profile (slogan...)',
  created_at          DATETIME(3)     NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at          DATETIME(3)     NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  deleted_at          DATETIME(3)     NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_users_email (email),
  KEY idx_users_lb_xp     (status, deleted_at, total_lifetime_xp DESC),
  KEY idx_users_lb_streak (status, deleted_at, longest_streak DESC),
  CONSTRAINT chk_users_streak CHECK (longest_streak >= streak_days)
) ENGINE=InnoDB;

CREATE TABLE user_auth_providers (
  id                CHAR(36)     NOT NULL,
  user_id           CHAR(36)     NOT NULL,
  provider          ENUM('GOOGLE') NOT NULL,
  provider_user_id  VARCHAR(255) NOT NULL COMMENT 'Google "sub" claim',
  provider_email    VARCHAR(255) NULL,
  created_at        DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_provider_subject (provider, provider_user_id),
  UNIQUE KEY uk_user_provider (user_id, provider),
  CONSTRAINT fk_uap_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE refresh_tokens (
  id              CHAR(36)     NOT NULL,
  user_id         CHAR(36)     NOT NULL,
  token_hash      CHAR(64)     NOT NULL COMMENT 'SHA-256 của refresh token, không lưu token thô',
  device_id       VARCHAR(100) NULL,
  user_agent      VARCHAR(255) NULL,
  expires_at      DATETIME(3)  NOT NULL,
  revoked_at      DATETIME(3)  NULL,
  replaced_by_id  CHAR(36)     NULL COMMENT 'Refresh token rotation: token kế nhiệm',
  created_at      DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_refresh_token_hash (token_hash),
  KEY idx_refresh_user (user_id, revoked_at),
  CONSTRAINT fk_rt_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE password_reset_tokens (
  id             CHAR(36)    NOT NULL,
  user_id        CHAR(36)    NOT NULL,
  purpose        ENUM('PASSWORD_RESET','EMAIL_VERIFY','CHANGE_PASSWORD') NOT NULL DEFAULT 'PASSWORD_RESET',
  token_hash     CHAR(64)    NOT NULL COMMENT 'SHA-256 của OTP/token gửi qua email',
  expires_at     DATETIME(3) NOT NULL,
  used_at        DATETIME(3) NULL,
  attempt_count  TINYINT UNSIGNED NOT NULL DEFAULT 0,
  created_at     DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_prt_hash (token_hash),
  KEY idx_prt_user_purpose (user_id, purpose, expires_at),
  CONSTRAINT fk_prt_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 1-1 với users. Bản gốc nằm ở SharedPreferences; bảng này chỉ để đồng bộ đa thiết bị
-- và để server biết giờ nhắc học nếu sau này gửi push notification.
CREATE TABLE user_settings (
  user_id                  CHAR(36)    NOT NULL,
  is_notification_enabled  BOOLEAN     NOT NULL DEFAULT TRUE,
  is_sound_enabled         BOOLEAN     NOT NULL DEFAULT TRUE,
  is_vibration_enabled     BOOLEAN     NOT NULL DEFAULT TRUE,
  is_dark_mode             BOOLEAN     NOT NULL DEFAULT FALSE,
  app_language             VARCHAR(10) NOT NULL DEFAULT 'vi',
  daily_reminder_time      TIME        NULL,
  daily_goal_lessons       TINYINT UNSIGNED NOT NULL DEFAULT 5 COMMENT 'Mục tiêu "3/5 bài" ở Home',
  version                  INT UNSIGNED NOT NULL DEFAULT 0,
  client_updated_at        DATETIME(3) NULL,
  updated_at               DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (user_id),
  CONSTRAINT fk_us_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =====================================================================
-- 2. LEARNING CONTENT DOMAIN (admin quản lý, client chỉ đọc + cache)
-- =====================================================================

CREATE TABLE topics (
  id                 CHAR(36)     NOT NULL,
  title              VARCHAR(150) NOT NULL,
  description        VARCHAR(500) NULL,
  icon_path          VARCHAR(255) NOT NULL,
  level              ENUM('A1','A2','B1','B2','C1','C2') NOT NULL DEFAULT 'A1',
  cover_color        INT UNSIGNED NULL COMMENT 'ARGB 0xAARRGGBB -> Color(int) trong Flutter',
  estimated_minutes  SMALLINT UNSIGNED NOT NULL DEFAULT 10,
  total_words        INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Counter, cập nhật khi thêm/xoá flashcard',
  sort_order         INT          NOT NULL DEFAULT 0,
  is_published       BOOLEAN      NOT NULL DEFAULT FALSE,
  version            INT UNSIGNED NOT NULL DEFAULT 0,
  created_at         DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at         DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  deleted_at         DATETIME(3)  NULL,
  PRIMARY KEY (id),
  KEY idx_topics_list (is_published, deleted_at, sort_order),
  KEY idx_topics_updated (updated_at),
  FULLTEXT KEY ft_topics_title (title)
) ENGINE=InnoDB;

CREATE TABLE flashcards (
  id                   CHAR(36)     NOT NULL,
  topic_id             CHAR(36)     NOT NULL,
  word                 VARCHAR(100) NOT NULL,
  part_of_speech       VARCHAR(30)  NOT NULL,
  pronunciation        VARCHAR(100) NOT NULL,
  meaning              VARCHAR(500) NOT NULL,
  example              TEXT         NULL,
  example_translation  TEXT         NULL,
  audio_url            VARCHAR(500) NULL,
  image_url            VARCHAR(500) NULL,
  sort_order           INT          NOT NULL DEFAULT 0,
  version              INT UNSIGNED NOT NULL DEFAULT 0,
  created_at           DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at           DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  deleted_at           DATETIME(3)  NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_flashcards_topic_word (topic_id, word),
  KEY idx_flashcards_topic (topic_id, deleted_at, sort_order),
  KEY idx_flashcards_word (word),
  KEY idx_flashcards_updated (updated_at),
  FULLTEXT KEY ft_flashcards_search (word, meaning),
  CONSTRAINT fk_fc_topic FOREIGN KEY (topic_id) REFERENCES topics (id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE grammar_lessons (
  id                 CHAR(36)     NOT NULL,
  title              VARCHAR(150) NOT NULL,
  description        VARCHAR(500) NULL,
  structure          VARCHAR(255) NOT NULL COMMENT 'VD: S + am/is/are + V-ing',
  content            TEXT         NULL COMMENT 'Giải thích chi tiết (Markdown)',
  usage_notes        TEXT         NULL,
  icon_name          VARCHAR(50)  NOT NULL COMMENT 'Tên Material icon, Flutter tự map sang IconData',
  level              ENUM('A1','A2','B1','B2','C1','C2') NOT NULL DEFAULT 'A1',
  cover_color        INT UNSIGNED NULL,
  estimated_minutes  SMALLINT UNSIGNED NOT NULL DEFAULT 10,
  sort_order         INT          NOT NULL DEFAULT 0,
  is_published       BOOLEAN      NOT NULL DEFAULT FALSE,
  version            INT UNSIGNED NOT NULL DEFAULT 0,
  created_at         DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at         DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  deleted_at         DATETIME(3)  NULL,
  PRIMARY KEY (id),
  KEY idx_grammar_list (is_published, deleted_at, sort_order),
  KEY idx_grammar_updated (updated_at),
  FULLTEXT KEY ft_grammar_title (title)
) ENGINE=InnoDB;

CREATE TABLE grammar_examples (
  id                 CHAR(36)     NOT NULL,
  grammar_lesson_id  CHAR(36)     NOT NULL,
  sentence           TEXT         NOT NULL,
  translation        TEXT         NULL,
  highlight          VARCHAR(100) NULL COMMENT 'Cụm cần tô đậm trong câu, VD: "is playing"',
  sort_order         INT          NOT NULL DEFAULT 0,
  created_at         DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at         DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  deleted_at         DATETIME(3)  NULL,
  PRIMARY KEY (id),
  KEY idx_ge_lesson (grammar_lesson_id, sort_order),
  CONSTRAINT fk_ge_lesson FOREIGN KEY (grammar_lesson_id) REFERENCES grammar_lessons (id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Một quiz thuộc về đúng 1 trong 2: topic HOẶC grammar_lesson (enforce ở service).
CREATE TABLE quizzes (
  id                  CHAR(36)     NOT NULL,
  title               VARCHAR(150) NOT NULL,
  quiz_type           ENUM('TOPIC','GRAMMAR') NOT NULL,
  topic_id            CHAR(36)     NULL,
  grammar_lesson_id   CHAR(36)     NULL,
  time_limit_seconds  INT UNSIGNED NULL,
  pass_score_percent  TINYINT UNSIGNED NOT NULL DEFAULT 70,
  is_published        BOOLEAN      NOT NULL DEFAULT FALSE,
  version             INT UNSIGNED NOT NULL DEFAULT 0,
  created_at          DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at          DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  deleted_at          DATETIME(3)  NULL,
  PRIMARY KEY (id),
  KEY idx_quizzes_topic (topic_id),
  KEY idx_quizzes_grammar (grammar_lesson_id),
  KEY idx_quizzes_updated (updated_at),
  CONSTRAINT chk_quizzes_pass CHECK (pass_score_percent BETWEEN 0 AND 100),
  CONSTRAINT fk_quiz_topic   FOREIGN KEY (topic_id)          REFERENCES topics (id)          ON DELETE CASCADE,
  CONSTRAINT fk_quiz_grammar FOREIGN KEY (grammar_lesson_id) REFERENCES grammar_lessons (id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE quiz_questions (
  id                    CHAR(36)    NOT NULL,
  quiz_id               CHAR(36)    NOT NULL,
  flashcard_id          CHAR(36)    NULL COMMENT 'Câu hỏi sinh từ từ vựng nào (nếu có)',
  question_text         TEXT        NOT NULL,
  correct_option_index  TINYINT UNSIGNED NOT NULL,
  explanation           TEXT        NULL COMMENT 'Hiển thị ở QuizReviewScreen',
  sort_order            INT         NOT NULL DEFAULT 0,
  version               INT UNSIGNED NOT NULL DEFAULT 0,
  created_at            DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at            DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  deleted_at            DATETIME(3) NULL,
  PRIMARY KEY (id),
  KEY idx_qq_quiz (quiz_id, sort_order),
  KEY idx_qq_flashcard (flashcard_id),
  CONSTRAINT chk_qq_correct CHECK (correct_option_index BETWEEN 0 AND 3),
  CONSTRAINT fk_qq_quiz      FOREIGN KEY (quiz_id)      REFERENCES quizzes (id)    ON DELETE CASCADE,
  CONSTRAINT fk_qq_flashcard FOREIGN KEY (flashcard_id) REFERENCES flashcards (id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Chuẩn hoá 4 đáp án A/B/C/D thành bảng con (1NF) thay vì JSON.
CREATE TABLE quiz_question_options (
  question_id   CHAR(36)     NOT NULL,
  option_index  TINYINT UNSIGNED NOT NULL COMMENT '0=A, 1=B, 2=C, 3=D',
  option_text   VARCHAR(500) NOT NULL,
  PRIMARY KEY (question_id, option_index),
  CONSTRAINT chk_qqo_index CHECK (option_index BETWEEN 0 AND 3),
  CONSTRAINT fk_qqo_question FOREIGN KEY (question_id) REFERENCES quiz_questions (id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =====================================================================
-- 3. USER PROGRESS & SRS DOMAIN
-- =====================================================================

-- Trạng thái SRS hiện tại của từng (user, flashcard) - bảng n-n users x flashcards.
-- Được server TÍNH LẠI từ flashcard_review_logs (event sourcing), không nhận trực tiếp từ client.
CREATE TABLE user_flashcard_progress (
  user_id           CHAR(36)    NOT NULL,
  flashcard_id      CHAR(36)    NOT NULL,
  box               TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Leitner box 0..5',
  repetitions       INT UNSIGNED NOT NULL DEFAULT 0,
  again_count       INT UNSIGNED NOT NULL DEFAULT 0,
  know_count        INT UNSIGNED NOT NULL DEFAULT 0,
  last_rating       ENUM('AGAIN','KNOW') NULL,
  is_learned        BOOLEAN     NOT NULL DEFAULT FALSE COMMENT 'TRUE khi box >= 3',
  last_reviewed_at  DATETIME(3) NULL,
  due_at            DATETIME(3) NULL COMMENT 'Thời điểm cần ôn lại',
  version           INT UNSIGNED NOT NULL DEFAULT 0,
  created_at        DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at        DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (user_id, flashcard_id),
  KEY idx_ufp_due (user_id, due_at),
  KEY idx_ufp_learned (user_id, is_learned),
  KEY idx_ufp_updated (user_id, updated_at),
  KEY idx_ufp_flashcard (flashcard_id),
  CONSTRAINT chk_ufp_box CHECK (box <= 5),
  CONSTRAINT fk_ufp_user      FOREIGN KEY (user_id)      REFERENCES users (id)      ON DELETE CASCADE,
  CONSTRAINT fk_ufp_flashcard FOREIGN KEY (flashcard_id) REFERENCES flashcards (id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Append-only log mỗi lần bấm "Again"/"Know". id do client sinh (UUID) -> idempotent.
CREATE TABLE flashcard_review_logs (
  id                CHAR(36)    NOT NULL,
  user_id           CHAR(36)    NOT NULL,
  flashcard_id      CHAR(36)    NOT NULL,
  rating            ENUM('AGAIN','KNOW') NOT NULL,
  box_before        TINYINT UNSIGNED NOT NULL,
  box_after         TINYINT UNSIGNED NOT NULL,
  response_time_ms  INT UNSIGNED NULL,
  reviewed_at       DATETIME(3) NOT NULL COMMENT 'Giờ client (đã hiệu chỉnh lệch đồng hồ)',
  received_at       DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  KEY idx_frl_user_time (user_id, reviewed_at),
  KEY idx_frl_card (user_id, flashcard_id, reviewed_at),
  KEY idx_frl_flashcard (flashcard_id),
  CONSTRAINT fk_frl_user      FOREIGN KEY (user_id)      REFERENCES users (id)      ON DELETE CASCADE,
  CONSTRAINT fk_frl_flashcard FOREIGN KEY (flashcard_id) REFERENCES flashcards (id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Ghi chú cá nhân: tối đa 1 ghi chú / (user, flashcard). Xoá = soft delete (tombstone để sync).
CREATE TABLE user_flashcard_notes (
  id                 CHAR(36)    NOT NULL,
  user_id            CHAR(36)    NOT NULL,
  flashcard_id       CHAR(36)    NOT NULL,
  content            TEXT        NOT NULL,
  version            INT UNSIGNED NOT NULL DEFAULT 0,
  client_updated_at  DATETIME(3) NOT NULL,
  created_at         DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at         DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  deleted_at         DATETIME(3) NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_ufn_user_card (user_id, flashcard_id),
  KEY idx_ufn_updated (user_id, updated_at),
  KEY idx_ufn_flashcard (flashcard_id),
  CONSTRAINT fk_ufn_user      FOREIGN KEY (user_id)      REFERENCES users (id)      ON DELETE CASCADE,
  CONSTRAINT fk_ufn_flashcard FOREIGN KEY (flashcard_id) REFERENCES flashcards (id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Bookmark / từ yêu thích. Bỏ bookmark = set deleted_at (tombstone), bookmark lại = clear deleted_at.
CREATE TABLE user_bookmarks (
  user_id            CHAR(36)    NOT NULL,
  flashcard_id       CHAR(36)    NOT NULL,
  version            INT UNSIGNED NOT NULL DEFAULT 0,
  client_updated_at  DATETIME(3) NOT NULL,
  created_at         DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at         DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  deleted_at         DATETIME(3) NULL,
  PRIMARY KEY (user_id, flashcard_id),
  KEY idx_ub_list (user_id, deleted_at, created_at),
  KEY idx_ub_updated (user_id, updated_at),
  KEY idx_ub_flashcard (flashcard_id),
  CONSTRAINT fk_ub_user      FOREIGN KEY (user_id)      REFERENCES users (id)      ON DELETE CASCADE,
  CONSTRAINT fk_ub_flashcard FOREIGN KEY (flashcard_id) REFERENCES flashcards (id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE user_topic_progress (
  user_id          CHAR(36)    NOT NULL,
  topic_id         CHAR(36)    NOT NULL,
  learned_words    INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Số flashcard is_learned trong topic',
  status           ENUM('NOT_STARTED','IN_PROGRESS','COMPLETED') NOT NULL DEFAULT 'NOT_STARTED',
  last_studied_at  DATETIME(3) NULL,
  completed_at     DATETIME(3) NULL,
  version          INT UNSIGNED NOT NULL DEFAULT 0,
  created_at       DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at       DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (user_id, topic_id),
  KEY idx_utp_status (user_id, status, last_studied_at),
  KEY idx_utp_updated (user_id, updated_at),
  KEY idx_utp_topic (topic_id),
  CONSTRAINT fk_utp_user  FOREIGN KEY (user_id)  REFERENCES users (id)  ON DELETE CASCADE,
  CONSTRAINT fk_utp_topic FOREIGN KEY (topic_id) REFERENCES topics (id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE user_grammar_progress (
  user_id            CHAR(36)    NOT NULL,
  grammar_lesson_id  CHAR(36)    NOT NULL,
  progress           DECIMAL(5,4) NOT NULL DEFAULT 0 COMMENT '0.0000 .. 1.0000',
  status             ENUM('NOT_STARTED','IN_PROGRESS','COMPLETED') NOT NULL DEFAULT 'NOT_STARTED',
  best_score_percent TINYINT UNSIGNED NULL,
  last_studied_at    DATETIME(3) NULL,
  completed_at       DATETIME(3) NULL,
  version            INT UNSIGNED NOT NULL DEFAULT 0,
  created_at         DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at         DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (user_id, grammar_lesson_id),
  KEY idx_ugp_status (user_id, status, last_studied_at),
  KEY idx_ugp_updated (user_id, updated_at),
  KEY idx_ugp_lesson (grammar_lesson_id),
  CONSTRAINT chk_ugp_progress CHECK (progress BETWEEN 0 AND 1),
  CONSTRAINT fk_ugp_user   FOREIGN KEY (user_id)           REFERENCES users (id)           ON DELETE CASCADE,
  CONSTRAINT fk_ugp_lesson FOREIGN KEY (grammar_lesson_id) REFERENCES grammar_lessons (id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Một phiên học hoàn thành (một "bài" trong mục tiêu ngày 3/5). id do client sinh.
-- Đúng 1 trong topic_id / grammar_lesson_id khác NULL (enforce ở service).
CREATE TABLE lesson_completions (
  id                 CHAR(36)    NOT NULL,
  user_id            CHAR(36)    NOT NULL,
  lesson_type        ENUM('TOPIC','GRAMMAR') NOT NULL,
  topic_id           CHAR(36)    NULL,
  grammar_lesson_id  CHAR(36)    NULL,
  cards_reviewed     INT UNSIGNED NOT NULL DEFAULT 0,
  duration_seconds   INT UNSIGNED NOT NULL DEFAULT 0,
  completed_at       DATETIME(3) NOT NULL,
  received_at        DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  KEY idx_lc_user_time (user_id, completed_at),
  KEY idx_lc_topic (topic_id),
  KEY idx_lc_grammar (grammar_lesson_id),
  CONSTRAINT fk_lc_user    FOREIGN KEY (user_id)           REFERENCES users (id)           ON DELETE CASCADE,
  CONSTRAINT fk_lc_topic   FOREIGN KEY (topic_id)          REFERENCES topics (id)          ON DELETE CASCADE,
  CONSTRAINT fk_lc_grammar FOREIGN KEY (grammar_lesson_id) REFERENCES grammar_lessons (id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Một lần làm quiz (QuizResult). id do client sinh -> nộp lại khi mất mạng không bị nhân đôi.
-- correct_answers / wrong_answers do SERVER chấm từ quiz_attempt_answers.
CREATE TABLE quiz_attempts (
  id                  CHAR(36)    NOT NULL,
  user_id             CHAR(36)    NOT NULL,
  quiz_id             CHAR(36)    NOT NULL,
  total_questions     SMALLINT UNSIGNED NOT NULL,
  correct_answers     SMALLINT UNSIGNED NOT NULL,
  wrong_answers       SMALLINT UNSIGNED NOT NULL,
  score_percent       TINYINT UNSIGNED NOT NULL,
  time_taken_seconds  INT UNSIGNED NOT NULL,
  started_at          DATETIME(3) NOT NULL,
  submitted_at        DATETIME(3) NOT NULL,
  received_at         DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  KEY idx_qa_user_time (user_id, submitted_at),
  KEY idx_qa_user_quiz (user_id, quiz_id, submitted_at),
  KEY idx_qa_quiz (quiz_id),
  CONSTRAINT chk_qa_sum   CHECK (correct_answers + wrong_answers <= total_questions),
  CONSTRAINT chk_qa_score CHECK (score_percent <= 100),
  CONSTRAINT fk_qa_user FOREIGN KEY (user_id) REFERENCES users (id)   ON DELETE CASCADE,
  CONSTRAINT fk_qa_quiz FOREIGN KEY (quiz_id) REFERENCES quizzes (id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Đáp án user chọn cho từng câu -> nguồn của wrongQuestionIds và QuizReviewItem.userIndex.
CREATE TABLE quiz_attempt_answers (
  attempt_id             CHAR(36)    NOT NULL,
  question_id            CHAR(36)    NOT NULL,
  selected_option_index  TINYINT UNSIGNED NULL COMMENT 'NULL = bỏ qua (Dart: -1)',
  is_correct             BOOLEAN     NOT NULL,
  answered_at            DATETIME(3) NULL,
  PRIMARY KEY (attempt_id, question_id),
  KEY idx_qaa_question (question_id),
  CONSTRAINT chk_qaa_index CHECK (selected_option_index IS NULL OR selected_option_index BETWEEN 0 AND 3),
  CONSTRAINT fk_qaa_attempt  FOREIGN KEY (attempt_id)  REFERENCES quiz_attempts (id)  ON DELETE CASCADE,
  CONSTRAINT fk_qaa_question FOREIGN KEY (question_id) REFERENCES quiz_questions (id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =====================================================================
-- 4. GAMIFICATION & ECONOMY DOMAIN
-- =====================================================================

-- Sổ cái XP (ledger). users.current_xp / total_lifetime_xp chỉ là số dư cache của bảng này.
-- UNIQUE(user_id, source_type, source_id) => mỗi sự kiện chỉ được cộng XP đúng 1 lần.
CREATE TABLE xp_transactions (
  id             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id        CHAR(36)    NOT NULL,
  amount         INT         NOT NULL COMMENT 'Dương = nhận, âm = tiêu (mua đồ)',
  balance_after  INT UNSIGNED NOT NULL,
  source_type    ENUM('FLASHCARD_REVIEW','LESSON_COMPLETE','QUIZ','QUEST','STREAK_BONUS','SHOP_PURCHASE','ADMIN_ADJUST') NOT NULL,
  source_id      VARCHAR(64) NOT NULL COMMENT 'id của review log / attempt / user_quest / inventory...',
  note           VARCHAR(255) NULL,
  created_at     DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_xp_source (user_id, source_type, source_id),
  KEY idx_xp_user_time (user_id, created_at),
  CONSTRAINT chk_xp_amount CHECK (amount <> 0),
  CONSTRAINT fk_xp_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE quest_definitions (
  id            CHAR(36)     NOT NULL,
  code          VARCHAR(50)  NOT NULL,
  title         VARCHAR(150) NOT NULL COMMENT 'VD: Học 20 từ mới',
  description   VARCHAR(500) NULL,
  quest_type    ENUM('LEARN_WORDS','REVIEW_CARDS','COMPLETE_LESSON','COMPLETE_QUIZ','PERFECT_QUIZ','STUDY_MINUTES','KEEP_STREAK') NOT NULL,
  frequency     ENUM('DAILY','WEEKLY','ONE_TIME') NOT NULL DEFAULT 'DAILY',
  target_value  INT UNSIGNED NOT NULL,
  xp_reward     INT UNSIGNED NOT NULL,
  icon_name     VARCHAR(50)  NOT NULL,
  is_active     BOOLEAN      NOT NULL DEFAULT TRUE,
  sort_order    INT          NOT NULL DEFAULT 0,
  created_at    DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at    DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_quest_code (code),
  KEY idx_quest_active (is_active, frequency, sort_order),
  CONSTRAINT chk_quest_target CHECK (target_value > 0)
) ENGINE=InnoDB;

-- Nhiệm vụ đã giao cho user trong 1 chu kỳ (ngày/tuần).
-- target_value / xp_reward được SNAPSHOT tại lúc giao để admin sửa định nghĩa không làm sai lịch sử.
CREATE TABLE user_quests (
  id                   CHAR(36)    NOT NULL,
  user_id              CHAR(36)    NOT NULL,
  quest_definition_id  CHAR(36)    NOT NULL,
  period_start         DATE        NOT NULL COMMENT 'Ngày giao (DAILY) / thứ Hai đầu tuần (WEEKLY)',
  current_value        INT UNSIGNED NOT NULL DEFAULT 0,
  target_value         INT UNSIGNED NOT NULL,
  xp_reward            INT UNSIGNED NOT NULL,
  completed_at         DATETIME(3) NULL,
  is_claimed           BOOLEAN     NOT NULL DEFAULT FALSE,
  claimed_at           DATETIME(3) NULL,
  version              INT UNSIGNED NOT NULL DEFAULT 0,
  created_at           DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at           DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_uq_period (user_id, quest_definition_id, period_start),
  KEY idx_uq_user_period (user_id, period_start),
  KEY idx_uq_updated (user_id, updated_at),
  KEY idx_uq_definition (quest_definition_id),
  CONSTRAINT chk_uq_claim CHECK (is_claimed = FALSE OR claimed_at IS NOT NULL),
  CONSTRAINT fk_uq_user       FOREIGN KEY (user_id)             REFERENCES users (id)             ON DELETE CASCADE,
  CONSTRAINT fk_uq_definition FOREIGN KEY (quest_definition_id) REFERENCES quest_definitions (id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE reward_items (
  id             CHAR(36)     NOT NULL,
  code           VARCHAR(50)  NOT NULL,
  name           VARCHAR(100) NOT NULL,
  description    VARCHAR(255) NULL,
  item_type      ENUM('BORDER','AVATAR') NOT NULL,
  xp_cost        INT UNSIGNED NOT NULL DEFAULT 0,
  border_colors  JSON         NULL COMMENT 'Mảng ARGB int, VD: [4294198070, 4294940672]',
  image_url      VARCHAR(500) NULL COMMENT 'Dùng cho AVATAR',
  required_rank  SMALLINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '0 = không yêu cầu; 3 = phải Top 3',
  rank_board     ENUM('XP','STREAK') NOT NULL DEFAULT 'XP',
  is_active      BOOLEAN      NOT NULL DEFAULT TRUE,
  sort_order     INT          NOT NULL DEFAULT 0,
  created_at     DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at     DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_reward_code (code),
  KEY idx_reward_list (is_active, item_type, sort_order),
  KEY idx_reward_updated (updated_at),
  CONSTRAINT chk_reward_border CHECK (item_type <> 'BORDER' OR border_colors IS NOT NULL)
) ENGINE=InnoDB;

-- Kho đồ. Có bản ghi = đã sở hữu (RewardItem.isUnlocked).
-- "Mỗi loại chỉ trang bị 1 món" enforce ở service (SELECT ... FOR UPDATE rồi bỏ equip món cũ).
CREATE TABLE user_inventories (
  id                 CHAR(36)    NOT NULL,
  user_id            CHAR(36)    NOT NULL,
  reward_item_id     CHAR(36)    NOT NULL,
  is_equipped        BOOLEAN     NOT NULL DEFAULT FALSE,
  unlocked_at        DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  version            INT UNSIGNED NOT NULL DEFAULT 0,
  client_updated_at  DATETIME(3) NULL COMMENT 'LWW cho thao tác equip/unequip',
  updated_at         DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_inv_user_item (user_id, reward_item_id),
  KEY idx_inv_equipped (user_id, is_equipped),
  KEY idx_inv_updated (user_id, updated_at),
  KEY idx_inv_item (reward_item_id),
  CONSTRAINT fk_inv_user FOREIGN KEY (user_id)        REFERENCES users (id)        ON DELETE CASCADE,
  CONSTRAINT fk_inv_item FOREIGN KEY (reward_item_id) REFERENCES reward_items (id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =====================================================================
-- 5. ACTIVITY & TRACKING DOMAIN
-- =====================================================================

-- Một dòng / user / ngày (theo timezone của user). Server là nguồn chân lý.
CREATE TABLE daily_statistics (
  id                 CHAR(36)    NOT NULL,
  user_id            CHAR(36)    NOT NULL,
  stat_date          DATE        NOT NULL,
  words_learned      INT UNSIGNED NOT NULL DEFAULT 0,
  cards_reviewed     INT UNSIGNED NOT NULL DEFAULT 0,
  xp_gained          INT UNSIGNED NOT NULL DEFAULT 0,
  lessons_completed  INT UNSIGNED NOT NULL DEFAULT 0,
  quizzes_completed  INT UNSIGNED NOT NULL DEFAULT 0,
  correct_answers    INT UNSIGNED NOT NULL DEFAULT 0,
  total_answers      INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Accuracy = correct_answers / total_answers',
  study_seconds      INT UNSIGNED NOT NULL DEFAULT 0,
  created_at         DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at         DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_ds_user_date (user_id, stat_date),
  KEY idx_ds_updated (user_id, updated_at),
  CONSTRAINT chk_ds_answers CHECK (correct_answers <= total_answers),
  CONSTRAINT fk_ds_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =====================================================================
-- 6. SYNC INFRASTRUCTURE
-- =====================================================================

-- Sổ idempotency: mỗi op_id (client sinh) chỉ được xử lý 1 lần.
-- Client retry cùng op_id -> server trả lại result_json đã lưu. Dọn bản ghi > 30 ngày.
CREATE TABLE sync_operations (
  op_id              CHAR(36)    NOT NULL,
  user_id            CHAR(36)    NOT NULL,
  op_type            VARCHAR(40) NOT NULL,
  status             ENUM('APPLIED','REJECTED') NOT NULL,
  error_code         VARCHAR(50) NULL,
  result_json        JSON        NULL,
  client_created_at  DATETIME(3) NOT NULL,
  processed_at       DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (op_id),
  KEY idx_so_user_time (user_id, processed_at),
  KEY idx_so_processed (processed_at),
  CONSTRAINT fk_so_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =====================================================================
-- 6b. FEEDBACK (migration V5__feedback.sql)
-- =====================================================================

-- Phản hồi của user về flashcard / grammar / quiz. item_id đa hình nên KHÔNG có FK;
-- item chỉ bị xoá mềm nên backend xoá cứng feedback của item trong cùng transaction với việc xoá item.
CREATE TABLE feedbacks (
  id            CHAR(36)    NOT NULL,
  user_id       CHAR(36)    NOT NULL,
  content       TEXT        NOT NULL,
  feedback_for  TINYINT     NOT NULL COMMENT '1=flashcard, 2=grammar, 3=quiz',
  item_id       CHAR(36)    NOT NULL COMMENT 'id của flashcard / grammar lesson / quiz tuỳ feedback_for',
  is_viewed     BOOLEAN     NOT NULL DEFAULT FALSE COMMENT 'Admin đã xem; đã xem thì user không sửa/xoá được',
  created_at    DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at    DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  KEY idx_fb_user_created (user_id, created_at),
  KEY idx_fb_for_created (feedback_for, created_at),
  KEY idx_fb_item (item_id),
  KEY idx_fb_viewed (is_viewed),
  CONSTRAINT chk_fb_for CHECK (feedback_for IN (1, 2, 3)),
  CONSTRAINT fk_fb_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =====================================================================
-- 7. READ MODELS - LEADERBOARD
-- =====================================================================

CREATE OR REPLACE VIEW v_leaderboard_xp AS
SELECT u.id                AS user_id,
       u.full_name,
       u.avatar_url,
       u.slogan,
       u.total_lifetime_xp AS score,
       RANK() OVER (ORDER BY u.total_lifetime_xp DESC) AS rank_no
FROM users u
WHERE u.status = 'ACTIVE' AND u.deleted_at IS NULL AND u.role = 'USER';

CREATE OR REPLACE VIEW v_leaderboard_streak AS
SELECT u.id             AS user_id,
       u.full_name,
       u.avatar_url,
       u.slogan,
       u.longest_streak AS score,
       RANK() OVER (ORDER BY u.longest_streak DESC) AS rank_no
FROM users u
WHERE u.status = 'ACTIVE' AND u.deleted_at IS NULL AND u.role = 'USER';
