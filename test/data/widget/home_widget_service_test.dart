import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flash/data/local/app_database.dart';
import 'package:flash/data/widget/home_widget_service.dart';

void main() {
  late AppDatabase db;
  const now = 1000000;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.customStatement(
        "INSERT INTO topics (id, title, icon_path, server_updated_at) VALUES ('t1', 'Daily Life', 'x', 1)");
  });
  tearDown(() => db.close());

  /// Thêm một flashcard chưa học (không có dòng tiến độ).
  Future<void> addNewCard(String id, {String topic = 't1', int sortOrder = 0}) async {
    await db.customStatement(
        'INSERT INTO flashcards (id, topic_id, word, part_of_speech, pronunciation, meaning, sort_order, server_updated_at) '
        "VALUES (?, ?, ?, 'n.', ?, ?, ?, 1)",
        [id, topic, 'word_$id', '/$id/', 'nghĩa $id', sortOrder]);
  }

  /// Thêm một flashcard và tiến độ với due_at cho trước (null = chưa có lịch ôn).
  Future<void> addCard(String id, int? dueAt) async {
    await addNewCard(id);
    await db.customStatement(
        'INSERT INTO user_flashcard_progress (flashcard_id, due_at) VALUES (?, ?)', [id, dueAt]);
  }

  test('DB không có flashcard nào → 0 thẻ', () async {
    final snap = await HomeWidgetService.load(db, nowMs: now);
    expect(snap.cards, isEmpty);
    expect(snap.dueCount, 0);
    expect(snap.cardsJson, '[]');
  });

  test('không có tiến độ nhưng có flashcard → trả về thẻ mới, dueCount = 0', () async {
    await db.customStatement(
        "INSERT INTO topics (id, title, icon_path, sort_order, server_updated_at) VALUES ('t2', 'Travel', 'x', 1, 1)");
    await db.customStatement(
        "INSERT INTO topics (id, title, icon_path, sort_order, server_updated_at) VALUES ('t3', 'Food', 'x', 2, 1)");
    // t2 học gần nhất, t3 học lâu hơn, t1 chưa học → thứ tự t2, t3, t1; trong topic theo sort_order.
    await db.customStatement("INSERT INTO user_topic_progress (topic_id, last_studied_at) VALUES ('t2', 500)");
    await db.customStatement("INSERT INTO user_topic_progress (topic_id, last_studied_at) VALUES ('t3', 100)");
    await addNewCard('a1', topic: 't1', sortOrder: 0);
    await addNewCard('b2', topic: 't2', sortOrder: 2);
    await addNewCard('b1', topic: 't2', sortOrder: 1);
    await addNewCard('c1', topic: 't3', sortOrder: 0);

    final snap = await HomeWidgetService.load(db, nowMs: now);
    expect(snap.cards.map((c) => c['id']), ['b1', 'b2', 'c1', 'a1']);
    expect(snap.dueCount, 0);

    // Gọi lại cho cùng kết quả (không ngẫu nhiên).
    final again = await HomeWidgetService.load(db, nowMs: now);
    expect(again.cardsJson, snap.cardsJson);
  });

  test('thiếu thẻ đến hạn → bổ sung bằng thẻ mới, không trùng, không lấy thẻ tương lai', () async {
    await addCard('due1', now - 20);
    await addCard('due2', now - 10);
    await addCard('future', now + 1000);
    for (var i = 0; i < 5; i++) {
      await addNewCard('n$i', sortOrder: i);
    }

    final snap = await HomeWidgetService.load(db, nowMs: now, limit: 4);
    expect(snap.cards.map((c) => c['id']), ['due1', 'due2', 'n0', 'n1']);
    expect(snap.dueCount, 2);
  });

  test('không có thẻ đến hạn lẫn thẻ mới → lấy thẻ có due_at gần nhất trong tương lai', () async {
    await addCard('far', now + 5000);
    await addCard('near', now + 10);
    await addCard('none', null);

    final snap = await HomeWidgetService.load(db, nowMs: now);
    expect(snap.cards.map((c) => c['id']), ['near', 'far']);
    expect(snap.dueCount, 0);
  });

  test('chỉ lấy thẻ đã đến hạn, sắp theo due_at tăng dần', () async {
    await addCard('late', now - 10);
    await addCard('future', now + 1);
    await addCard('early', now - 500);
    await addCard('exact', now);
    await addCard('none', null);

    final snap = await HomeWidgetService.load(db, nowMs: now);
    expect(snap.cards.map((c) => c['id']), ['early', 'late', 'exact']);
    expect(snap.dueCount, 3);
  });

  test('nhiều hơn limit → danh sách bị cắt nhưng dueCount là tổng thật', () async {
    for (var i = 0; i < 13; i++) {
      await addCard('c$i', now - 100 + i);
    }
    final snap = await HomeWidgetService.load(db, nowMs: now, limit: 10);
    expect(snap.cards.length, 10);
    expect(snap.cards.first['id'], 'c0');
    expect(snap.dueCount, 13);
  });

  test('JSON mỗi thẻ có đủ khóa cho widget native', () async {
    await addCard('f1', now - 1);
    final snap = await HomeWidgetService.load(db, nowMs: now);
    final decoded = jsonDecode(snap.cardsJson) as List;
    expect(decoded, hasLength(1));
    final card = decoded.single as Map<String, dynamic>;
    expect(card.keys.toSet(), {'id', 'word', 'pronunciation', 'meaning', 'topicId', 'topicTitle'});
    expect(card, {
      'id': 'f1',
      'word': 'word_f1',
      'pronunciation': '/f1/',
      'meaning': 'nghĩa f1',
      'topicId': 't1',
      'topicTitle': 'Daily Life',
    });
  });
}
