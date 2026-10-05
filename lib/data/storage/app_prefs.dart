import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cài đặt UI nhỏ, đọc đồng bộ (DATA_ARCHITECTURE.md §4.3).
/// Phải `await AppPrefs.load()` trong `main()` TRƯỚC `runApp` để theme không bị nháy.
class AppPrefs {
  AppPrefs._(this._p);

  final SharedPreferences _p;

  static Future<AppPrefs> load() async => AppPrefs._(await SharedPreferences.getInstance());

  @visibleForTesting
  static AppPrefs fromInstance(SharedPreferences p) => AppPrefs._(p);

  static const _kDarkMode = 'is_dark_mode';
  static const _kSound = 'is_sound_enabled';
  static const _kVibration = 'is_vibration_enabled';
  static const _kNotification = 'is_notification_enabled';
  static const _kLanguage = 'app_language';
  static const _kReminderTime = 'daily_reminder_time';
  static const _kReminderShown = 'reminder_dialog_last_shown';
  static const _kDailyGoal = 'daily_goal_lessons';
  static const _kOnboarding = 'onboarding_completed';
  static const _kLastEmail = 'last_login_email';
  static const _kLastSynced = 'last_synced_timestamp';
  static const _kDbOwner = 'local_db_owner_user_id';

  bool get isDarkMode => _p.getBool(_kDarkMode) ?? false;
  Future<void> setDarkMode(bool v) => _p.setBool(_kDarkMode, v);

  bool get isSoundEnabled => _p.getBool(_kSound) ?? true;
  Future<void> setSoundEnabled(bool v) => _p.setBool(_kSound, v);

  bool get isVibrationEnabled => _p.getBool(_kVibration) ?? true;
  Future<void> setVibrationEnabled(bool v) => _p.setBool(_kVibration, v);

  bool get isNotificationEnabled => _p.getBool(_kNotification) ?? true;
  Future<void> setNotificationEnabled(bool v) => _p.setBool(_kNotification, v);

  /// 'vi' | 'en'
  String get appLanguage => _p.getString(_kLanguage) ?? 'vi';
  Future<void> setAppLanguage(String v) => _p.setString(_kLanguage, v);

  /// 'HH:mm'
  String get dailyReminderTime => _p.getString(_kReminderTime) ?? '20:00';
  Future<void> setDailyReminderTime(String v) => _p.setString(_kReminderTime, v);

  /// 'YYYY-MM-DD', để mỗi ngày chỉ hiện ReminderDialog một lần.
  String? get reminderDialogLastShown => _p.getString(_kReminderShown);
  Future<void> setReminderDialogLastShown(String v) => _p.setString(_kReminderShown, v);

  int get dailyGoalLessons => _p.getInt(_kDailyGoal) ?? 5;
  Future<void> setDailyGoalLessons(int v) => _p.setInt(_kDailyGoal, v);

  bool get onboardingCompleted => _p.getBool(_kOnboarding) ?? false;
  Future<void> setOnboardingCompleted(bool v) => _p.setBool(_kOnboarding, v);

  String? get lastLoginEmail => _p.getString(_kLastEmail);
  Future<void> setLastLoginEmail(String v) => _p.setString(_kLastEmail, v);

  /// Chỉ để HIỂN THỊ "Đồng bộ lần cuối". Con trỏ pull thật nằm ở `sync_meta` (SQLite).
  int get lastSyncedTimestamp => _p.getInt(_kLastSynced) ?? 0;
  Future<void> setLastSyncedTimestamp(int ms) => _p.setInt(_kLastSynced, ms);

  /// user_id sở hữu dữ liệu đang nằm trong SQLite. Khác user_id lúc đăng nhập thì phải xoá dữ liệu user.
  String? get localDbOwnerUserId => _p.getString(_kDbOwner);
  Future<void> setLocalDbOwnerUserId(String v) => _p.setString(_kDbOwner, v);

  /// Đăng xuất: xoá phần gắn với tài khoản, giữ cài đặt UI.
  Future<void> resetUserScoped() async {
    await _p.remove(_kDbOwner);
    await _p.remove(_kLastSynced);
  }
}
