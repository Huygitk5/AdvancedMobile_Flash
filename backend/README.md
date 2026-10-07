# flash-backend

REST API cho AdvancedMobile_Flash — Spring Boot 2.7.18, MySQL 8, Flyway, Swagger (OpenAPI 3).
Thiết kế: [`../docs/DATA_ARCHITECTURE.md`](../docs/DATA_ARCHITECTURE.md) · Lộ trình: [`../docs/IMPLEMENTATION_PLAN.md`](../docs/IMPLEMENTATION_PLAN.md)

## Chạy local

```bash
# 1. MySQL: dùng MySQL cài sẵn trên máy (cổng 3306, root/root), DB flash_db tự được tạo.
#    Nếu muốn dùng Docker (cổng 3307) thì chạy thêm:
#      docker compose up -d mysql
#      rồi đặt DB_PORT=3307 DB_USERNAME=flash DB_PASSWORD=flash

# 2. Backend (không cần cài Maven, wrapper tự tải)
cd backend
./mvnw spring-boot:run        # Windows: mvnw.cmd spring-boot:run
```

- Health: <http://localhost:8080/v1/health>
- Swagger UI: <http://localhost:8080/swagger-ui.html>

Khi khởi động, Flyway tự chạy (theo thứ tự version) rồi Hibernate `validate` kiểm tra mọi entity khớp schema:

| Migration | Thư mục | Nội dung |
|---|---|---|
| `V1__init.sql` | `db/migration` | schema |
| `V2__seed_content.sql` | `db/migration` | seed nhỏ (5 chủ đề, 5 ngữ pháp...) dùng cho test tích hợp |
| `V3__otp_purpose_leaderboard.sql` | `db/migration` | OTP dùng chung nhiều mục đích, bảng xếp hạng có slogan và loại admin |
| `V4__seed_vocabulary_grammar.sql` | `db/seed` | bộ nội dung đầy đủ: **18 chủ đề / 530 từ vựng** (mỗi từ có câu hỏi kiểm tra, mỗi chủ đề chia thành các bài ~10 câu) và **40 chủ điểm ngữ pháp** A1-C1 (giải thích, cấu trúc, ví dụ, bài kiểm tra 6 câu) |
| `V5__feedback.sql` | `db/migration` | bảng `feedbacks`: phản hồi của user về từ vựng / ngữ pháp / bài kiểm tra (`item_id` đa hình, không có FK) |

`db/seed` chỉ được nạp khi chạy app (`spring.flyway.locations`), **không** nạp trong test tích hợp để các test có dữ liệu cố định. Bộ seed lớn được kiểm riêng bởi `SeedContentTest` (MySQL riêng).

## Xác thực email bằng OTP

Mặc định `REQUIRE_EMAIL_VERIFICATION=true`:

- `POST /v1/auth/register` tạo tài khoản `PENDING_VERIFY`, gửi OTP 6 số tới email, **chưa trả token** (`verificationRequired: true`).
- `POST /v1/auth/verify-email {email, otp}` kích hoạt tài khoản và đăng nhập luôn; `POST /v1/auth/resend-verification` gửi lại mã (cách nhau 60 giây).
- Đăng nhập khi chưa xác thực trả `403 EMAIL_NOT_VERIFIED` (và gửi lại OTP).
- Đổi mật khẩu: `POST /v1/users/change-password/otp` gửi mã tới email, rồi `PUT /v1/users/change-password` kèm `otp`.
- Quên mật khẩu: `forgot-password` + `reset-password` như trước.

Chưa cấu hình SMTP thì OTP chỉ **in ra log** của backend (`[DEV - chưa cấu hình SMTP] OTP EMAIL_VERIFY cho a@b.c: 123456`). Muốn gửi email thật, ví dụ Gmail (cần bật xác minh 2 bước và tạo *App Password*):

```bash
SPRING_MAIL_HOST=smtp.gmail.com SPRING_MAIL_PORT=587 \
SPRING_MAIL_USERNAME=ban@gmail.com SPRING_MAIL_PASSWORD=<app-password> MAIL_FROM=ban@gmail.com \
./mvnw spring-boot:run
```

Tắt xác thực email khi phát triển: `REQUIRE_EMAIL_VERIFICATION=false` (đăng ký xong có token ngay, đổi mật khẩu không cần OTP).

## Đăng nhập Google

1. Google Cloud Console -> APIs & Services -> Credentials: tạo OAuth client **Web** (dùng làm `serverClientId`) và client **Android** (package `com.example.flash` + SHA-1 của keystore: `keytool -list -v -keystore ~/.android/debug.keystore -storepass android`).
2. Backend: `GOOGLE_CLIENT_IDS=<web-client-id>.apps.googleusercontent.com` (nhiều id cách nhau bằng dấu phẩy).
3. App: chạy với `--dart-define=GOOGLE_SERVER_CLIENT_ID=<web-client-id>.apps.googleusercontent.com`.

## Biến môi trường

| Biến | Mặc định |
|---|---|
| `DB_HOST` / `DB_PORT` / `DB_NAME` | `localhost` / `3306` / `flash_db` |
| `DB_USERNAME` / `DB_PASSWORD` | `root` / `root` |
| `SERVER_PORT` | `8080` |
| `JWT_SECRET` | giá trị dev, **bắt buộc đổi ở production** (tối thiểu 32 ký tự) |
| `ADMIN_EMAIL` / `ADMIN_PASSWORD` | trống; đặt cả hai thì lần khởi động đầu sẽ tạo tài khoản ADMIN |
| `GOOGLE_CLIENT_IDS` | trống (Google Sign-In bị tắt); các OAuth client id cách nhau bằng dấu phẩy |
| `SPRING_MAIL_HOST` / `_PORT` / `_USERNAME` / `_PASSWORD` | trống: OTP chỉ in ra log |
| `REQUIRE_EMAIL_VERIFICATION` | `true`: đăng ký và đổi mật khẩu phải nhập OTP gửi qua email |
| `CORS_ALLOWED_ORIGINS` | `*` (API dùng Bearer token, không cookie); production nên liệt kê origin cụ thể |
| `MAIL_FROM` | `no-reply@flash.local` |
| `AUTH_RATE_LIMIT_PER_MINUTE` | `20` request/phút cho mỗi (IP, endpoint) `/v1/auth/**` |
| `SYNC_RATE_LIMIT_PER_MINUTE` | `30` request/phút cho mỗi user, tính chung `/v1/sync/**` |

## Feedback (phản hồi)

User gửi phản hồi về một từ vựng (`feedbackFor=1`), bài ngữ pháp (`2`) hoặc bài kiểm tra (`3`); admin xem và đánh dấu đã xem.

| API | Quyền | Mô tả |
|---|---|---|
| `POST /v1/feedbacks/create` `{feedbackFor, itemId, content}` | user | content trim, tối đa 1000 ký tự; item phải còn (chưa xoá mềm), nếu không `404` |
| `GET /v1/feedbacks/me?feedbackFor=&from=&to=&page=&size=` | user | của chính mình, mới nhất trước; `from`/`to` là ngày `yyyy-MM-dd` (gồm cả `to`) theo `users.timezone` |
| `GET /v1/feedbacks/me/summary` | user | `{flashcard, grammar, quiz}` |
| `PUT /v1/feedbacks/update/{id}` `{content}`, `DELETE /v1/feedbacks/delete/{id}` | chủ sở hữu | chỉ khi `is_viewed=false` (1 câu UPDATE/DELETE có điều kiện); đã xem -> `409 FEEDBACK_ALREADY_VIEWED`, không phải của mình -> `404` |
| `GET /v1/feedbacks?feedbackFor=&isViewed=&from=&to=&page=&size=` | ADMIN | của mọi user |
| `PUT /v1/feedbacks/{id}/viewed` `{isViewed}` | ADMIN | đánh dấu đã xem / chưa xem |

Item chỉ bị xoá mềm nên FK cascade không chạy: `FeedbackCleanup` xoá cứng feedback (bulk delete, cùng transaction) khi xoá flashcard / grammar (kèm quiz của nó) / quiz / topic (kèm flashcard và quiz của nó).

## Test

```bash
./mvnw test     # cần Docker đang chạy: Testcontainers tự bật MySQL 8 riêng cho test (87 test)
```

Test tích hợp chạy trên MySQL thật nên kiểm tra luôn Flyway và Hibernate `validate`.

> Thử API bằng `curl` trên Windows: tiếng Việt trong `-d '...'` bị đổi thành `?` do codepage của dòng lệnh.
> Ghi body ra file UTF-8 rồi gửi bằng `--data-binary @body.json`, hoặc dùng Swagger UI.

## Quy ước

- Đổi schema: sửa `docs/sql/server_mysql.sql` **và** thêm migration mới `V6__...sql` vào `db/migration`. Không sửa migration đã chạy.
- Nội dung học lớn thêm vào `db/seed`, không đặt trong `db/migration` (test tích hợp dựa vào seed nhỏ V2).
- Entity map cột kiểu `CHAR(36)` sang `UUID` (`@Type(type = "uuid-char")`, `columnDefinition = "char"`). Các cột `ENUM`, `TINYINT`, `SMALLINT`, `TEXT`, `JSON`, `DECIMAL` cũng cần `columnDefinition` để `ddl-auto: validate` khớp.
- `created_at` / `updated_at` do MySQL tự điền (`insertable = false, updatable = false`).
- Seed dùng UUID cố định theo tiền tố: `10..` topics, `20..` grammar, `21..` ví dụ ngữ pháp, `30..` flashcards, `40..` quizzes, `41..` câu hỏi, `50..` quests, `60..` reward items.
- XP do server tính (`XpService`): Know lần đầu trong ngày +2, từ chuyển sang "đã học" +5 (ngay lần Know đầu tiên), hoàn thành bài +10 (một lần/bài/ngày), quiz +2/câu đúng +10 nếu 100% (lần đầu trong ngày). "Bài học hoàn thành" chỉ tăng ở lần đầu hoàn thành mỗi bài.
- Chạy được trên JDK 17–24 (`pom.xml` đã nâng Lombok và ByteBuddy cho JDK mới).
