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

  static const _androidName = 'FlashWidgetProvider'; // tên lớp Java (FlashWidgetProvider.java)
  static const _limit = 10;

  /// Widget chỉ có trên Android; nơi khác (iOS, web, desktop, test) bỏ qua mọi lệnh gọi plugin.
  static bool get supported => !kIsWeb && Platform.isAndroid;
  static StreamSubscription<void>? _sub;
  static Timer? _debounce;

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

  static const _cardColumns = 'SELECT f.id, f.word, f.pronunciation, f.meaning, f.topic_id, t.title AS topic_title ';

  /// Chọn tối đa [limit] thẻ để widget không bao giờ trống khi DB có thẻ, theo thứ tự ưu tiên:
  /// 1. Thẻ đến hạn (due_at <= nowMs), sắp theo due_at.
  /// 2. Còn thiếu → thẻ mới (chưa có tiến độ), topic học gần nhất trước, topic chưa học sau.
  /// 3. Vẫn chưa có thẻ nào → thẻ đã học có due_at gần nhất trong tương lai.
  /// Không dùng RANDOM() để widget không tự đổi từ mỗi lần refresh.
  /// `dueCount` chỉ đếm thẻ đến hạn thật, không bị cắt.
  @visibleForTesting
  static Future<WidgetSnapshot> load(AppDatabase db, {required int nowMs, int limit = _limit}) async {
    final rows = [
      ...await db
          .customSelect(
            '$_cardColumns'
            'FROM user_flashcard_progress p '
            'JOIN flashcards f ON f.id = p.flashcard_id '
            'JOIN topics t ON t.id = f.topic_id '
            'WHERE p.due_at IS NOT NULL AND p.due_at <= ? '
            'ORDER BY p.due_at LIMIT ?',
            variables: [Variable.withInt(nowMs), Variable.withInt(limit)],
          )
          .get(),
    ];

    if (rows.length < limit) {
      rows.addAll(
        await db
            .customSelect(
              '$_cardColumns'
              'FROM flashcards f '
              'JOIN topics t ON t.id = f.topic_id '
              'LEFT JOIN user_flashcard_progress p ON p.flashcard_id = f.id '
              'LEFT JOIN user_topic_progress tp ON tp.topic_id = f.topic_id '
              'WHERE p.flashcard_id IS NULL '
              'ORDER BY tp.last_studied_at IS NULL, tp.last_studied_at DESC, t.sort_order, f.topic_id, f.sort_order, f.id '
              'LIMIT ?',
              variables: [Variable.withInt(limit - rows.length)],
            )
            .get(),
      );
    }

    if (rows.isEmpty) {
      rows.addAll(
        await db
            .customSelect(
              '$_cardColumns'
              'FROM user_flashcard_progress p '
              'JOIN flashcards f ON f.id = p.flashcard_id '
              'JOIN topics t ON t.id = f.topic_id '
              'WHERE p.due_at > ? '
              'ORDER BY p.due_at LIMIT ?',
              variables: [Variable.withInt(nowMs), Variable.withInt(limit)],
            )
            .get(),
      );
    }

    final countRow = await db
        .customSelect(
          'SELECT COUNT(*) AS c FROM user_flashcard_progress WHERE due_at IS NOT NULL AND due_at <= ?',
          variables: [Variable.withInt(nowMs)],
        )
        .getSingle();

    // Ba nhóm vốn rời nhau theo điều kiện WHERE; vẫn lọc theo id để chắc chắn không trùng thẻ.
    final seen = <String>{};
    final cards = rows
        .where((r) => seen.add(r.read<String>('id')))
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
      await HomeWidget.requestPinWidget(androidName: _androidName);
      return true;
    } catch (e) {
      debugPrint('HomeWidgetService.requestPin: $e');
      return false;
    }
  }

  /// Đọc thẻ đến hạn từ SQLite và gửi sang widget.
  static Future<void> refresh(AppDatabase db) async {
    if (!supported) return;
    try {
      final snap = await load(db, nowMs: Clock.nowMs());

      // Nhãn chữ cũng gửi từ Dart → widget tự theo ngôn ngữ app (bọc bằng tr(...) nếu muốn).
      await HomeWidget.saveWidgetData<String>('cards', snap.cardsJson);
      await HomeWidget.saveWidgetData<String>(
        'w_count_label',
        snap.dueCount > 0 ? '${snap.dueCount} thẻ cần ôn' : 'Từ mới hôm nay',
      );
      await HomeWidget.saveWidgetData<String>('w_tap_hint', 'Chạm để xem nghĩa');
      await HomeWidget.saveWidgetData<String>('w_empty_title', 'Không có thẻ cần ôn');
      await HomeWidget.saveWidgetData<String>('w_empty_hint', 'Chạm để mở app học từ mới');
      await HomeWidget.updateWidget(androidName: _androidName);
    } catch (e) {
      debugPrint('HomeWidgetService.refresh: $e'); // widget lỗi không được làm hỏng app
    }
  }
}
