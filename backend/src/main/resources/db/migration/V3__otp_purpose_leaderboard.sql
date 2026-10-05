-- =====================================================================
-- V3: OTP dùng chung nhiều mục đích + bảng xếp hạng có slogan, không tính ADMIN
-- =====================================================================

-- password_reset_tokens trở thành bảng OTP chung: đặt lại mật khẩu, xác thực email khi đăng ký,
-- xác nhận đổi mật khẩu. Dòng cũ đều là OTP đặt lại mật khẩu nên DEFAULT giữ nguyên ý nghĩa.
-- Thêm index mới và bỏ index cũ trong cùng một câu lệnh vì FK fk_prt_user đang dựa vào idx_prt_user.
ALTER TABLE password_reset_tokens
  ADD COLUMN purpose ENUM('PASSWORD_RESET','EMAIL_VERIFY','CHANGE_PASSWORD') NOT NULL DEFAULT 'PASSWORD_RESET' AFTER user_id,
  ADD KEY idx_prt_user_purpose (user_id, purpose, expires_at),
  DROP KEY idx_prt_user;

-- Bảng xếp hạng: trả thêm slogan (hiển thị dưới tên) và chỉ tính học viên, admin không tham gia xếp hạng.
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
