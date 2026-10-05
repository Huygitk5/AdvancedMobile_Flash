# Flash English (AdvancedMobile_Flash)

Ứng dụng học từ vựng và ngữ pháp tiếng Anh bằng thẻ ghi nhớ (Flutter) + backend Spring Boot / MySQL ở [`backend/`](backend/README.md).
Thiết kế dữ liệu: [`docs/DATA_ARCHITECTURE.md`](docs/DATA_ARCHITECTURE.md) · Lộ trình: [`docs/IMPLEMENTATION_PLAN.md`](docs/IMPLEMENTATION_PLAN.md)

## Chạy thử

1. **Backend** (MySQL cài sẵn ở cổng 3306, user `root` / mật khẩu `root`; DB `flash_db` tự tạo, Flyway tự nạp dữ liệu học):

   ```bash
   cd backend
   ADMIN_EMAIL=admin@flash.local ADMIN_PASSWORD=Admin@12345 ./mvnw spring-boot:run   # Windows: mvnw.cmd spring-boot:run
   ```

   Chưa cấu hình SMTP thì mã OTP (đăng ký, đổi/quên mật khẩu) được in ra console của backend.

2. **App Flutter** (Windows cần bật *Developer Mode* để build plugin: `start ms-settings:developers`):

   ```bash
   flutter pub get
   flutter run                                   # Android emulator tự dùng http://10.0.2.2:8080
   flutter run --dart-define=API_BASE_URL=http://192.168.1.5:8080   # điện thoại thật: IP LAN của máy chạy backend
   ```

   Địa chỉ máy chủ cũng đổi được trong app: giữ lâu vào logo ở màn Chào mừng, hoặc Cài đặt -> Địa chỉ máy chủ.
   Điện thoại thật phải cùng Wi-Fi với máy chạy backend và Windows Firewall phải cho phép cổng 8080.
   Bản debug cho phép `http://`; bản release cần https.

3. **Đăng nhập Google** (tuỳ chọn): xem mục "Đăng nhập Google" trong [`backend/README.md`](backend/README.md) rồi chạy app với `--dart-define=GOOGLE_SERVER_CLIENT_ID=...`.

Tài khoản quản trị: đăng nhập ở tab *Quản trị viên* bằng `ADMIN_EMAIL` / `ADMIN_PASSWORD` đã đặt khi chạy backend.

## Kiểm thử

```bash
flutter analyze && flutter test                  # đơn vị + kiểm tra layout 320/360/411px, cỡ chữ 1.15x, dark mode
cd backend && ./mvnw test                        # cần Docker (Testcontainers)

# Đầu-cuối với backend thật (bật REQUIRE_EMAIL_VERIFICATION=true, chưa cấu hình SMTP):
flutter test test/live/live_backend_test.dart --dart-define=LIVE_API=http://localhost:8081 \
  --dart-define=BACKEND_LOG=<file log backend> --dart-define=ADMIN_EMAIL=... --dart-define=ADMIN_PASSWORD=...
```

## Ngôn ngữ giao diện

Tiếng Việt / English (Cài đặt -> Ngôn ngữ). Chuỗi giao diện viết tiếng Việt trong code qua `tr('...')`, bản English nằm ở `lib/core/l10n_en.dart`;
`test/l10n_test.dart` báo lỗi nếu có chuỗi chưa dịch. Nội dung học (giải thích ngữ pháp, nghĩa từ) lấy từ server nên giữ nguyên.
