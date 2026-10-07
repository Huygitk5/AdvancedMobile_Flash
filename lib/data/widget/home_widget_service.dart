import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show TableUpdateQuery, Variable;
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../../core/clock.dart';
import '../local/app_database.dart';

/// Dữ liệu widget đọc từ SQLite: tối đa `limit` thẻ đến hạn + tổng số thẻ đến hạn thật.
class WidgetSnapshot {
  final List<Map<String, String>> cards;
  final int dueCount;
  const WidgetSnapshot({required this.cards, required this.dueCount});

  /// JSON gửi sang native dưới khóa "cards".
  String get cardsJson => jsonEncode(cards);
}

/// Đẩy dữ liệu "thẻ cần ôn" sang widget màn hình chính.
/// Dart chỉ chuẩn bị dữ liệu; hiển thị, chuyển từ, lật thẻ do code native đảm nhận.
class HomeWidgetService {
  HomeWidgetService._();

  static const appGroupId = 'group.com.example.flash'; // phải trùng App Group trên iOS
  static const _androidName = 'FlashWidgetProvider'; // tên lớp Java (FlashWidgetProvider.java)
  static const _iosName = 'FlashWidget'; // "kind" của widget Swift (ios/FlashWidget/FlashWidget.swift)
  static const _limit = 10;

  /// Chỉ Android/iOS có widget; nơi khác (web, desktop, test) bỏ qua mọi lệnh gọi plugin.
  static bool get supported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  static StreamSubscription<void>? _sub;
  static Timer? _debounce;

  /// Gọi một lần trong main(), trước mọi lệnh lưu dữ liệu. Android bỏ qua lệnh này.
  static Future<void> init() async {
    if (!supported) return;
    try {
      await HomeWidget.setAppGroupId(appGroupId);
    } catch (e) {
      debugPrint('HomeWidgetService.init: $e');
    }
  }

  /// Tự cập nhật widget mỗi khi bảng tiến độ thay đổi (ôn thẻ, kéo dữ liệu về, đăng xuất...).
  static void watch(AppDatabase db) {
    if (!supported) return;
    _sub?.cancel();
    _sub = db.tableUpdates(TableUpdateQuery.onTableName('user_flashcard_progress')).listen((_) {
      // Ôn 20 thẻ liên tiếp sẽ bắn 20 sự kiện → gom lại, chỉ cập nhật một lần.
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 800), () => refresh(db));
    });
  }

  /// Đọc thẻ đến hạn (due_at <= nowMs), sắp theo due_at tăng dần, cắt ở [limit].
  /// `dueCount` là tổng số thẻ đến hạn, không bị cắt.
  @visibleForTesting
  static Future<WidgetSnapshot> load(AppDatabase db, {required int nowMs, int limit = _limit}) async {
    final rows = await db.customSelect(
      'SELECT f.id, f.word, f.pronunciation, f.meaning, f.topic_id, t.title AS topic_title '
      'FROM user_flashcard_progress p '
      'JOIN flashcards f ON f.id = p.flashcard_id '
      'JOIN topics t ON t.id = f.topic_id '
      'WHERE p.due_at IS NOT NULL AND p.due_at <= ? '
      'ORDER BY p.due_at LIMIT ?',
      variables: [Variable.withInt(nowMs), Variable.withInt(limit)],
    ).get();
    final countRow = await db.customSelect(
      'SELECT COUNT(*) AS c FROM user_flashcard_progress WHERE due_at IS NOT NULL AND due_at <= ?',
      variables: [Variable.withInt(nowMs)],
    ).getSingle();

    final cards = rows
        .map((r) => {
              'id': r.read<String>('id'),
              'word': r.read<String>('word'),
              'pronunciation': r.read<String>('pronunciation'),
              'meaning': r.read<String>('meaning'),
              'topicId': r.read<String>('topic_id'),
              'topicTitle': r.read<String>('topic_title'),
            })
        .toList();
    return WidgetSnapshot(cards: cards, dueCount: countRow.read<int>('c'));
  }

  /// Đọc thẻ đến hạn từ SQLite và gửi sang widget.
  static Future<void> refresh(AppDatabase db) async {
    if (!supported) return;
    try {
      final snap = await load(db, nowMs: Clock.nowMs());

      // Nhãn chữ cũng gửi từ Dart → widget tự theo ngôn ngữ app (bọc bằng tr(...) nếu muốn).
      await HomeWidget.saveWidgetData<String>('cards', snap.cardsJson);
      await HomeWidget.saveWidgetData<String>('w_count_label', '${snap.dueCount} thẻ cần ôn');
      await HomeWidget.saveWidgetData<String>('w_tap_hint', 'Chạm để xem nghĩa');
      await HomeWidget.saveWidgetData<String>('w_empty_title', 'Không có thẻ cần ôn');
      await HomeWidget.saveWidgetData<String>('w_empty_hint', 'Chạm để mở app học từ mới');
      await HomeWidget.updateWidget(androidName: _androidName, iOSName: _iosName);
    } catch (e) {
      debugPrint('HomeWidgetService.refresh: $e'); // widget lỗi không được làm hỏng app
    }
  }
}
