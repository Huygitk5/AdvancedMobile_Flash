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

  /// Thêm một flashcard và tiến độ với due_at cho trước (null = chưa có lịch ôn).
  Future<void> addCard(String id, int? dueAt) async {
    await db.customStatement(
        'INSERT INTO flashcards (id, topic_id, word, part_of_speech, pronunciation, meaning, server_updated_at) '
        "VALUES (?, 't1', ?, 'n.', ?, ?, 1)",
        [id, 'word_$id', '/$id/', 'nghĩa $id']);
    await db.customStatement(
        'INSERT INTO user_flashcard_progress (flashcard_id, due_at) VALUES (?, ?)', [id, dueAt]);
  }

  test('không có tiến độ → 0 thẻ, dueCount = 0', () async {
    final snap = await HomeWidgetService.load(db, nowMs: now);
    expect(snap.cards, isEmpty);
    expect(snap.dueCount, 0);
    expect(snap.cardsJson, '[]');
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
