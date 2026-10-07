-- =====================================================================
-- V5: Phản hồi (feedback) của người dùng về từ vựng / ngữ pháp / bài kiểm tra
-- (V4 đã dùng cho bộ seed ở db/seed nên migration này là V5.)
-- =====================================================================

-- item_id trỏ tới flashcards / grammar_lessons / quizzes tuỳ feedback_for nên KHÔNG có FK (đa hình).
-- Item chỉ bị xoá mềm, FK cũng không chạy được -> backend xoá cứng feedback của item khi item bị xoá.
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
