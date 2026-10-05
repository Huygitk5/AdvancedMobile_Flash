import 'package:dio/dio.dart';
import 'package:flutter/material.dart' show ThemeMode;

import '../../core/clock.dart';
import '../../core/ids.dart';
import '../../core/l10n.dart';
import '../../core/speech.dart';
import '../../core/theme.dart';
import '../../models/_json.dart';
import '../../models/leaderboard_model.dart';
import '../../models/quest_model.dart';
import '../../models/reward_item_model.dart';
import '../local/app_database.dart' show AppDatabase;
import '../local/converters.dart';
import '../remote/api_exception.dart';
import '../remote/apis/gamification_api.dart';
import '../remote/apis/user_api.dart';
import '../storage/app_prefs.dart';
import '../storage/secure_store.dart';
import '../sync/pull_service.dart';
import 'base_repository.dart';

/// ChallengeScreen: nhận thưởng -> QUEST_CLAIM; giao nhiệm vụ đầu ngày cần online.
class QuestRepository extends WriteRepository {
  QuestRepository(super.db, super.kick, this._api, this._pull);

  final GamificationApi _api;
  final PullService _pull;

  Future<void> claim(Quest quest) async {
    final at = now();
    await db.transaction(() async {
      await db.questDao.setClaimed(quest.id, true, at.toUtc().millisecondsSinceEpoch);
      await db.profileDao.addPendingXp(quest.xp);
      await db.syncDao.enqueue(
        opType: 'QUEST_CLAIM',
        entityTable: 'user_quests',
        entityId: quest.id,
        payload: {'userQuestId': quest.id, 'claimedAt': isoNow(at)},
      );
    });
    kick();
  }

  /// Lần đầu trong ngày chưa có nhiệm vụ local: gọi `/v1/quests/today` (server tự giao) rồi pull.
  /// Lỗi mạng bỏ qua (offline thì dùng những gì đang có).
  Future<void> ensureToday() async {
    if (await db.questDao.countForPeriod(localDateKey(now())) > 0) return;
    try {
      await _api.todayQuests();
      await _pull.pullUserData();
    } on NetworkException {
      // offline
    }
  }
}

/// Kết quả mua: xong ngay, hoặc đang chờ (mất mạng sau khi đã gửi).
enum PurchaseState { done, pending }

/// ShopScreen / ProfileScreen. Mua chỉ online; trang bị -> ITEM_EQUIP.
class ShopRepository extends WriteRepository {
  ShopRepository(super.db, super.kick, this._api);

  final GamificationApi _api;

  /// Trạng thái `canAfford` / `meetsRankRequirement` theo server (chỉ online). null khi offline.
  Future<Map<String, RewardItem>?> onlineStatus() async {
    try {
      final items = await _api.shopItems();
      return {for (final i in items) i.id: i};
    } on NetworkException {
      return null;
    }
  }

  /// Ném [ApiException] (409 INSUFFICIENT_XP / ALREADY_OWNED, 403 RANK_REQUIREMENT_NOT_MET),
  /// [NetworkException] khi chưa gửi được (không có mạng).
  Future<PurchaseState> purchase(RewardItem item) async {
    final key = newId();
    try {
      final res = await _api.purchase(item.id, key);
      final nowMs = Clock.nowMs();
      await db.transaction(() async {
        await db.shopDao.applyInventory(res['inventory'] as Map<String, dynamic>, nowMs: nowMs);
        await db.profileDao.setXp(currentXp: jInt(res['currentXp']));
      });
      return PurchaseState.done;
    } on NetworkException catch (e) {
      final type = e.cause?.type;
      final notSent = type == DioExceptionType.connectionError || type == DioExceptionType.connectionTimeout;
      if (notSent) rethrow;
      // Có thể server đã nhận: gửi lại qua sync với CÙNG Idempotency-Key, không trừ XP lạc quan.
      await db.syncDao.enqueue(
        opType: 'SHOP_PURCHASE',
        entityTable: 'reward_items',
        entityId: item.id,
        payload: {'rewardItemId': item.id},
        opId: key,
      );
      kick();
      return PurchaseState.pending;
    }
  }

  Future<void> setEquipped(RewardItem item, bool equipped) async {
    final inventoryId = item.inventoryId;
    if (inventoryId == null) return;
    final at = now();
    await db.transaction(() async {
      await db.shopDao.equipLocal(inventoryId, equipped, at.toUtc().millisecondsSinceEpoch);
      await db.syncDao.enqueue(
        opType: 'ITEM_EQUIP',
        entityTable: 'user_inventories',
        entityId: inventoryId,
        payload: {'inventoryId': inventoryId, 'equipped': equipped, 'clientUpdatedAt': isoNow(at)},
      );
    });
    kick();
  }
}

/// ProfileScreen: đổi slogan -> PROFILE_UPDATE.
class ProfileRepository extends WriteRepository {
  ProfileRepository(super.db, super.kick);

  Future<void> updateSlogan(String slogan) async {
    final at = now();
    await db.transaction(() async {
      final userId = await db.profileDao.userId();
      if (userId == null) return;
      final base = await db.profileDao.updateProfileLocal(slogan: slogan, nowMs: at.toUtc().millisecondsSinceEpoch);
      await db.syncDao.enqueue(
        opType: 'PROFILE_UPDATE',
        entityTable: 'user_profile',
        entityId: userId,
        payload: {'slogan': slogan, 'baseVersion': base, 'clientUpdatedAt': isoNow(at)},
      );
    });
    kick();
  }
}

/// SettingsScreen: cài đặt lưu ở AppPrefs (đọc đồng bộ) + SETTINGS_UPDATE; đổi mật khẩu chỉ online.
class SettingsRepository extends WriteRepository {
  SettingsRepository(super.db, super.kick, this.prefs, this._userApi, this._store);

  final AppPrefs prefs;
  final UserApi _userApi;
  final SecureStore _store;

  Future<void> setNotification(bool v) => _change(() => prefs.setNotificationEnabled(v));
  Future<void> setSound(bool v) {
    SpeechService.soundEnabled = v;
    if (!v) SpeechService.stop();
    return _change(() => prefs.setSoundEnabled(v));
  }

  Future<void> setVibration(bool v) => _change(() => prefs.setVibrationEnabled(v));

  /// Đổi ngôn ngữ giao diện ngay lập tức (FlashApp dựng lại cây widget), lưu trên máy và đồng bộ lên server.
  Future<void> setLanguage(String v) {
    AppLocale.apply(v);
    return _change(() => prefs.setAppLanguage(v));
  }
  Future<void> setReminderTime(String hhmm) => _change(() => prefs.setDailyReminderTime(hhmm));
  Future<void> setDailyGoal(int lessons) => _change(() => prefs.setDailyGoalLessons(lessons));

  Future<void> setDarkMode(bool v) async {
    themeNotifier.value = v ? ThemeMode.dark : ThemeMode.light;
    await _change(() => prefs.setDarkMode(v));
  }

  /// `UserSettingsResponse` từ server (pull hoặc kết quả SETTINGS_UPDATE).
  Future<void> applyServer(Map<String, dynamic> s) async {
    if (s['isNotificationEnabled'] is bool) await prefs.setNotificationEnabled(s['isNotificationEnabled'] as bool);
    if (s['isSoundEnabled'] is bool) {
      await prefs.setSoundEnabled(s['isSoundEnabled'] as bool);
      SpeechService.soundEnabled = prefs.isSoundEnabled;
    }
    if (s['isVibrationEnabled'] is bool) await prefs.setVibrationEnabled(s['isVibrationEnabled'] as bool);
    if (s['isDarkMode'] is bool) {
      await prefs.setDarkMode(s['isDarkMode'] as bool);
      themeNotifier.value = prefs.isDarkMode ? ThemeMode.dark : ThemeMode.light;
    }
    if (s['appLanguage'] is String) {
      await prefs.setAppLanguage(s['appLanguage'] as String);
      AppLocale.apply(prefs.appLanguage);
    }
    if (s['dailyReminderTime'] is String) {
      final t = s['dailyReminderTime'] as String;
      await prefs.setDailyReminderTime(t.length >= 5 ? t.substring(0, 5) : t);
    }
    if (s['dailyGoalLessons'] is num) await prefs.setDailyGoalLessons((s['dailyGoalLessons'] as num).toInt());
  }

  /// Gửi OTP xác nhận đổi mật khẩu tới email của tài khoản (chỉ online).
  Future<void> requestChangePasswordOtp() => _userApi.requestChangePasswordOtp();

  /// `hasPassword` của tài khoản (Google-only thì không cần mật khẩu cũ). Lỗi mạng ném [NetworkException].
  Future<bool> hasPassword() async => jBool((await _userApi.me())['hasPassword'], true);

  /// Trả cặp token mới; lưu ngay (mọi refresh token cũ đã bị thu hồi).
  Future<void> changePassword({String? currentPassword, required String newPassword, String? otp}) async {
    final auth = await _userApi.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      otp: otp,
      deviceId: await _store.deviceId(),
    );
    await _store.saveTokens(
      accessToken: auth.accessToken,
      refreshToken: auth.refreshToken,
      accessExpiresAt: Clock.now().toUtc().add(Duration(seconds: auth.expiresIn)),
    );
  }

  Future<void> _change(Future<void> Function() write) async {
    await write();
    final at = now();
    await db.transaction(() async {
      final userId = await db.profileDao.userId();
      if (userId == null) return;
      await db.syncDao.enqueue(
        opType: 'SETTINGS_UPDATE',
        entityTable: 'user_settings',
        entityId: userId,
        payload: {
          'isNotificationEnabled': prefs.isNotificationEnabled,
          'isSoundEnabled': prefs.isSoundEnabled,
          'isVibrationEnabled': prefs.isVibrationEnabled,
          'isDarkMode': prefs.isDarkMode,
          'appLanguage': prefs.appLanguage,
          'dailyReminderTime': prefs.dailyReminderTime,
          'dailyGoalLessons': prefs.dailyGoalLessons,
          'clientUpdatedAt': isoNow(at),
        },
      );
    });
    kick();
  }
}

/// LeaderboardScreen: cache TTL 5 phút ở `leaderboard_cache`.
class LeaderboardRepository {
  LeaderboardRepository(this._db, this._api);

  final AppDatabase _db;
  final GamificationApi _api;

  /// "Hạng của bạn" không có cột trong cache: giữ bản gần nhất trong bộ nhớ.
  final Map<String, Leaderboard> _last = {};

  static const ttl = Duration(minutes: 5);

  /// [board]: 'XP' | 'STREAK'. Quá TTL (hoặc [force]) thì gọi API; lỗi mạng trả bản cache.
  Future<Leaderboard?> load(String board, {bool force = false}) async {
    final mem = _last[board];
    if (!force && mem?.fetchedAt != null && Clock.now().toUtc().difference(mem!.fetchedAt!) < ttl) return mem;
    final cached = await _db.leaderboardDao.cached(board);
    final fresh = cached?.fetchedAt != null && Clock.now().toUtc().difference(cached!.fetchedAt!) < ttl;
    if (fresh && !force) return cached;
    try {
      final lb = await _api.leaderboard(board.toLowerCase());
      await _db.leaderboardDao.replace(board, lb.items, Clock.nowMs());
      return _last[board] = lb;
    } on NetworkException {
      return mem ?? cached;
    }
  }
}
