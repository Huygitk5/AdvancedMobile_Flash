import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flash/app.dart';
import 'package:flash/data/local/app_database.dart';
import 'package:flash/data/storage/app_prefs.dart';
import 'package:flash/data/storage/secure_store.dart';
import 'package:flash/providers/providers.dart';
import 'package:flash/screens/admin/admin_main_screen.dart';
import 'package:flash/screens/auth/login_screen.dart';
import 'package:flash/screens/splash/welcome_screen.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester, {Map<String, String> secure = const {}, Map<String, Object> prefs = const {}}) async {
    // Kích thước điện thoại (mặc định 800x600 làm Welcome bị tràn).
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    FlutterSecureStorage.setMockInitialValues(Map.of(secure));
    SharedPreferences.setMockInitialValues(Map.of(prefs));
    final appPrefs = AppPrefs.fromInstance(await SharedPreferences.getInstance());
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        appPrefsProvider.overrideWithValue(appPrefs),
        dbProvider.overrideWithValue(db),
      ],
      child: const FlashApp(),
    ));
    await tester.pump();
    await tester.pump();
  }

  testWidgets('chưa đăng nhập: StartGate mở WelcomeScreen', (tester) async {
    await pumpApp(tester);
    expect(find.byType(WelcomeScreen), findsOneWidget);
  });

  testWidgets('đã qua Welcome: mở thẳng LoginScreen, không có nút back', (tester) async {
    await pumpApp(tester, prefs: {'onboarding_completed': true});
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_ios_new), findsNothing);
  });

  testWidgets('phiên ADMIN đã lưu: vào thẳng AdminMainScreen (không cần mạng)', (tester) async {
    await pumpApp(tester, secure: {
      SecureStore.kRefreshToken: 'rt',
      SecureStore.kUserId: 'admin-1',
      SecureStore.kUserRole: 'ADMIN',
    });
    expect(find.byType(AdminMainScreen), findsOneWidget);
    // Dashboard gọi API: trong test không có server nên hiện lỗi rõ ràng thay vì treo.
    await tester.pump(const Duration(seconds: 1));
  });
}
