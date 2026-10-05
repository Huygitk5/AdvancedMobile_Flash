import 'package:flutter_test/flutter_test.dart';
import 'package:flash/data/sync/srs.dart';
import 'package:flash/data/sync/xp_estimator.dart';

/// Cùng các ca của `SrsReplayTest` ở backend (Leitner §5.2, phát lại log đến muộn §5.3c).
void main() {
  final t0 = DateTime.utc(2026, 10, 1, 8);
  var seq = 0;
  SrsLog log(String rating, DateTime at) => SrsLog(id: 'l${seq++}', rating: rating, reviewedAt: at);

  test('Know lên 1 box, hạn ôn theo khoảng của box mới', () {
    final logs = [
      log('KNOW', t0),
      log('KNOW', t0.add(const Duration(days: 1))),
      log('KNOW', t0.add(const Duration(days: 4))),
    ];
    final s = Srs.replay(logs);
    expect(s.box, 3);
    expect(s.isLearned, isTrue);
    expect(s.dueAt, t0.add(const Duration(days: 4 + 7)));
    expect(s.knowCount, 3);
    expect(s.repetitions, 3);
    expect(logs.map((l) => s.boxes[l.id]!.$1), [0, 1, 2]);
    expect(logs.map((l) => s.boxes[l.id]!.$2), [1, 2, 3]);
  });

  test('box tối đa 5; Again tụt 2 box và hẹn lại sau 10 phút', () {
    final logs = [for (var i = 0; i < 7; i++) log('KNOW', t0.add(Duration(days: i)))];
    expect(Srs.replay(logs).box, 5);

    final againAt = t0.add(const Duration(days: 10));
    logs.add(log('AGAIN', againAt));
    final s = Srs.replay(logs);
    expect(s.box, 3);
    expect(s.dueAt, againAt.add(const Duration(minutes: 10)));
    expect(s.lastRating, 'AGAIN');
    expect(s.againCount, 1);
  });

  test('Again không bao giờ xuống dưới 0', () {
    final s = Srs.replay([log('KNOW', t0), log('AGAIN', t0.add(const Duration(seconds: 60)))]);
    expect(s.box, 0);
    expect(s.isLearned, isFalse);
  });

  test('log đến muộn (máy khác) được phát lại đúng thứ tự thời gian', () {
    final a1 = log('KNOW', t0);
    final a2 = log('KNOW', t0.add(const Duration(days: 2)));
    expect(Srs.replay([a1, a2]).box, 2);

    final lateFromB = log('AGAIN', t0.add(const Duration(days: 1)));
    // Truyền không theo thứ tự: replay tự sắp xếp.
    final s = Srs.replay([a1, a2, lateFromB]);
    // KNOW(0->1), AGAIN(1->0), KNOW(0->1)
    expect(s.box, 1);
    expect(s.boxes[a2.id]!.$1, 0);
    expect(s.lastRating, 'KNOW');
    expect(s.lastReviewedAt, a2.reviewedAt);
    expect(s.dueAt, a2.reviewedAt.add(const Duration(days: 1)));
  });

  group('XpEstimator (chép XpRules)', () {
    test('Know lần đầu trong ngày +2, thẻ thành đã thuộc lần đầu +5, chạm trần 300/ngày', () {
      expect(XpEstimator.review(isKnow: true, firstKnowOfCardToday: true, knowXpToday: 0, becameLearnedFirstTime: false), 2);
      expect(XpEstimator.review(isKnow: true, firstKnowOfCardToday: false, knowXpToday: 0, becameLearnedFirstTime: false), 0);
      expect(XpEstimator.review(isKnow: true, firstKnowOfCardToday: true, knowXpToday: 0, becameLearnedFirstTime: true), 7);
      expect(XpEstimator.review(isKnow: true, firstKnowOfCardToday: true, knowXpToday: 300, becameLearnedFirstTime: false), 0);
      expect(XpEstimator.review(isKnow: false, firstKnowOfCardToday: false, knowXpToday: 0, becameLearnedFirstTime: false), 0);
    });

    test('bài học +10 cho 20 bài đầu mỗi ngày', () {
      expect(XpEstimator.lesson(lessonsBeforeToday: 0), 10);
      expect(XpEstimator.lesson(lessonsBeforeToday: 19), 10);
      expect(XpEstimator.lesson(lessonsBeforeToday: 20), 0);
    });

    test('quiz +2/câu đúng, +10 khi 100%, chỉ lần đầu trong ngày', () {
      expect(XpEstimator.quiz(correct: 3, total: 5, firstAttemptToday: true), 6);
      expect(XpEstimator.quiz(correct: 5, total: 5, firstAttemptToday: true), 20);
      expect(XpEstimator.quiz(correct: 5, total: 5, firstAttemptToday: false), 0);
    });
  });
}
