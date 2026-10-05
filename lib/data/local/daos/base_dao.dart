import 'package:drift/drift.dart';

import '../app_database.dart' show AppDatabase;

/// Dart value -> biến SQL. Bool ghi thành 0/1 như schema.
Variable sqlVar(Object? v) {
  if (v == null) return const Variable<String>(null);
  if (v is bool) return Variable<int>(v ? 1 : 0);
  if (v is int) return Variable<int>(v);
  if (v is double) return Variable<double>(v);
  if (v is num) return Variable<double>(v.toDouble());
  return Variable<String>(v.toString());
}

/// Các DAO viết SQL thuần (giống [SyncDao]) để không phụ thuộc tên lớp Drift sinh ra,
/// vốn trùng tên với model ở `lib/models/` (Topic, Flashcard, RewardItem...).
///
/// Ghi luôn khai báo `updates` và đọc khai báo `readsFrom` để `.watch()` tự phát lại.
abstract class BaseDao {
  BaseDao(this.db);

  final AppDatabase db;

  TableInfo table(String name) => db.allTables.firstWhere((t) => t.actualTableName == name);

  Set<TableInfo> tables(Iterable<String> names) => names.map(table).toSet();

  Selectable<QueryRow> select(String sql, [List<Object?> args = const [], Iterable<String> readsFrom = const []]) =>
      db.customSelect(sql, variables: args.map(sqlVar).toList(), readsFrom: tables(readsFrom));

  Future<int> update(String sql, List<Object?> args, Iterable<String> touched) =>
      db.customUpdate(sql, variables: args.map(sqlVar).toList(), updates: tables(touched));

  /// `INSERT ... ON CONFLICT(pk) DO UPDATE`. Không dùng `INSERT OR REPLACE`: REPLACE xoá dòng cũ
  /// và kéo theo ON DELETE CASCADE (VD thay một topic sẽ xoá sạch flashcard + tiến độ của nó).
  Future<void> upsert(String tableName, Map<String, Object?> row, List<String> pk) async {
    final cols = row.keys.toList();
    final set = cols.where((c) => !pk.contains(c)).map((c) => '$c = excluded.$c').join(', ');
    final sql = 'INSERT INTO $tableName (${cols.join(', ')}) VALUES (${List.filled(cols.length, '?').join(', ')}) '
        'ON CONFLICT(${pk.join(', ')}) DO ${set.isEmpty ? 'NOTHING' : 'UPDATE SET $set'}';
    await db.customInsert(sql, variables: row.values.map(sqlVar).toList(), updates: {table(tableName)});
  }

  Future<int> insertIgnore(String tableName, Map<String, Object?> row) {
    final cols = row.keys.toList();
    return db.customInsert(
      'INSERT OR IGNORE INTO $tableName (${cols.join(', ')}) VALUES (${List.filled(cols.length, '?').join(', ')})',
      variables: row.values.map(sqlVar).toList(),
      updates: {table(tableName)},
    );
  }

  Future<int> deleteWhere(String tableName, String where, List<Object?> args) => db.customUpdate(
        'DELETE FROM $tableName WHERE $where',
        variables: args.map(sqlVar).toList(),
        updates: {table(tableName)},
        updateKind: UpdateKind.delete,
      );

  Future<Set<String>> ids(String tableName, [String column = 'id']) async {
    final rows = await db.customSelect('SELECT $column AS v FROM $tableName').get();
    return rows.map((r) => r.read<String>('v')).toSet();
  }
}

extension QueryRowX on QueryRow {
  int i(String c) => read<int>(c);
  int? iN(String c) => readNullable<int>(c);
  String s(String c) => read<String>(c);
  String? sN(String c) => readNullable<String>(c);
  bool b(String c) => readNullable<int>(c) == 1;
  double d(String c) => readNullable<double>(c) ?? 0;
}
