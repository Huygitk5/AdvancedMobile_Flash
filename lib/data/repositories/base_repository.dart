import '../../core/clock.dart';
import '../local/app_database.dart' show AppDatabase;
import '../local/converters.dart';

/// Khuôn chung của repository ghi (G8): **ghi = 1 transaction (dữ liệu lạc quan + enqueue)**, rồi `kick()`.
abstract class WriteRepository {
  WriteRepository(this.db, this.kick);

  final AppDatabase db;

  /// `SyncWorker.kick` (debounce ~2 giây).
  final void Function() kick;

  /// [start, end) của ngày địa phương chứa [at], tính bằng epoch ms UTC.
  static (int, int) dayBounds(DateTime at) {
    final l = at.toLocal();
    final start = DateTime(l.year, l.month, l.day);
    final end = DateTime(l.year, l.month, l.day + 1);
    return (start.toUtc().millisecondsSinceEpoch, end.toUtc().millisecondsSinceEpoch);
  }

  /// Hoạt động học đầu tiên trong ngày thì tăng nhiệm vụ KEEP_STREAK (giống `ActivityRecorder` ở server).
  /// Gọi TRƯỚC khi cộng `daily_statistics` của thao tác hiện tại.
  Future<void> recordActivity(DateTime at) async {
    final today = await db.statsDao.watchDay(localDateKey(at)).first;
    final active = today != null &&
        (today.cardsReviewed + today.lessonsCompleted + today.quizzesCompleted) > 0;
    if (!active) await db.questDao.bump('KEEP_STREAK', 1, at);
  }

  DateTime now() => Clock.now();
}
