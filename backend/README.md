# flash-backend

REST API cho AdvancedMobile_Flash — Spring Boot 2.7.18, MySQL 8, Flyway, Swagger (OpenAPI 3).
Thiết kế: [`../docs/DATA_ARCHITECTURE.md`](../docs/DATA_ARCHITECTURE.md) · Lộ trình: [`../docs/IMPLEMENTATION_PLAN.md`](../docs/IMPLEMENTATION_PLAN.md)

## Chạy local

```bash
# 1. MySQL (từ thư mục gốc repo) - mở ở cổng 3307
docker compose up -d mysql

# 2. Backend (không cần cài Maven, wrapper tự tải)
cd backend
./mvnw spring-boot:run        # Windows: mvnw.cmd spring-boot:run
```

- Health: <http://localhost:8080/v1/health>
- Swagger UI: <http://localhost:8080/swagger-ui.html>

Khi khởi động, Flyway tự chạy `V1__init.sql` (schema) và `V2__seed_content.sql` (dữ liệu mẫu từ `mock_data.dart`), sau đó Hibernate `validate` kiểm tra mọi entity khớp schema.

## Biến môi trường

| Biến | Mặc định |
|---|---|
| `DB_HOST` / `DB_PORT` / `DB_NAME` | `localhost` / `3307` / `flash_db` |
| `DB_USERNAME` / `DB_PASSWORD` | `flash` / `flash` |
| `SERVER_PORT` | `8080` |
| `JWT_SECRET` | giá trị dev, **bắt buộc đổi ở production** (tối thiểu 32 ký tự) |
| `ADMIN_EMAIL` / `ADMIN_PASSWORD` | trống; đặt cả hai thì lần khởi động đầu sẽ tạo tài khoản ADMIN |
| `GOOGLE_CLIENT_IDS` | trống (Google Sign-In bị tắt); các OAuth client id cách nhau bằng dấu phẩy |
| `SPRING_MAIL_HOST` / `_PORT` / `_USERNAME` / `_PASSWORD` | trống: OTP quên mật khẩu chỉ in ra log |
| `MAIL_FROM` | `no-reply@flash.local` |
| `AUTH_RATE_LIMIT_PER_MINUTE` | `20` request/phút cho mỗi (IP, endpoint) `/v1/auth/**` |

## Test

```bash
./mvnw test     # cần Docker đang chạy: Testcontainers tự bật MySQL 8 riêng cho test
```

Test tích hợp chạy trên MySQL thật nên kiểm tra luôn Flyway và Hibernate `validate`.

> Thử API bằng `curl` trên Windows: tiếng Việt trong `-d '...'` bị đổi thành `?` do codepage của dòng lệnh.
> Ghi body ra file UTF-8 rồi gửi bằng `--data-binary @body.json`, hoặc dùng Swagger UI.

## Quy ước

- Đổi schema: sửa `docs/sql/server_mysql.sql` **và** thêm migration mới `V3__...sql`. Không sửa migration đã chạy.
- Entity map cột kiểu `CHAR(36)` sang `UUID` (`@Type(type = "uuid-char")`, `columnDefinition = "char"`). Các cột `ENUM`, `TINYINT`, `SMALLINT`, `TEXT`, `JSON`, `DECIMAL` cũng cần `columnDefinition` để `ddl-auto: validate` khớp.
- `created_at` / `updated_at` do MySQL tự điền (`insertable = false, updatable = false`).
- Seed dùng UUID cố định theo tiền tố: `10..` topics, `20..` grammar, `30..` flashcards, `40..` quizzes, `50..` quests, `60..` reward items.
- Chạy được trên JDK 17–24 (`pom.xml` đã nâng Lombok và ByteBuddy cho JDK mới).
