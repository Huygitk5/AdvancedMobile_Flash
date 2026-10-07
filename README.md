# Flash English

Ứng dụng học **từ vựng** và **ngữ pháp** tiếng Anh bằng thẻ ghi nhớ (flashcard), có lặp lại ngắt quãng (SRS), bài kiểm tra, nhiệm vụ hằng ngày, bảng xếp hạng và cửa hàng đổi thưởng bằng XP.
App viết bằng **Flutter**, hoạt động **offline-first**; backend là **Spring Boot + MySQL** (thư mục [`backend/`](backend/README.md)).

> Đồ án cuối kỳ môn Lập trình di động nâng cao.

## Tính năng

**Người học**

- **Từ vựng**: 18 chủ đề / 530 từ, mỗi từ có phiên âm, loại từ, nghĩa, ví dụ và đọc to bằng TTS. Thẻ lật 3D, chấm *Đã nhớ* / *Chưa nhớ*.
- **Ghi nhớ ngắt quãng (Leitner)**: 6 hộp, ôn lại sau 1 → 3 → 7 → 14 → 30 ngày; bấm *Chưa nhớ* thì lùi 2 hộp và ôn lại sau 10 phút.
- **Ngữ pháp**: 40 chủ điểm A1–C1 gồm cấu trúc, giải thích, ví dụ có tô đậm cụm từ cần chú ý.
- **Kiểm tra**: trắc nghiệm 4 đáp án, tính giờ, xem lại câu sai kèm giải thích.
- **Cá nhân hoá**: ghi chú riêng cho từng từ, lưu từ yêu thích, tìm kiếm chủ đề / từ vựng / ngữ pháp.
- **Gamification**: XP, streak, nhiệm vụ ngày / tuần, bảng xếp hạng (XP, streak) kèm slogan, cửa hàng viền và avatar, kho đồ.
- **Tiến độ**: biểu đồ số từ đã học, XP, độ chính xác quiz theo tuần / tháng / năm / khoảng tuỳ chọn.
- **Widget màn hình chính (Android)**: xem nhanh thẻ từ vựng ngay trên launcher, không cần mở app. Xem [`docs/HOME_WIDGET.md`](docs/HOME_WIDGET.md).
- **Khác**: nhắc giờ học, chế độ tối, Tiếng Việt / English, gửi phản hồi về từ vựng / ngữ pháp / bài kiểm tra.

**Quản trị viên** (đăng nhập ở tab *Quản trị viên*): tổng quan hệ thống, quản lý nội dung (chủ đề, từ vựng, ngữ pháp, ví dụ, bài kiểm tra, câu hỏi), quản lý học viên, kinh tế (nhiệm vụ, vật phẩm cửa hàng) và xử lý phản hồi.

## Công nghệ

| Thành phần | Công nghệ |
|---|---|
| App | Flutter (Dart `^3.13`), Riverpod, Drift (SQLite), Dio, workmanager, home_widget, flutter_tts, google_sign_in |
| Lưu trữ cục bộ | SQLite qua Drift (dữ liệu học), `flutter_secure_storage` (token), `shared_preferences` (cài đặt) |
| Backend | Spring Boot 2.7.18, Java 17, Spring Security + JWT, JPA/Hibernate, Flyway, Swagger (springdoc) |
| CSDL | MySQL 8 |
| Kiểm thử | `flutter_test`, mocktail · JUnit 5, Testcontainers |

## Kiến trúc

```
┌──────────────── Flutter app ────────────────┐            ┌──────────── Backend ────────────┐
│ screens ─► providers (Riverpod)             │            │ Controller ─► Service           │
│               │                             │            │                  │              │
│        repositories ──► Drift / SQLite      │  /v1/sync  │ JWT + rate limit │  JPA         │
│               │            (đọc/ghi local)  │ ◄────────► │                  ▼              │
│          sync_queue (outbox)                │  push/pull │               MySQL 8           │
│               │                             │            │         (Flyway quản lý schema) │
│          SyncWorker ──► Dio ApiClient       │            └─────────────────────────────────┘
└─────────────────────────────────────────────┘
```

- **Offline-first**: mọi thao tác (chấm thẻ, ghi chú, bookmark, nộp quiz, hoàn thành bài) ghi vào SQLite và hàng đợi `sync_queue` trong cùng một transaction, nên dùng được khi mất mạng.
- **Đồng bộ**: `SyncWorker` đẩy hàng đợi lên `/v1/sync/push` theo lô 50 thao tác, sau đó kéo thay đổi mới về (`/v1/sync/pull`, theo con trỏ `updated_at`). Đồng bộ chạy khi mở app, khi quay lại foreground, khi có mạng trở lại và mỗi 15 phút ở nền (Android).
- **Server là nguồn chân lý** cho XP, streak, kho đồ, chấm quiz và trạng thái SRS. Client chỉ gửi *sự kiện* ("đã bấm Nhớ lúc t"), không gửi *con số*. Mỗi thao tác có `op_id` nên gửi lại không bị cộng XP hai lần.
- **Xác thực**: access token (15 phút) + refresh token xoay vòng (30 ngày), đăng ký / đổi mật khẩu bằng OTP email, đăng nhập Google, giới hạn tốc độ cho `/v1/auth/**` và `/v1/sync/**`.

Chi tiết thiết kế dữ liệu, ERD và chiến lược xung đột: [`docs/DATA_ARCHITECTURE.md`](docs/DATA_ARCHITECTURE.md). Lộ trình triển khai: [`docs/IMPLEMENTATION_PLAN.md`](docs/IMPLEMENTATION_PLAN.md).

## Cấu trúc thư mục

```
.
├── lib/
│   ├── core/            cấu hình, theme, i18n (tr + l10n_en), TTS
│   ├── data/
│   │   ├── local/       Drift: schema.drift, database, DAO
│   │   ├── remote/      Dio ApiClient, interceptor token, các API
│   │   ├── repositories/
│   │   ├── storage/     SecureStore, AppPrefs
│   │   ├── sync/        SyncWorker, PullService, SRS, chạy nền
│   │   └── widget/      dữ liệu cho widget màn hình chính
│   ├── models/          model dùng trong UI
│   ├── providers/       Riverpod providers
│   ├── screens/         auth, home, vocabulary, flashcard, grammar, quiz,
│   │                    challenge, progress, leaderboard, profile, admin, splash
│   └── widgets/         thành phần UI dùng chung
├── android/             Android runner + widget native (Java)
├── backend/             Spring Boot API (xem backend/README.md)
├── docs/                kiến trúc dữ liệu, kế hoạch, widget, DDL (sql/)
├── test/                kiểm thử Flutter
└── docker-compose.yml   MySQL 8 cho môi trường dev
```

## Chạy thử

### Yêu cầu

- Flutter SDK (Dart `^3.13.1`), Android Studio / emulator hoặc điện thoại Android.
- JDK 17+ và MySQL 8 (hoặc Docker) nếu muốn tự chạy backend. Maven đã có sẵn qua `mvnw`.
- Windows: bật *Developer Mode* để build plugin (`start ms-settings:developers`).

### 1. Backend (tuỳ chọn)

Mặc định app trỏ tới server đã triển khai `https://flash.devflux.io.vn`, nên có thể bỏ qua bước này. Muốn chạy backend trên máy mình:

```bash
# MySQL cài sẵn ở cổng 3306 (root/root) — DB flash_db tự tạo, Flyway tự nạp dữ liệu học.
# Hoặc dùng Docker (cổng 3307):  docker compose up -d mysql
#   rồi đặt DB_PORT=3307 DB_USERNAME=flash DB_PASSWORD=flash

cd backend
ADMIN_EMAIL=admin@flash.local ADMIN_PASSWORD=Admin@12345 ./mvnw spring-boot:run   # Windows: mvnw.cmd spring-boot:run
```

- Health: <http://localhost:8080/v1/health>
- Swagger UI: <http://localhost:8080/swagger-ui.html>
- Chưa cấu hình SMTP thì mã OTP (đăng ký, đổi / quên mật khẩu) được **in ra console** của backend.
  Muốn bỏ qua OTP khi phát triển: `REQUIRE_EMAIL_VERIFICATION=false`.

Biến môi trường, cấu hình SMTP và Google Sign-In: xem [`backend/README.md`](backend/README.md).

### 2. App Flutter

```bash
flutter pub get
flutter run                                                        # dùng server mặc định
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080        # emulator Android -> backend trên máy bạn
flutter run --dart-define=API_BASE_URL=http://192.168.1.5:8080     # điện thoại thật -> IP LAN của máy chạy backend
```

Thứ tự ưu tiên địa chỉ máy chủ: **giá trị nhập trong app** > `--dart-define=API_BASE_URL` > mặc định.
Đổi trong app bằng cách giữ lâu vào logo ở màn Chào mừng, hoặc *Cài đặt → Địa chỉ máy chủ*.

Lưu ý khi dùng backend cục bộ trên điện thoại thật: cùng Wi-Fi với máy chạy backend, và Windows Firewall phải cho phép cổng 8080. Bản debug cho phép `http://`; bản release cần `https`.

### 3. Tài khoản

- **Người học**: đăng ký trong app (nhập OTP gửi qua email, hoặc xem OTP ở console backend khi chưa có SMTP) hoặc đăng nhập Google.
- **Quản trị viên**: đăng nhập ở tab *Quản trị viên* bằng `ADMIN_EMAIL` / `ADMIN_PASSWORD` đã đặt khi chạy backend (tài khoản được tạo ở lần khởi động đầu).

### Đăng nhập Google (tuỳ chọn)

Tạo OAuth client **Web** và **Android** (package `com.example.flash` + SHA-1 keystore) trên Google Cloud Console, đặt `GOOGLE_CLIENT_IDS` cho backend và chạy app với `--dart-define=GOOGLE_SERVER_CLIENT_ID=<web-client-id>.apps.googleusercontent.com`. Từng bước ở mục "Đăng nhập Google" trong [`backend/README.md`](backend/README.md).

## Kiểm thử

```bash
flutter analyze && flutter test        # đơn vị + kiểm tra layout 320/360/411px, cỡ chữ 1.15x, dark mode
cd backend && ./mvnw test              # cần Docker đang chạy (Testcontainers tự bật MySQL 8)

# Đầu-cuối với backend thật (bật REQUIRE_EMAIL_VERIFICATION=true, chưa cấu hình SMTP):
flutter test test/live/live_backend_test.dart --dart-define=LIVE_API=http://localhost:8081 \
  --dart-define=BACKEND_LOG=<file log backend> --dart-define=ADMIN_EMAIL=... --dart-define=ADMIN_PASSWORD=...
```

## Ngôn ngữ giao diện

Tiếng Việt / English (*Cài đặt → Ngôn ngữ*). Chuỗi giao diện viết tiếng Việt trong code qua `tr('...')`, bản English nằm ở `lib/core/l10n_en.dart`; `test/l10n_test.dart` báo lỗi nếu có chuỗi chưa dịch.
Nội dung học (giải thích ngữ pháp, nghĩa từ) lấy từ server nên giữ nguyên.

## Phạm vi nền tảng

Mục tiêu chính là **Android**. Widget màn hình chính và đồng bộ nền (workmanager) chỉ có trên Android; các thư mục iOS / web / desktop là phần mặc định của Flutter và chưa được kiểm thử.

## Tài liệu

| Tài liệu | Nội dung |
|---|---|
| [`backend/README.md`](backend/README.md) | Chạy backend, migration, OTP, Google Sign-In, biến môi trường, API feedback, quy ước |
| [`docs/DATA_ARCHITECTURE.md`](docs/DATA_ARCHITECTURE.md) | ERD, schema MySQL / SQLite, chiến lược đồng bộ, API contract |
| [`docs/IMPLEMENTATION_PLAN.md`](docs/IMPLEMENTATION_PLAN.md) | Các giai đoạn triển khai và điều kiện hoàn thành |
| [`docs/HOME_WIDGET.md`](docs/HOME_WIDGET.md) | Widget màn hình chính: kiến trúc, cấu hình, deep link, kiểm thử |
| [`docs/sql/`](docs/sql) | DDL chạy được cho server (`server_mysql.sql`) và client (`client_sqlite.sql`) |
