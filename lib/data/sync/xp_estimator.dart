/// Chép luật `XpRules` của server để ƯỚC LƯỢNG XP hiển thị ngay (cột `user_profile.pending_xp`).
/// Không bao giờ gửi số này lên server: server tự tính XP (DATA_ARCHITECTURE.md §5.3d).
class XpEstimator {
  const XpEstimator._();

  /// Know một thẻ, lần đầu trong ngày với thẻ đó; tối đa 300 XP/ngày.
  static const knowXp = 2;
  static const knowDailyCap = 300;

  /// Thẻ chuyển sang "đã thuộc" lần đầu.
  static const learnedXp = 5;

  /// Chỉ 20 bài đầu tiên mỗi ngày được tính XP; học lại cùng một bài trong ngày không được cộng lần nữa.
  static const lessonXp = 10;
  static const lessonDailyXpLimit = 20;

  /// Quiz: mỗi câu đúng, +10 nếu 100%; chỉ lần làm đầu tiên trong ngày của mỗi quiz.
  static const quizCorrectXp = 2;
  static const quizPerfectBonus = 10;

  static int review({
    required bool isKnow,
    required bool firstKnowOfCardToday,
    required int knowXpToday,
    required bool becameLearnedFirstTime,
  }) {
    var xp = 0;
    if (isKnow && firstKnowOfCardToday && knowXpToday + knowXp <= knowDailyCap) xp += knowXp;
    if (becameLearnedFirstTime) xp += learnedXp;
    return xp;
  }

  /// [lessonsBeforeToday] = số bài đã hoàn thành hôm nay TRƯỚC bài này;
  /// [sameLessonToday] = bài này (cùng topic / chủ điểm) đã hoàn thành trước đó trong hôm nay.
  static int lesson({required int lessonsBeforeToday, bool sameLessonToday = false}) =>
      !sameLessonToday && lessonsBeforeToday < lessonDailyXpLimit ? lessonXp : 0;

  static int quiz({required int correct, required int total, required bool firstAttemptToday}) {
    if (!firstAttemptToday) return 0;
    return correct * quizCorrectXp + (total > 0 && correct == total ? quizPerfectBonus : 0);
  }
}
