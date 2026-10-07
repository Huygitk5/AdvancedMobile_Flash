import 'dart:convert';

import 'package:drift/drift.dart' show QueryExecutor, QueryInterceptor, ApplyInterceptor;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flash/data/local/app_database.dart';
import 'package:flash/data/widget/home_widget_service.dart';

/// Đếm số câu SELECT để kiểm tra "widget tắt thì không truy vấn".
class _SelectCounter extends QueryInterceptor {
  int selects = 0;

  @override
  Future<List<Map<String, Object?>>> runSelect(QueryExecutor executor, String statement, List<Object?> args) {
    selects++;
    return super.runSelect(executor, statement, args);
  }
}

/// Ghi vào bộ nhớ thay cho platform channel của home_widget.
class _FakeWriter implements WidgetDataWriter {
  final data = <String, String>{};
  int updates = 0;

  @override
  Future<void> save(String key, String value) async => data[key] = value;

  @override
  Future<void> update() async => updates++;
}

void main() {
  late AppDatabase db;
  late _SelectCounter counter;
  // Giữa trưa theo giờ máy: "hôm nay" là [00:00, 24:00) địa phương.
  final now = DateTime(2026, 10, 7, 12).millisecondsSinceEpoch;
  const hour = 3600 * 1000;

  Future<void> addTopic(String id, {int sortOrder = 0}) => db.customStatement(
      'INSERT INTO topics (id, title, icon_path, sort_order, server_updated_at) VALUES (?, ?, ?, ?, 1)',
      [id, 'Topic $id', 'x', sortOrder]);

  /// Thẻ chưa học (chưa có dòng tiến độ).
  Future<void> addCard(String id, {String topic = 't1', int sortOrder = 0}) => db.customStatement(
      'INSERT INTO flashcards (id, topic_id, word, part_of_speech, pronunciation, meaning, sort_order, server_updated_at) '
      "VALUES (?, ?, ?, 'n.', ?, ?, ?, 1)",
      [id, topic, 'word_$id', '/$id/', 'nghĩa $id', sortOrder]);

  Future<void> addProgress(String id, {int? dueAt, bool learned = false}) => db.customStatement(
      'INSERT INTO user_flashcard_progress (flashcard_id, due_at, is_learned) VALUES (?, ?, ?)',
      [id, dueAt, learned ? 1 : 0]);

  Future<void> addLog(String logId, String cardId, int reviewedAt) => db.customStatement(
      'INSERT INTO flashcard_review_logs (id, flashcard_id, rating, box_before, box_after, reviewed_at) '
      "VALUES (?, ?, 'KNOW', 0, 1, ?)",
      [logId, cardId, reviewedAt]);

  Future<void> addBookmark(String id, int createdAt, {int? deletedAt}) => db.customStatement(
      'INSERT INTO user_bookmarks (flashcard_id, created_at, client_updated_at, deleted_at) VALUES (?, ?, ?, ?)',
      [id, createdAt, createdAt, deletedAt]);

  setUp(() async {
    counter = _SelectCounter();
    db = AppDatabase(NativeDatabase.memory().interceptWith(counter));
    await addTopic('t1', sortOrder: 0);
  });
  tearDown(() => db.close());

  Future<List<String?>> ids(WidgetConfig config, {int limit = HomeWidgetService.maxCards}) async =>
      (await HomeWidgetService.load(db, nowMs: now, config: config, limit: limit)).cards.map((c) => c['id']).toList();

  group('nguồn mặc định (chưa nhớ + ôn hôm nay)', () {
    test('lấy thẻ chưa nhớ (đến hạn trước) rồi thẻ ôn hôm nay; bỏ thẻ đã học không ôn hôm nay', () async {
      for (final id in ['u_future', 'u_due', 'u_none', 'learned_today', 'learned_old', 'learned_yesterday']) {
        await addCard(id);
      }
      await addProgress('u_future', dueAt: now + hour);
      await addProgress('u_due', dueAt: now - hour);
      await addProgress('u_none');
      await addProgress('learned_today', dueAt: now + 48 * hour, learned: true);
      await addProgress('learned_old', dueAt: now + 48 * hour, learned: true);
      await addProgress('learned_yesterday', dueAt: now + 48 * hour, learned: true);
      await addLog('l1', 'learned_today', now - hour);
      await addLog('l2', 'u_due', now - 2 * hour); // vừa chưa nhớ vừa ôn hôm nay → không trùng
      await addLog('l3', 'learned_yesterday', now - 24 * hour);

      final snap = await HomeWidgetService.load(db, nowMs: now, config: const WidgetConfig());
      expect(snap.cards.map((c) => c['id']), ['u_due', 'u_future', 'u_none', 'learned_today']);
      expect(snap.dueCount, 1);
    });

    test('kết quả rỗng → dự phòng thẻ mới, dueCount = 0', () async {
      await addTopic('t2', sortOrder: 1);
      await db.customStatement("INSERT INTO user_topic_progress (topic_id, last_studied_at) VALUES ('t2', 500)");
      await addCard('a1', topic: 't1');
      await addCard('b2', topic: 't2', sortOrder: 2);
      await addCard('b1', topic: 't2', sortOrder: 1);

      final snap = await HomeWidgetService.load(db, nowMs: now);
      expect(snap.cards.map((c) => c['id']), ['b1', 'b2', 'a1']);
      expect(snap.dueCount, 0);
    });

    test('không có thẻ mới → dự phòng thẻ đã học sắp đến hạn', () async {
      await addCard('far');
      await addCard('near');
      await addProgress('far', dueAt: now + 50 * hour, learned: true);
      await addProgress('near', dueAt: now + 30 * hour, learned: true);
      expect(await ids(const WidgetConfig()), ['near', 'far']);
    });

    test('DB không có flashcard nào → 0 thẻ', () async {
      final snap = await HomeWidgetService.load(db, nowMs: now);
      expect(snap.cards, isEmpty);
      expect(snap.dueCount, 0);
      expect(snap.cardsJson, '[]');
    });
  });

  group('chủ đề đã chọn', () {
    setUp(() async {
      await addTopic('t2', sortOrder: 2);
      await addTopic('t3', sortOrder: 1);
      await addCard('a', topic: 't1');
      await addCard('b2', topic: 't2', sortOrder: 2);
      await addCard('b1', topic: 't2', sortOrder: 1);
      await addCard('c', topic: 't3');
    });

    test('chỉ ra thẻ của các chủ đề đã chọn, theo thứ tự chủ đề rồi sort_order', () async {
      const cfg = WidgetConfig(srcDefault: false, srcTopics: true, topicIds: ['t2', 't3']);
      expect(await ids(cfg), ['c', 'b1', 'b2']);
    });

    test('danh sách chủ đề rỗng → 0 thẻ (không dùng dự phòng)', () async {
      const cfg = WidgetConfig(srcDefault: false, srcTopics: true, topicIds: []);
      expect(await ids(cfg), isEmpty);
    });
  });

  test('từ đã lưu: bỏ bookmark đã xóa, mới lưu trước', () async {
    for (final id in ['old', 'new', 'gone']) {
      await addCard(id);
    }
    await addBookmark('old', 100);
    await addBookmark('new', 200);
    await addBookmark('gone', 300, deletedAt: 400);
    expect(await ids(const WidgetConfig(srcDefault: false, srcSaved: true)), ['new', 'old']);
  });

  test('kết hợp nhiều nguồn: không trùng thẻ, tối đa 50 thẻ', () async {
    for (var i = 0; i < 60; i++) {
      await addCard('c${i.toString().padLeft(2, '0')}', sortOrder: i);
    }
    await addProgress('c05', dueAt: now - hour); // mặc định + chủ đề
    await addBookmark('c05', 100); // + đã lưu
    await addBookmark('c59', 200);

    const cfg = WidgetConfig(srcTopics: true, topicIds: ['t1'], srcSaved: true);
    final result = await ids(cfg);
    expect(result.length, 50);
    expect(result.toSet().length, 50);
    expect(result.first, 'c05');
    expect(result.where((id) => id == 'c05').length, 1);

    // Đủ chỗ thì thẻ chỉ có ở nguồn "đã lưu" cũng được lấy, vẫn không trùng.
    final all = await ids(cfg, limit: 100);
    expect(all.length, 60);
    expect(all.toSet().length, 60);
  });

  test('JSON mỗi thẻ có đủ khóa cho widget native', () async {
    await addCard('f1');
    final snap = await HomeWidgetService.load(db, nowMs: now);
    final card = (jsonDecode(snap.cardsJson) as List).single as Map<String, dynamic>;
    expect(card, {
      'id': 'f1',
      'word': 'word_f1',
      'pronunciation': '/f1/',
      'meaning': 'nghĩa f1',
      'topicId': 't1',
      'topicTitle': 'Topic t1',
    });
  });

  group('refresh()', () {
    test('widget tắt: không truy vấn, cards = [], w_enabled = "0"', () async {
      await addCard('f1');
      final writer = _FakeWriter();
      counter.selects = 0;

      await HomeWidgetService.refresh(db, config: const WidgetConfig(enabled: false), writer: writer);

      expect(counter.selects, 0);
      expect(writer.data['w_enabled'], '0');
      expect(writer.data['cards'], '[]');
      expect(writer.data['w_empty'], isNotEmpty);
      expect(writer.updates, 1);
    });

    test('widget bật: gửi thẻ và nhãn "N từ" khi không có thẻ đến hạn', () async {
      await addCard('f1');
      await addCard('f2');
      final writer = _FakeWriter();

      await HomeWidgetService.refresh(db, config: const WidgetConfig(), writer: writer);

      expect(writer.data['w_enabled'], '1');
      expect((jsonDecode(writer.data['cards']!) as List).length, 2);
      expect(writer.data['w_count_label'], '2 từ');
      expect(writer.updates, 1);
    });
  });
}
