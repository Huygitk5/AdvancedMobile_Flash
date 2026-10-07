# Widget màn hình chính (Android)

Tài liệu này mô tả widget **đúng như code hiện tại** trên nhánh `feature/home-widget`. Nó thay cho các file nháp `HOME_WIDGET_GUIDE.md` và `HOME_WIDGET_TASK*.md`. Các file đó ghi lại những phương án đã thử qua từng bước, nhiều chỗ không còn đúng.

---

## 1. Widget làm gì

Widget vuông bo góc, mặc định 2×2 ô và kéo to được. Mỗi lần widget hiện **một thẻ flashcard** để người dùng xem nhanh từ vựng mà không cần mở app.

```
┌───────────────────────────┐
│ Flash English             │  ← chạm: mở app vào chủ đề của thẻ đang hiện
│ ┌───────────────────────┐ │
│ │      resilient        │ │  ← mặt trước: chỉ có từ
│ │     Chạm để lật       │ │     chạm → lật sang mặt sau
│ └───────────────────────┘ │
│   ‹        3/10        ›   │  ← đổi từ trước / sau (quay vòng)
└───────────────────────────┘

Mặt sau:  resilient
          adjective              (loại từ – ẩn nếu trống)
          /rɪˈzɪliənt/           (phiên âm)
          kiên cường, mau phục hồi   (nghĩa)
```

| Thao tác | Kết quả |
|---|---|
| Chạm vào thẻ | Lật qua lại giữa mặt trước và mặt sau |
| Bấm ‹ hoặc › | Sang từ trước hoặc từ sau, quay vòng ở hai đầu; thẻ tự úp lại mặt trước |
| Chạm tiêu đề "Flash English" | Mở app vào `FlashcardScreen` của chủ đề chứa thẻ đang hiện |
| Widget đang tắt | Hiện "Widget đang tắt – chạm để bật"; chạm vào thì mở màn cấu hình widget |
| Không có từ nào | Hiện "Không có từ nào"; chạm vào thì mở app |

Widget **chỉ để xem trước từ vựng**. Nó không chấm Nhớ/Chưa nhớ và **không ghi gì vào cơ sở dữ liệu** (xem mục 7).

---

## 2. Kiến trúc

Widget Android không chạy trong app. Launcher là bên vẽ widget, kể cả khi app đã tắt hẳn, nên lúc đó không có Flutter engine để vẽ giao diện Flutter. Vì vậy công việc được chia hai phía:

```
┌──────────────── App Flutter (Dart) ────────────────┐            ┌──────── Native (Java) ─────────┐
│ SQLite (Drift)                                     │            │ FlashWidgetProvider            │
│   │                                                │   ghi      │  - đọc JSON "cards"            │
│   ▼                                                │ ─────────► │  - vẽ RemoteViews              │
│ HomeWidgetService.refresh()                        │ SharedPrefs│  - ‹ ›: đổi w_index            │
│   - đọc cấu hình (AppPrefs)                        │ "HomeWidget│  - chạm thẻ: đảo w_flipped     │
│   - load(): chọn tối đa 50 thẻ từ các nguồn bật    │ Preferences│  - tiêu đề: mở app (deep link) │
│   - lưu JSON + nhãn, gọi updateWidget()            │            │                                │
└────────────────────────────────────────────────────┘            └────────────────────────────────┘
```

- **Dart chỉ chuẩn bị dữ liệu.** Mọi giá trị gửi sang đều là chuỗi (String hoặc JSON).
- **Java chỉ hiển thị và lưu trạng thái hiển thị của riêng widget**, gồm `w_index` và `w_flipped`. Bấm ‹, › hay lật thẻ chỉ đổi các giá trị này rồi vẽ lại, không cần khởi động Dart. Nhờ vậy widget phản hồi ngay cả khi app đã tắt.
- Vùng nhớ chung là SharedPreferences tên `HomeWidgetPreferences`, do gói [`home_widget`](https://pub.dev/packages/home_widget) quản lý.

---

## 3. Nguồn từ vựng

Người dùng cấu hình ở **Cài đặt → Widget màn hình chính** (`WidgetSettingsScreen`).

| Nguồn | Mặc định | Lấy thẻ nào | Thứ tự |
|---|---|---|---|
| Từ chưa nhớ và ôn hôm nay | Bật | (a) Thẻ có tiến độ với `is_learned = 0`. (b) Thẻ có lượt ôn trong ngày hôm nay (`flashcard_review_logs`). | (a) Thẻ đã đến hạn xếp trước, sau đó theo `due_at`. (b) Lượt ôn gần nhất xếp trước. |
| Chủ đề đã chọn | Tắt | Toàn bộ thẻ của các chủ đề được chọn (chọn nhiều chủ đề bằng chip) | Theo thứ tự chủ đề, rồi `f.sort_order` |
| Từ đã lưu | Tắt | `user_bookmarks` chưa bị xóa (`deleted_at IS NULL`) | Mới lưu xếp trước |

Cách gộp các nguồn:

- Widget lấy **hợp** của các nguồn đang bật, theo đúng thứ tự trong bảng.
- Thẻ trùng giữa các nguồn chỉ giữ lần xuất hiện đầu tiên.
- Tối đa **50 thẻ**.
- Màn cấu hình bắt buộc còn **ít nhất một nguồn** được bật.

**Dự phòng để widget không trống.** Chỉ áp dụng khi nguồn mặc định đang bật mà kết quả rỗng, ví dụ tài khoản mới chưa học gì:

1. Lấy thẻ chưa học bao giờ, ưu tiên chủ đề học gần đây nhất.
2. Nếu vẫn rỗng, lấy thẻ đã học có thời điểm đến hạn gần nhất.

Không dùng `RANDOM()`, để widget không tự nhảy sang từ khác mỗi lần cập nhật.

Code liên quan: `HomeWidgetService.load()` trong `lib/data/widget/home_widget_service.dart`.

---

## 4. Cấu hình (lưu trong `AppPrefs`, theo từng thiết bị)

| Khóa | Kiểu | Mặc định | Ý nghĩa |
|---|---|---|---|
| `widget_enabled` | bool | `true` | Bật/tắt widget |
| `widget_src_default` | bool | `true` | Nguồn "Từ chưa nhớ và ôn hôm nay" |
| `widget_src_topics` | bool | `false` | Nguồn "Chủ đề đã chọn" |
| `widget_topic_ids` | List<String> | `[]` | Các chủ đề đã chọn |
| `widget_src_saved` | bool | `false` | Nguồn "Từ đã lưu" |
| `home_widget_prompt_done` | bool | `false` | Đã bấm "Thêm widget" hoặc "Để sau" trên thẻ gợi ý ở Trang chủ |

Về chế độ **tắt**: Android không cho app tự gỡ widget khỏi màn hình chính. Vì vậy tắt nghĩa là widget ngừng hiện từ và hiện lời nhắc bật lại. Muốn gỡ hẳn thì người dùng tự gỡ trên màn hình chính.

---

## 5. Dữ liệu dùng chung giữa Dart và Java

Tất cả nằm trong SharedPreferences `HomeWidgetPreferences`.

| Khóa | Ai ghi | Nội dung |
|---|---|---|
| `cards` | Dart | Mảng JSON các thẻ `{id, word, partOfSpeech, pronunciation, meaning, topicId, topicTitle}` |
| `w_enabled` | Dart | `"1"` hoặc `"0"` |
| `w_tap_hint` | Dart | Nhãn "Chạm để lật", đã dịch theo ngôn ngữ của app |
| `w_empty` | Dart | Thông báo khi tắt hoặc khi không có từ, đã dịch |
| `w_index` | Java | Vị trí thẻ đang hiện |
| `w_flipped` | Java | Thẻ đang ở mặt sau hay không |
| `w_cards_hash` | Java | Mã băm của chuỗi `cards` ở lần vẽ trước. Khi thấy mã băm khác (tức Dart vừa gửi danh sách mới), Java kẹp `w_index` vào phạm vi hợp lệ và úp thẻ lại. |

Các nhãn chữ do Dart gửi sang, bọc trong `tr(...)`, nên widget hiển thị theo ngôn ngữ đang chọn trong app (Tiếng Việt hoặc English).

---

## 6. Khi nào widget được cập nhật

| Thời điểm | Code |
|---|---|
| Mở app | `main.dart` gọi `HomeWidgetService.refresh(db)` |
| Dữ liệu nguồn thay đổi: ôn thẻ, lưu từ, kéo dữ liệu từ server về, đăng xuất | `HomeWidgetService.watch(db)` theo dõi các bảng `user_flashcard_progress`, `flashcard_review_logs`, `user_bookmarks`, `flashcards`. Các sự kiện được gom lại trong 800 ms rồi mới cập nhật một lần. |
| Quay lại app từ nền | `HomeScreen.didChangeAppLifecycleState(resumed)` |
| Đổi cài đặt widget | `WidgetSettingsScreen` gọi `refresh` ngay sau mỗi thay đổi |
| Chạy nền mỗi 15 phút | `backgroundSyncDispatcher` (workmanager) gọi `refresh` sau khi đồng bộ |
| Bấm "Thêm widget" | `requestPin()` gọi `refresh` trước, nên widget có dữ liệu ngay khi vừa xuất hiện |

---

## 7. Các quyết định thiết kế

| Quyết định | Lý do |
|---|---|
| **Widget chỉ đọc, không chấm Nhớ/Chưa nhớ** | Mỗi lần chấm, `SrsRepository.rate()` làm nhiều việc trong một giao dịch: tính lại hộp Leitner, ghi nhật ký, cộng XP, cập nhật chuỗi ngày học và nhiệm vụ, đưa thao tác vào hàng đợi đồng bộ. Cho widget ghi dữ liệu thì phải lặp lại logic này ở một nơi khác, dễ lệch với server. Mục đích của widget là xem trước từ, việc ôn thật vẫn làm trong app. |
| **Nút ‹ › thay vì vuốt** | Muốn vuốt trong widget phải dùng `StackView`. Vuốt ngang bị launcher dùng để chuyển trang màn hình chính; vuốt dọc thì mỗi launcher xử lý một kiểu, và thẻ có thể nhảy về đầu sau khi lật. Nút bấm chạy giống nhau trên mọi máy. |
| **Một `RemoteViews` thường, không dùng widget dạng danh sách** | Không cần `RemoteViewsService` hay `FLAG_MUTABLE`, ít điểm lỗi hơn. |
| **Chỉ làm Android** | Widget iOS cần máy Mac, Xcode và App Group (tài khoản Apple Developer), lại phải viết lại toàn bộ bằng Swift. |
| **Viết bằng Java** | Project Android đang dùng Java (`MainActivity.java`); viết Java thì không phải cấu hình thêm Kotlin. |
| **Mọi giá trị gửi sang là String** | Tránh lỗi lệch kiểu Int/Long khi Java đọc SharedPreferences. |

---

## 8. Danh sách file

**Dart**

- `lib/data/widget/home_widget_service.dart`: `WidgetConfig`, `WidgetSnapshot`, `load()`, `refresh()`, `watch()`, `canRequestPin()`, `requestPin()`.
- `lib/screens/profile/widget_settings_screen.dart`: màn cấu hình (bật/tắt, nguồn từ vựng, xem trước số từ, nút thêm widget).
- `lib/screens/profile/settings_screen.dart`: mục "Widget màn hình chính", chỉ hiện trên Android.
- `lib/widgets/add_home_widget_card.dart`: thẻ gợi ý "Thêm widget" ở Trang chủ.
- `lib/screens/home/home_screen.dart`: hiện thẻ gợi ý, xử lý deep link từ widget, `refresh` khi quay lại app.
- `lib/data/storage/app_prefs.dart`: các khóa cấu hình ở mục 4.
- `lib/main.dart`, `lib/data/sync/background_sync.dart`: gọi `watch` và `refresh`.
- `lib/core/l10n_en.dart`: bản tiếng Anh cho các nhãn.

**Android** (`android/app/src/main/`)

- `java/com/example/flash/FlashWidgetProvider.java`: vẽ widget, xử lý ‹ › và lật thẻ, mở app.
- `res/layout/flash_widget.xml`: header, `card_front`, `card_back`, `widget_empty`, thanh `widget_bar` (`widget_prev`, `widget_pos`, `widget_next`).
- `res/drawable/widget_bg.xml`, `widget_card_front.xml`, `widget_card_back.xml`: nền bo góc của widget và hai mặt thẻ.
- `res/xml/flash_widget_info.xml`: kích thước 2×2, kéo to được, `updatePeriodMillis=0` (vì app chủ động gọi cập nhật).
- `AndroidManifest.xml`: khai báo `<receiver>` cho widget, và `intent-filter` có action `es.antonborri.home_widget.action.LAUNCH` trên `MainActivity`.

**Test**

- `test/data/widget/home_widget_service_test.dart`: từng nguồn và tổ hợp các nguồn, bỏ trùng, giới hạn 50 thẻ, dự phòng khi trống, trạng thái tắt.

---

## 9. Đường dẫn mở app (deep link)

| Đường dẫn | Màn hình mở ra |
|---|---|
| `flashwidget://study?topic=<id>&title=<tên>` | `FlashcardScreen` của chủ đề đó |
| `flashwidget://study` | Chỉ mở app (không có từ nào) |
| `flashwidget://settings/widget` | `WidgetSettingsScreen` (khi widget đang tắt) |

Java gửi đường dẫn kèm action `LAUNCH` của gói `home_widget`. Phía Dart nhận đường dẫn qua `HomeWidget.initiallyLaunchedFromHomeWidget()` khi app đang tắt, và qua `HomeWidget.widgetClicked` khi app đang chạy nền. Cả hai được xử lý ở `HomeScreen`.

---

## 10. Kiểm thử

**Tự động:** `flutter analyze`, `flutter test`, `flutter build apk --debug`.

**Thử tay:**

- [ ] Bấm "Thêm widget" ở Trang chủ hoặc trong Cài đặt → hộp thoại hiện ra → widget xuất hiện trên màn hình chính và có từ ngay.
- [ ] Chạm thẻ thì lật sang mặt sau (loại từ, phiên âm, nghĩa); chạm lần nữa thì lật lại.
- [ ] Bấm › và ‹ thì đổi từ, vị trí "x/N" đúng, quay vòng ở hai đầu.
- [ ] Chạm tiêu đề thì mở đúng chủ đề.
- [ ] Ôn thẻ trong app thì widget đổi theo trong khoảng 1 giây.
- [ ] Đổi nguồn từ vựng trong Cài đặt thì widget đổi theo.
- [ ] Tắt widget thì hiện thông báo; chạm vào thì mở màn cấu hình.
- [ ] Đăng xuất thì widget không còn từ của tài khoản cũ.
- [ ] Kéo widget to lên 4×4 vẫn hiển thị đúng.

---

## 11. Giới hạn và hướng phát triển

- **Chưa có widget cho iOS.** Muốn làm phải viết bằng WidgetKit (Swift), dùng App Group để chia sẻ dữ liệu, và cần iOS 17 trở lên để có nút bấm trong widget.
- **Số liệu trên widget có thể chậm tới 15 phút khi không mở app.** Lý do: job nền chỉ chạy khi máy có mạng, theo điều kiện đã đặt cho workmanager.
- **Cấu hình lưu theo thiết bị, không đồng bộ giữa các máy.**
- Có thể mở rộng thêm:
  - nút phát âm (TTS) trên mặt sau của thẻ;
  - chọn cỡ chữ hoặc màu cho widget;
  - widget cỡ nhỏ 1×1 chỉ hiện số thẻ cần ôn.
