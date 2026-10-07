import 'package:flutter/foundation.dart';

/// Nguồn thời gian duy nhất của app, để test có thể "đóng băng" giờ.
/// Mọi nơi cần giờ hiện tại phải gọi `Clock.now()` thay vì `DateTime.now()`.
class Clock {
  const Clock._();

  static DateTime Function() _now = DateTime.now;

  static DateTime now() => _now();

  /// Epoch milliseconds UTC, đúng định dạng cột thời gian của SQLite (client_sqlite.sql).
  static int nowMs() => _now().toUtc().millisecondsSinceEpoch;

  @visibleForTesting
  static void override(DateTime Function()? fn) => _now = fn ?? DateTime.now;
}
