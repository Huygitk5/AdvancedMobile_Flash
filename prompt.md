# BỐI CẢNH & VAI TRÒ
Bạn là một **Principal Mobile System Architect & Senior Database Designer**. 
Tôi đang phát triển một ứng dụng học từ vựng và ngữ pháp tiếng Anh qua thẻ ghi nhớ (Flashcard) bằng Flutter, có tên là **AdvancedMobile_Flash**.

Hiện tại, ứng dụng đã hoàn thiện giao diện người dùng (UI) và các Dart Models cơ bản kèm Mock Data trong thư mục `lib/`. Dự án đang cần thiết kế kiến trúc dữ liệu hoàn chỉnh gồm:
1. **Hệ thống Database phía Server** (quan hệ RDBMS - PostgreSQL / MySQL).
2. **Hệ thống Local Database phía Client** (SQLite / Drift / Sqflite) hỗ trợ **Offline-First** (người dùng vẫn lật thẻ học từ, ghi chú, làm bài kiểm tra khi mất mạng và tự động đồng bộ khi có kết nối).
3. **Chiến lược Local Key-Value Storage** (Flutter Secure Storage, Shared Preferences).
4. **Chiến lược đồng bộ hóa dữ liệu (Data Synchronization & Conflict Resolution)** giữa Client và Server.
5. **Đặc tả danh mục RESTful API Endpoints**.

---

# HIỆN TRẠNG CODEBASE (INVENTORY)
Để bạn không cần đoán định, đây là toàn bộ cấu trúc các Model và Màn hình hiện có trong Flutter:

### 1. Các màn hình UI chính:
- **Xác thực (Auth)**: `LoginScreen`, `RegisterScreen`, `ForgotPasswordScreen` (hỗ trợ Email/Password và Google Sign-In).
- **Trang chủ (HomeScreen)**: Hiển thị Streak hiện tại, tiến độ học ngày (3/5 bài), bài học tiếp tục, danh mục Từ vựng/Ngữ pháp, gợi ý bài học, thử thách hôm nay, lối tắt Leaderboard và Dialog nhắc nhở giờ học.
- **Học tập (TopicScreen & GrammarDetailScreen)**: 
  - Tab Từ vựng: Danh sách chủ đề (`Topic`), tìm kiếm, bộ lọc (Tất cả / Đang học / Hoàn thành).
  - Tab Ngữ pháp: Danh sách chủ điểm (`Grammar`), cấu trúc (VD: `S + am/is/are + V-ing`), ví dụ minh họa và nút chuyển sang bài tập.
- **Luyện thẻ (FlashcardScreen)**:
  - Thẻ 3D lật mặt trước/sau (từ, phát âm, từ loại, nghĩa, câu ví dụ).
  - Nút đánh giá trí nhớ SRS: **"Again" (Chưa nhớ)** và **"Know" (Đã nhớ)**.
  - Chức năng lưu **Ghi chú cá nhân (Personal Note)** riêng cho từng từ.
  - BottomSheet chi tiết từ vựng + Nút **"Thêm vào danh sách từ yêu thích / Bookmark"**.
- **Kiểm tra (QuizScreen, QuizResultScreen, QuizReviewScreen)**:
  - Câu hỏi trắc nghiệm 4 đáp án (A, B, C, D), tính thời gian hoàn thành (giây).
  - Màn hình kết quả: Số câu đúng/sai, danh sách câu hỏi sai để làm lại.
  - Màn hình Review: Giải thích chi tiết từng câu kèm đáp án user đã chọn.
- **Nhiệm vụ & Thử thách (ChallengeScreen)**: Thẻ tổng điểm XP, danh sách nhiệm vụ (`Quest`) với tiến độ (VD: 12/20 từ), nút "Nhận thưởng" (+XP, rung haptic).
- **Cửa hàng & Hồ sơ (ShopScreen & ProfileScreen)**:
  - Shop: Dùng XP mua vật phẩm (`RewardItem` như viền avatar gradient, avatar). Một số vật phẩm yêu cầu thứ hạng cao trên BXH (VD: Top 3).
  - Profile: Đổi câu châm ngôn (`slogan`), xem thống kê XP, từ đã học, trang bị viền từ kho đồ (`UserInventory`).
- **Bảng xếp hạng (LeaderboardScreen)**: Top 10 theo 2 Tab: **Tổng điểm XP (totalLifetimeXp)** và **Chuỗi Streak (longestStreak)**.
- **Tiến độ học (ProgressScreen)**: Biểu đồ cột số từ học theo Tuần/Tháng/Tất cả (`DailyStatistic`), tỷ lệ chính xác (Accuracy), chuỗi streak.
- **Cài đặt (SettingsScreen)**: Bật/tắt thông báo, âm thanh, chế độ tối (Dark mode), ngôn ngữ, đổi mật khẩu.

### 2. Các Model Dart hiện tại:
- `UserModel`: id, fullName, email, level, currentXp, targetXp, streakDays, totalWordsLearned, completedLessons, totalLifetimeXp, longestStreak, slogan.
- `Topic`: id, title, totalWords, progress, iconPath.
- `Flashcard`: id, topicId, word, partOfSpeech, pronunciation, meaning, example, exampleTranslation, note.
- `Grammar`: id, title, progress, status, iconName.
- `Lesson`: id, title, type (vocabulary/grammar), level, progress, itemCounts, estimatedTime, imageBg.
- `QuizQuestion`: id, topicId, questionText, options (List 4), correctAnswerIndex.
- `QuizResult`: id, userId, topicId, correctAnswers, wrongAnswers, timeTakenSeconds, wrongQuestionIds.
- `QuizReviewItem`: id, question, options, correctIndex, userIndex, explanation.
- `Quest`: id, title, current, target, xp, isClaimed, icon.
- `RewardItem`: id, name, type (border/avatar), xpCost, borderColors (hex codes), requiredRank, isUnlocked, isEquipped.
- `UserInventory`: id, userId, rewardItemId, isEquipped, unlockedAt.
- `DailyStatistic`: id, userId, date, wordsLearned, xpGained.

---

# NHIỆM VỤ YÊU CẦU CHO AI

Hãy thực hiện phân tích và thiết kế toàn diện theo 6 phần chi tiết sau:

### PHẦN 1: BẢN ĐỒ THỰC THỂ & MỐI QUAN HỆ (DOMAIN ENTITY RELATIONSHIP)
1. Liệt kê toàn bộ các Thực thể (Entities) cần thiết cho hệ thống, phân chia theo các Domain:
   - *Auth & Identity Domain*
   - *Learning Content Domain* (Topics, Flashcards, Grammar Lessons, Grammar Examples, Quizzes, Questions)
   - *User Progress & SRS Domain* (Tiến độ theo Topic/Grammar, Lịch sử lật Flashcard theo Spaced Repetition, Ghi chú từ, Bookmark từ, Lịch sử làm Quiz)
   - *Gamification & Economy Domain* (XP, Quests/Nhiệm vụ hàng ngày, Cửa hàng vật phẩm, Kho đồ, Bảng xếp hạng)
   - *Activity & Tracking Domain* (Daily Statistics, Streak Tracking)
2. Vẽ sơ đồ quan hệ Mermaid ERD (`erDiagram`) thể hiện rõ quan hệ 1-1, 1-n, n-n giữa các bảng.

### PHẦN 2: THIẾT KẾ CƠ SỞ DỮ LIỆU PHÍA SERVER (SERVER-SIDE DATABASE SCHEMA)
1. Cung cấp câu lệnh tạo bảng SQL DDL (PostgreSQL hoặc MySQL) hoàn chỉnh, chuẩn hóa (ít nhất 3NF).
2. Yêu cầu chi tiết cho từng bảng:
   - Tên bảng dạng snake_case số nhiều (VD: `users`, `flashcards`, `user_flashcard_progress`).
   - Kiểu dữ liệu chính xác (UUID/BIGINT làm Primary Key, VARCHAR, TEXT, INT, BOOLEAN, TIMESTAMP WITH TIME ZONE, JSONB cho màu sắc hoặc options nếu phù hợp).
   - Ràng buộc toàn vẹn: Primary Key, Foreign Key (kèm `ON DELETE CASCADE` hợp lý), NOT NULL, UNIQUE, DEFAULT value.
   - Định nghĩa các chỉ mục (Indexes) quan trọng cho hiệu năng: Tìm kiếm từ khóa, lọc theo `user_id`, lọc tiến độ, sort bảng xếp hạng (Leaderboard XP/Streak).
3. Đảm bảo có các trường phục vụ kiểm soát dữ liệu: `created_at`, `updated_at`, `deleted_at` (soft delete nếu cần), và versioning (`version` hoặc `client_updated_at`) phục vụ đồng bộ.

### PHẦN 3: THIẾT KẾ LOCAL DATABASE PHÍA CLIENT (SQLITE / DRIFT)
1. Lập danh sách các bảng cần lưu cục bộ trên thiết bị SQLite và lý giải **tại sao** cần lưu (ví dụ: dữ liệu tĩnh cần cache để học offline, dữ liệu tương tác user cần lưu tức thời).
2. Cung cấp lược đồ DDL SQLite cho Client:
   - Các trường cờ đồng bộ hóa bắt buộc trên các bảng do người dùng tạo/sửa:
     - `is_dirty` (INTEGER 0/1: bản ghi đã bị sửa ở local nhưng chưa gửi lên server)
     - `sync_status` (TEXT / INT: 'synced', 'pending_create', 'pending_update', 'pending_delete')
     - `last_synced_at` (INTEGER timestamp)
   - Thiết kế bảng `sync_queue` (hàng đợi ngoại tuyến) để ghi nhận các hành động: hoàn thành bài học, trả lời flashcard ("Again" / "Know"), nhận XP quest, sửa slogan, mua đồ shop khi thiết bị đang Offline.
3. So sánh ngắn gọn giữa các giải pháp lưu trữ SQLite trong Flutter: `sqflite` (thuần) vs `drift` (type-safe reactive) vs `floor`, và đưa ra khuyến nghị phù hợp nhất cho dự án này.

### PHẦN 4: THIẾT KẾ LOCAL STORAGE & KEY-VALUE (PREFERENCES & SECURE STORAGE)
1. Xác định chính xác những gì **KHÔNG** nên đưa vào SQLite mà nên lưu trong Key-Value:
   - **Flutter Secure Storage**: Lưu trữ an toàn `access_token`, `refresh_token`, `user_id`.
   - **SharedPreferences**: Cài đặt ứng dụng (`is_dark_mode`, `is_sound_enabled`, `is_notification_enabled`, `app_language`, `daily_reminder_time`, `last_synced_timestamp`).
2. Định nghĩa cấu trúc Key - Type - Mục đích cụ thể dưới dạng bảng tra cứu.

### PHẦN 5: CHIẾN LƯỢC ĐỒNG BỘ OFFLINE-FIRST & XỬ LÝ XUNG ĐỘT (SYNC STRATEGY)
1. **Quy trình đọc (Read Flow)**: Luồng dữ liệu Local-First (UI đọc từ SQLite -> Hiển thị ngay lập tức -> Gửi request ngầm lên Server -> Cập nhật SQLite -> UI reactive tự cập nhật).
2. **Quy trình ghi (Write Flow)**: Khi người dùng bấm "Know", sửa ghi chú từ vựng, hoặc nhận quest:
   - Ghi vào SQLite + Đánh dấu `is_dirty = 1`.
   - Nếu Online: Bắn API đồng bộ ngay.
   - Nếu Offline: Đẩy vào bảng `sync_queue` để chờ kết nối mạng.
3. **Chiến lược giải quyết xung đột (Conflict Resolution)**:
   - Đối với Ghi chú từ vựng (`note`): Áp dụng *Last-Write-Wins* (dựa trên timestamp) hay merge?
   - Đối với Điểm XP và Chuỗi Streak: Cơ chế Server-authoritative để chống gian lận (cheat sửa SQLite ở client để tăng 99999 XP).
   - Đối với Mua đồ trong Shop: Bắt buộc xác thực trên Server khi có mạng hay cho phép mua offline?

### PHẦN 6: DANH MỤC API CONTRACT (RESTFUL API SPECIFICATIONS)
Liệt kê danh sách các Endpoints chuẩn RESTful kèm Method, URL, Mô tả ngắn, Body tóm tắt và Response status code:
- Nhóm `/api/v1/auth`: Đăng ký, Đăng nhập, Google Login, Quên mật khẩu, Refresh Token.
- Nhóm `/api/v1/users`: Lấy thông tin user hiện tại, Cập nhật Profile (slogan, level), Đổi mật khẩu.
- Nhóm `/api/v1/topics` & `/api/v1/flashcards`: Lấy danh sách Topic, Chi tiết từ vựng theo Topic, Bookmark từ, Ghi chú từ vựng.
- Nhóm `/api/v1/grammar`: Lấy bài học ngữ pháp, nội dung chi tiết.
- Nhóm `/api/v1/quizzes`: Lấy đề bài, Nộp bài kiểm tra (`QuizResult`), Lấy lịch sử review bài làm.
- Nhóm `/api/v1/quests`: Danh sách nhiệm vụ hôm nay, API Claim nhận thưởng XP.
- Nhóm `/api/v1/shop`: Danh mục vật phẩm, Mua vật phẩm, Trang bị/Tháo trang bị viền/avatar.
- Nhóm `/api/v1/leaderboard`: Lấy Top 10 XP, Top 10 Streak.
- Nhóm `/api/v1/sync`: Batch sync endpoint (Client gửi danh sách các hành động offline lên một lần để Server xử lý transactional).

---

# TIÊU CHUẨN ĐẦU RA
- Trình bày mạch lạc, có cấu trúc rõ ràng với Markdown.
- Mã nguồn SQL DDL phải sẵn sàng chạy được (syntactically valid).
- Các tên trường phải có tính nhất quán cao giữa Server, Local SQLite và Dart Model (kèm bảng map tên trường nếu có sự khác biệt giữa snake_case và camelCase).
  
- Local DB: drift cho phép type-safe trong Dart, hỗ trợ Stream tự động cập nhật UI khi database SQLite thay đổi (cực kỳ thích hợp cho trạng thái "Again/Know" của Flashcard)
  
- Secure Token: flutter_secure_storage để lưu Access/Refresh Token.Secure Token: flutter_secure_storage để lưu Access/Refresh Token.
  
- Settings: shared_preferences để lưu cài đặt âm thanh, rung, reminder dialog.

- Backend: Spring Boot 2.7 và SWAGGER v3
 
- Database: MySQL
  
- API endpoint format: /v1/users, /v1/users/get/??, /v1/users/create,  /v1/users/update,  /v1/users/delete