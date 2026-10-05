import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flash/data/storage/app_prefs.dart';
import 'package:flash/data/storage/secure_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SecureStore', () {
    setUp(() => FlutterSecureStorage.setMockInitialValues({}));

    test('lưu và đọc phiên, expiresAt giữ nguyên tới mili giây', () async {
      final s = SecureStore();
      final exp = DateTime.utc(2026, 10, 5, 8, 15, 30, 123);
      await s.saveSession(accessToken: 'a', refreshToken: 'r', accessExpiresAt: exp, userId: 'u', role: 'ADMIN');

      expect(await s.accessToken(), 'a');
      expect(await s.refreshToken(), 'r');
      expect(await s.userId(), 'u');
      expect(await s.userRole(), 'ADMIN');
      expect(await s.accessTokenExpiresAt(), exp);
    });

    test('deviceId sinh một lần và sống sót qua clearSession', () async {
      final s = SecureStore();
      final id = await s.deviceId();
      expect(await s.deviceId(), id);

      await s.saveSession(accessToken: 'a', refreshToken: 'r', accessExpiresAt: DateTime.now(), userId: 'u', role: 'USER');
      await s.clearSession();

      expect(await s.refreshToken(), isNull);
      expect(await s.userRole(), isNull);
      expect(await s.deviceId(), id);
    });
  });

  group('AppPrefs', () {
    test('giá trị mặc định đúng §4.3', () async {
      SharedPreferences.setMockInitialValues({});
      final p = AppPrefs.fromInstance(await SharedPreferences.getInstance());
      expect(p.isDarkMode, false);
      expect(p.isSoundEnabled, true);
      expect(p.appLanguage, 'vi');
      expect(p.dailyReminderTime, '20:00');
      expect(p.dailyGoalLessons, 5);
      expect(p.onboardingCompleted, false);
      expect(p.lastSyncedTimestamp, 0);
    });

    test('resetUserScoped chỉ xoá phần gắn tài khoản, giữ cài đặt UI', () async {
      SharedPreferences.setMockInitialValues({});
      final p = AppPrefs.fromInstance(await SharedPreferences.getInstance());
      await p.setDarkMode(true);
      await p.setLocalDbOwnerUserId('u1');
      await p.setLastSyncedTimestamp(123);

      await p.resetUserScoped();

      expect(p.localDbOwnerUserId, isNull);
      expect(p.lastSyncedTimestamp, 0);
      expect(p.isDarkMode, true);
    });
  });
}
