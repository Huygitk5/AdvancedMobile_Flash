/// Bản Dart của `SrsService.replay` phía server (Leitner, DATA_ARCHITECTURE.md §5.2).
/// Client dùng để cập nhật lạc quan `user_flashcard_progress`; server luôn tính lại và ghi đè.
///
/// - Know:  box = min(box + 1, 5), due = reviewedAt + intervals[box]
/// - Again: box = max(box - 2, 0), due = reviewedAt + 10 phút
/// - is_learned = box >= 3 (có thể rớt lại nếu có log AGAIN đến muộn)
class Srs {
  const Srs._();

  static const maxBox = 5;
  static const learnedBox = 3;
  static const againBoxDrop = 2;
  static const againDelay = Duration(minutes: 10);

  /// Khoảng ôn lại theo box 0..5: ngay, 1, 3, 7, 14, 30 ngày.
  static const intervals = [
    Duration.zero,
    Duration(days: 1),
    Duration(days: 3),
    Duration(days: 7),
    Duration(days: 14),
    Duration(days: 30),
  ];

  /// Phát lại TOÀN BỘ log của một thẻ theo thứ tự thời gian (log đến muộn được xếp đúng chỗ).
  static SrsState replay(Iterable<SrsLog> logs) {
    final sorted = logs.toList()..sort((a, b) => a.reviewedAt.compareTo(b.reviewedAt));
    var box = 0, again = 0, know = 0;
    DateTime? dueAt;
    SrsLog? last;
    final boxes = <String, (int, int)>{};
    for (final log in sorted) {
      final before = box;
      if (log.isKnow) {
        box = box + 1 > maxBox ? maxBox : box + 1;
        know++;
        dueAt = log.reviewedAt.add(intervals[box]);
      } else {
        box = box - againBoxDrop < 0 ? 0 : box - againBoxDrop;
        again++;
        dueAt = log.reviewedAt.add(againDelay);
      }
      boxes[log.id] = (before, box);
      last = log;
    }
    return SrsState(
      box: box,
      repetitions: sorted.length,
      againCount: again,
      knowCount: know,
      lastRating: last?.rating,
      lastReviewedAt: last?.reviewedAt,
      dueAt: dueAt,
      isLearned: box >= learnedBox,
      boxes: boxes,
    );
  }
}

class SrsLog {
  const SrsLog({required this.id, required this.rating, required this.reviewedAt});

  final String id;

  /// 'AGAIN' | 'KNOW'
  final String rating;
  final DateTime reviewedAt;

  bool get isKnow => rating == 'KNOW';
}

class SrsState {
  const SrsState({
    required this.box,
    required this.repetitions,
    required this.againCount,
    required this.knowCount,
    required this.lastRating,
    required this.lastReviewedAt,
    required this.dueAt,
    required this.isLearned,
    required this.boxes,
  });

  final int box;
  final int repetitions;
  final int againCount;
  final int knowCount;
  final String? lastRating;
  final DateTime? lastReviewedAt;
  final DateTime? dueAt;
  final bool isLearned;

  /// logId -> (box_before, box_after) sau khi phát lại.
  final Map<String, (int, int)> boxes;
}
