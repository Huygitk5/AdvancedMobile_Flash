-- =====================================================================
-- Seed nội dung học, chuyển từ lib/data/mock_data.dart.
-- UUID cố định theo tiền tố để dễ test:
--   10.. topics | 20.. grammar_lessons | 21.. grammar_examples | 30.. flashcards
--   40.. quizzes | 41.. quiz_questions | 50.. quest_definitions | 60.. reward_items
-- topics.total_words = số flashcard thật đang có (mock ghi 25/30 nhưng chỉ có 2 từ).
-- Không seed user: tài khoản được tạo qua API đăng ký (G2).
-- =====================================================================

INSERT INTO topics (id, title, icon_path, level, cover_color, estimated_minutes, total_words, sort_order, is_published) VALUES
  ('10000000-0000-0000-0000-000000000001', 'Daily Life', '☀️', 'A1', 4294959282, 10, 1, 1, TRUE),
  ('10000000-0000-0000-0000-000000000002', 'Travel', '✈️', 'A2', 4290502395, 8, 0, 2, TRUE),
  ('10000000-0000-0000-0000-000000000003', 'Food & Drink', '🍔', 'A1', NULL, 10, 0, 3, TRUE),
  ('10000000-0000-0000-0000-000000000004', 'Technology', '💻', 'B1', NULL, 12, 0, 4, TRUE),
  ('10000000-0000-0000-0000-000000000005', 'Business', '💼', 'B1', NULL, 12, 1, 5, TRUE);

INSERT INTO flashcards (id, topic_id, word, part_of_speech, pronunciation, meaning, example, example_translation, sort_order) VALUES
  ('30000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 'beautiful', 'adj.', '/ˈbjuːtɪfl/', 'đẹp, xinh đẹp', 'She is a beautiful girl.', 'Cô ấy là một cô gái xinh đẹp.', 1),
  ('30000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000005', 'opportunity', 'n.', '/ˌɒpəˈtjuːnəti/', 'cơ hội', 'This is a great opportunity for you.', 'Đây là một cơ hội tuyệt vời cho bạn.', 2);

INSERT INTO grammar_lessons (id, title, structure, icon_name, level, cover_color, estimated_minutes, sort_order, is_published) VALUES
  ('20000000-0000-0000-0000-000000000001', 'Present Simple', 'S + V(s/es)', 'account_tree', 'A1', 4292984551, 12, 1, TRUE),
  ('20000000-0000-0000-0000-000000000002', 'Present Continuous', 'S + am/is/are + V-ing', 'access_alarm', 'A1', NULL, 10, 2, TRUE),
  ('20000000-0000-0000-0000-000000000003', 'Past Simple', 'S + V2/V-ed', 'history_edu', 'A2', NULL, 10, 3, TRUE),
  ('20000000-0000-0000-0000-000000000004', 'Present Perfect', 'S + have/has + V3/V-ed', 'verified_user', 'A2', NULL, 12, 4, TRUE),
  ('20000000-0000-0000-0000-000000000005', 'Conditional', 'If + S + V(hiện tại), S + will + V', 'alt_route', 'B1', NULL, 15, 5, TRUE);

INSERT INTO grammar_examples (id, grammar_lesson_id, sentence, translation, highlight, sort_order) VALUES
  ('21000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'She goes to school every day.', 'Cô ấy đi học mỗi ngày.', 'goes', 1),
  ('21000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000001', 'The sun rises in the east.', 'Mặt trời mọc ở hướng đông.', 'rises', 2),
  ('21000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000002', 'She is doing her homework now.', 'Bây giờ cô ấy đang làm bài tập.', 'is doing', 1),
  ('21000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000002', 'They are playing football.', 'Họ đang chơi bóng đá.', 'are playing', 2),
  ('21000000-0000-0000-0000-000000000005', '20000000-0000-0000-0000-000000000003', 'I went to the store yesterday.', 'Hôm qua tôi đã đi đến cửa hàng.', 'went', 1),
  ('21000000-0000-0000-0000-000000000006', '20000000-0000-0000-0000-000000000004', 'I have finished my homework.', 'Tôi đã làm xong bài tập.', 'have finished', 1),
  ('21000000-0000-0000-0000-000000000007', '20000000-0000-0000-0000-000000000005', 'If it rains, I will stay at home.', 'Nếu trời mưa, tôi sẽ ở nhà.', 'If it rains', 1);

-- Quiz của topic Daily Life (dữ liệu từ MockData.mockReviewData)
INSERT INTO quizzes (id, title, quiz_type, topic_id, time_limit_seconds, pass_score_percent, is_published) VALUES
  ('40000000-0000-0000-0000-000000000001', 'Daily Life Quiz', 'TOPIC', '10000000-0000-0000-0000-000000000001', 600, 70, TRUE);

INSERT INTO quiz_questions (id, quiz_id, question_text, correct_option_index, explanation, sort_order) VALUES
  ('41000000-0000-0000-0000-000000000001', '40000000-0000-0000-0000-000000000001', 'She ______ her homework now.', 0, 'Câu ở thì hiện tại tiếp diễn, nên dùng "is doing".', 1),
  ('41000000-0000-0000-0000-000000000002', '40000000-0000-0000-0000-000000000001', 'The weather is very ______ today.', 3, 'Sau "is" (thời tiết) ta dùng tính từ, nên đáp án đúng là "nice".', 2),
  ('41000000-0000-0000-0000-000000000003', '40000000-0000-0000-0000-000000000001', 'I ______ to the store yesterday.', 0, 'Câu ở thì quá khứ đơn, dấu hiệu "yesterday" nên dùng "went".', 3);

INSERT INTO quiz_question_options (question_id, option_index, option_text) VALUES
  ('41000000-0000-0000-0000-000000000001', 0, 'is doing'),
  ('41000000-0000-0000-0000-000000000001', 1, 'does'),
  ('41000000-0000-0000-0000-000000000001', 2, 'did'),
  ('41000000-0000-0000-0000-000000000001', 3, 'was doing'),
  ('41000000-0000-0000-0000-000000000002', 0, 'good'),
  ('41000000-0000-0000-0000-000000000002', 1, 'well'),
  ('41000000-0000-0000-0000-000000000002', 2, 'bad'),
  ('41000000-0000-0000-0000-000000000002', 3, 'nice'),
  ('41000000-0000-0000-0000-000000000003', 0, 'went'),
  ('41000000-0000-0000-0000-000000000003', 1, 'go'),
  ('41000000-0000-0000-0000-000000000003', 2, 'goes'),
  ('41000000-0000-0000-0000-000000000003', 3, 'going');

INSERT INTO quest_definitions (id, code, title, quest_type, frequency, target_value, xp_reward, icon_name, sort_order) VALUES
  ('50000000-0000-0000-0000-000000000001', 'DAILY_LEARN_20_WORDS', 'Học 20 Flashcard mới', 'LEARN_WORDS', 'DAILY', 20, 50, 'style', 1),
  ('50000000-0000-0000-0000-000000000002', 'DAILY_PERFECT_QUIZ', 'Đạt 100% 1 bài kiểm tra', 'PERFECT_QUIZ', 'DAILY', 1, 100, 'fact_check', 2),
  ('50000000-0000-0000-0000-000000000003', 'DAILY_KEEP_STREAK', 'Duy trì Streak', 'KEEP_STREAK', 'DAILY', 1, 20, 'local_fire_department', 3);

INSERT INTO reward_items (id, code, name, item_type, xp_cost, border_colors, required_rank, rank_board, sort_order) VALUES
  ('60000000-0000-0000-0000-000000000001', 'BORDER_TAN_BINH', 'Tân binh', 'BORDER', 0, '[4293060848, 4291548641]', 0, 'XP', 1),
  ('60000000-0000-0000-0000-000000000002', 'BORDER_HOA_THAN', 'Hỏa thần', 'BORDER', 500, '[4294921551, 4294933061, 4294945088]', 0, 'XP', 2),
  ('60000000-0000-0000-0000-000000000003', 'BORDER_TINH_TU', 'Tinh tú', 'BORDER', 1500, '[4285673169, 4289953771, 4283637163]', 0, 'XP', 3),
  ('60000000-0000-0000-0000-000000000004', 'BORDER_VUA_TRO_CHOI', 'Vua Trò Chơi', 'BORDER', 3000, '[4294618388, 4294960527, 4294609942]', 3, 'XP', 4);
