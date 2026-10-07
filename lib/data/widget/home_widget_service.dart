import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show QueryRow, TableUpdateQuery, Variable;
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../../core/clock.dart';
import '../../core/l10n.dart';
import '../local/app_database.dart';
import '../repositories/base_repository.dart' show WriteRepository;
import '../storage/app_prefs.dart';

/// Cấu hình widget (lưu theo thiết bị trong [AppPrefs]).
class WidgetConfig {
  final bool enabled;

  /// Nguồn "Từ chưa nhớ + ôn hôm nay".
  final bool srcDefault;

  /// Nguồn "Chủ đề đã chọn"; danh sách rỗng thì nguồn này rỗng.
  final bool srcTopics;
  final List<String> topicIds;

  /// Nguồn "Từ đã lưu".
  final bool srcSaved;

  const WidgetConfig({
    this.enabled = true,
    this.srcDefault = true,
    this.srcTopics = false,
    this.topicIds = const [],
    this.srcSaved = false,
  });

  factory WidgetConfig.fromPrefs(AppPrefs p) => WidgetConfig(
        enabled: p.widgetEnabled,
        srcDefault: p.widgetSrcDefault,
        srcTopics: p.widgetSrcTopics,
        topicIds: p.widgetTopicIds,
        srcSaved: p.widgetSrcSaved,
      );
}

/// Dữ liệu widget đọc từ SQLite: các thẻ sẽ hiện + tổng số thẻ đến hạn thật.
class WidgetSnapshot {
  final List<Map<String, String>> cards;
  final int dueCount;
  const WidgetSnapshot({required this.cards, required this.dueCount});

  /// JSON gửi sang native dưới khóa "cards".
  String get cardsJson => jsonEncode(cards);
}

/// Nơi ghi dữ liệu cho widget. Tách ra để test `refresh()` không cần platform channel.
abstract interface class WidgetDataWriter {
  Future<void> save(String key, String value);
  Future<void> update();
}

/// Ghi vào SharedPreferences "HomeWidgetPreferences" qua gói home_widget rồi báo widget vẽ lại.
class HomeWidgetDataWriter implements WidgetDataWriter {
  const HomeWidgetDataWriter();

  static const androidName = 'FlashWidgetProvider'; // tên lớp Java (FlashWidgetProvider.java)

  @override
  Future<void> save(String key, String value) => HomeWidget.saveWidgetData<String>(key, value);

  @override
  Future<void> update() => HomeWidget.updateWidget(androidName: androidName);
}

/// Đẩy danh sách từ sang widget màn hình chính (Android).
/// Dart chỉ chuẩn bị dữ liệu (chuỗi / JSON); hiển thị và cuộn danh sách do code native đảm nhận.
class HomeWidgetService {
  HomeWidgetService._();

  static const maxCards = 50;

  /// Widget chỉ có trên Android; nơi khác (iOS, web, desktop, test) bỏ qua mọi lệnh gọi plugin.
  static bool get supported => !kIsWeb && Platform.isAndroid;
  static StreamSubscription<void>? _sub;
  static Timer? _debounce;

  /// Các bảng mà nguồn dữ liệu của widget phụ thuộc vào.
  static const _watchedTables = ['user_flashcard_progress', 'flashcard_review_logs', 'user_bookmarks', 'flashcards'];

  /// Tự cập nhật widget mỗi khi dữ liệu nguồn thay đổi (ôn thẻ, lưu từ, kéo dữ liệu về, đăng xuất...).
  static void watch(AppDatabase db) {
    if (!supported) return;
    _sub?.cancel();
    _sub = db
        .tableUpdates(TableUpdateQuery.allOf(_watchedTables.map(TableUpdateQuery.onTableName).toList()))
        .listen((_) {
      // Ôn 20 thẻ liên tiếp sẽ bắn 20 sự kiện → gom lại, chỉ cập nhật một lần.
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 800), () => refresh(db));
    });
  }

  static const _cardColumns = 'SELECT f.id, f.word, f.pronunciation, f.meaning, f.topic_id, t.title AS topic_title ';

  /// Hợp các nguồn đang bật trong [config], bỏ trùng theo flashcard_id, tối đa [limit] thẻ. Thứ tự:
  /// 1. Nguồn mặc định: thẻ chưa nhớ (is_learned = 0; đã đến hạn trước, rồi theo due_at),
  ///    sau đó thẻ ôn hôm nay (lần ôn gần nhất trước).
  /// 2. Chủ đề đã chọn: theo thứ tự chủ đề rồi f.sort_order.
  /// 3. Từ đã lưu: mới lưu trước.
  /// Chỉ khi nguồn mặc định bật mà kết quả rỗng mới dùng dự phòng: thẻ mới, rồi thẻ sắp đến hạn.
  /// Không dùng RANDOM() để widget không tự đổi từ mỗi lần refresh.
  /// `dueCount` chỉ đếm thẻ đến hạn thật.
  static Future<WidgetSnapshot> load(
    AppDatabase db, {
    required int nowMs,
    WidgetConfig config = const WidgetConfig(),
    int limit = maxCards,
  }) async {
    final rows = <QueryRow>[];
    Future<void> add(String sql, List<Variable> vars) async =>
        rows.addAll(await db.customSelect(sql, variables: [...vars, Variable.withInt(limit)]).get());

    if (config.srcDefault) {
      await add(
        '$_cardColumns'
        'FROM user_flashcard_progress p '
        'JOIN flashcards f ON f.id = p.flashcard_id '
        'JOIN topics t ON t.id = f.topic_id '
        'WHERE p.is_learned = 0 '
        'ORDER BY (p.due_at IS NULL OR p.due_at > ?), p.due_at IS NULL, p.due_at, f.id '
        'LIMIT ?',
        [Variable.withInt(nowMs)],
      );
      final (dayStart, dayEnd) = WriteRepository.dayBounds(DateTime.fromMillisecondsSinceEpoch(nowMs, isUtc: true));
      await add(
        '$_cardColumns'
        'FROM flashcard_review_logs l '
        'JOIN flashcards f ON f.id = l.flashcard_id '
        'JOIN topics t ON t.id = f.topic_id '
        'WHERE l.reviewed_at >= ? AND l.reviewed_at < ? '
        'GROUP BY f.id '
        'ORDER BY MAX(l.reviewed_at) DESC, f.id '
        'LIMIT ?',
        [Variable.withInt(dayStart), Variable.withInt(dayEnd)],
      );
    }

    if (config.srcTopics && config.topicIds.isNotEmpty) {
      final marks = List.filled(config.topicIds.length, '?').join(', ');
      await add(
        '$_cardColumns'
        'FROM flashcards f '
        'JOIN topics t ON t.id = f.topic_id '
        'WHERE f.topic_id IN ($marks) '
        'ORDER BY t.sort_order, t.id, f.sort_order, f.id '
        'LIMIT ?',
        config.topicIds.map(Variable.withString).toList(),
      );
    }

    if (config.srcSaved) {
      await add(
        '$_cardColumns'
        'FROM user_bookmarks b '
        'JOIN flashcards f ON f.id = b.flashcard_id '
        'JOIN topics t ON t.id = f.topic_id '
        'WHERE b.deleted_at IS NULL '
        'ORDER BY b.created_at DESC, f.id '
        'LIMIT ?',
        const [],
      );
    }

    // Dự phòng "không bao giờ trống" chỉ thuộc về nguồn mặc định.
    if (config.srcDefault && rows.isEmpty) {
      await add(
        '$_cardColumns'
        'FROM flashcards f '
        'JOIN topics t ON t.id = f.topic_id '
        'LEFT JOIN user_flashcard_progress p ON p.flashcard_id = f.id '
        'LEFT JOIN user_topic_progress tp ON tp.topic_id = f.topic_id '
        'WHERE p.flashcard_id IS NULL '
        'ORDER BY tp.last_studied_at IS NULL, tp.last_studied_at DESC, t.sort_order, f.topic_id, f.sort_order, f.id '
        'LIMIT ?',
        const [],
      );
      if (rows.isEmpty) {
        await add(
          '$_cardColumns'
          'FROM user_flashcard_progress p '
          'JOIN flashcards f ON f.id = p.flashcard_id '
          'JOIN topics t ON t.id = f.topic_id '
          'WHERE p.due_at > ? '
          'ORDER BY p.due_at, f.id '
          'LIMIT ?',
          [Variable.withInt(nowMs)],
        );
      }
    }

    final countRow = await db
        .customSelect(
          'SELECT COUNT(*) AS c FROM user_flashcard_progress WHERE due_at IS NOT NULL AND due_at <= ?',
          variables: [Variable.withInt(nowMs)],
        )
        .getSingle();

    // Các nguồn có thể chồng nhau (thẻ vừa chưa nhớ vừa được lưu...) → giữ lần xuất hiện đầu tiên.
    final seen = <String>{};
    final cards = rows
        .where((r) => seen.add(r.read<String>('id')))
        .take(limit)
        .map(
          (r) => {
            'id': r.read<String>('id'),
            'word': r.read<String>('word'),
            'pronunciation': r.read<String>('pronunciation'),
            'meaning': r.read<String>('meaning'),
            'topicId': r.read<String>('topic_id'),
            'topicTitle': r.read<String>('topic_title'),
          },
        )
        .toList();
    return WidgetSnapshot(cards: cards, dueCount: countRow.read<int>('c'));
  }

  /// Launcher có hỗ trợ "ghim widget" (Android 8+, tùy launcher) thì mới hiện nút "Thêm widget".
  static Future<bool> canRequestPin() async {
    if (!supported) return false;
    try {
      return await HomeWidget.isRequestPinWidgetSupported() == true;
    } catch (e) {
      debugPrint('HomeWidgetService.canRequestPin: $e');
      return false;
    }
  }

  /// Gửi dữ liệu mới nhất rồi nhờ launcher hiện hộp thoại đặt widget ra màn hình chính.
  /// Trả về false nếu không gửi được yêu cầu.
  static Future<bool> requestPin(AppDatabase db) async {
    if (!supported) return false;
    try {
      await refresh(db);
      await HomeWidget.requestPinWidget(androidName: HomeWidgetDataWriter.androidName);
      return true;
    } catch (e) {
      debugPrint('HomeWidgetService.requestPin: $e');
      return false;
    }
  }

  /// Đọc cấu hình + dữ liệu rồi gửi sang widget. [config] / [writer] chỉ truyền khi test;
  /// mặc định đọc [AppPrefs] và ghi qua gói home_widget.
  static Future<void> refresh(AppDatabase db, {WidgetConfig? config, WidgetDataWriter? writer}) async {
    if (writer == null && !supported) return;
    final w = writer ?? const HomeWidgetDataWriter();
    try {
      final cfg = config ?? WidgetConfig.fromPrefs(await AppPrefs.load());

      if (!cfg.enabled) {
        // Tắt: không truy vấn gì, widget chỉ hiện thông báo "chạm để bật".
        await w.save('w_enabled', '0');
        await w.save('cards', '[]');
        await w.save('w_count_label', '');
        await w.save('w_empty', tr('Widget đang tắt – chạm để bật'));
        await w.update();
        return;
      }

      final snap = await load(db, nowMs: Clock.nowMs(), config: cfg);
      await w.save('w_enabled', '1');
      await w.save('cards', snap.cardsJson);
      await w.save(
        'w_count_label',
        snap.dueCount > 0
            ? trf('{n} thẻ cần ôn', {'n': snap.dueCount})
            : trf('{n} từ', {'n': snap.cards.length}),
      );
      await w.save('w_empty', tr('Không có từ nào'));
      await w.update();
    } catch (e) {
      debugPrint('HomeWidgetService.refresh: $e'); // widget lỗi không được làm hỏng app
    }
  }
}
