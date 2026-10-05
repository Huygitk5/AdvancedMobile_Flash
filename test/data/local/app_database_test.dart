import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flash/data/local/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<int> count(String table) async {
    final r = await db.customSelect('SELECT COUNT(*) AS c FROM $table').getSingle();
    return r.read<int>('c');
  }

  test('tạo đủ 25 bảng', () async {
    final rows = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'")
        .get();
    expect(rows.length, 25);
  });

  test('foreign_keys được bật', () async {
    final r = await db.customSelect('PRAGMA foreign_keys').getSingle();
    expect(r.read<int>('foreign_keys'), 1);
  });

  test('clearUserData chỉ xoá nhóm B, C và giữ content cache', () async {
    await db.customStatement(
        "INSERT INTO topics (id, title, icon_path, server_updated_at) VALUES ('t1', 'Daily Life', 'x', 1)");
    await db.customStatement(
        "INSERT INTO flashcards (id, topic_id, word, part_of_speech, pronunciation, meaning, server_updated_at) "
        "VALUES ('f1', 't1', 'beautiful', 'adj.', '/b/', 'đẹp', 1)");
    await db.customStatement(
        "INSERT INTO leaderboard_cache (board, rank_no, user_id, full_name, score, fetched_at) "
        "VALUES ('XP', 1, 'u1', 'A', 10, 1)");
    await db.customStatement("INSERT INTO user_profile (id, email, full_name) VALUES ('u1', 'a@b.c', 'A')");
    await db.customStatement(
        "INSERT INTO flashcard_review_logs (id, flashcard_id, rating, box_before, box_after, reviewed_at) "
        "VALUES ('l1', 'f1', 'KNOW', 0, 1, 1)");
    await db.customStatement(
        "INSERT INTO sync_queue (op_id, op_type, entity_table, entity_id, payload, created_at) "
        "VALUES ('o1', 'FLASHCARD_REVIEW', 'flashcard_review_logs', 'l1', '{}', 1)");
    await db.customStatement("INSERT INTO sync_meta (scope, server_cursor) VALUES ('content', 'c')");

    await db.clearUserData();

    for (final t in ['user_profile', 'flashcard_review_logs', 'sync_queue', 'sync_meta']) {
      expect(await count(t), 0, reason: t);
    }
    expect(await count('topics'), 1);
    expect(await count('flashcards'), 1);
    expect(await count('leaderboard_cache'), 1);
  });

  test('xoá flashcard thì progress/log/note đi theo (ON DELETE CASCADE)', () async {
    await db.customStatement(
        "INSERT INTO topics (id, title, icon_path, server_updated_at) VALUES ('t1', 'T', 'x', 1)");
    await db.customStatement(
        "INSERT INTO flashcards (id, topic_id, word, part_of_speech, pronunciation, meaning, server_updated_at) "
        "VALUES ('f1', 't1', 'w', 'n.', '/w/', 'm', 1)");
    await db.customStatement("INSERT INTO user_bookmarks (flashcard_id, created_at, client_updated_at) VALUES ('f1', 1, 1)");
    await db.customStatement('DELETE FROM flashcards WHERE id = ?', ['f1']);
    expect(await count('user_bookmarks'), 0);
  });
}
