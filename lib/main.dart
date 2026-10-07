import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/config.dart';
import 'core/l10n.dart';
import 'core/speech.dart';
import 'core/theme.dart';
import 'data/local/app_database.dart';
import 'data/sync/background_sync.dart';
import 'data/widget/home_widget_service.dart';
import 'data/storage/app_prefs.dart';
import 'providers/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Đọc cài đặt TRƯỚC runApp để theme đúng ngay khung hình đầu tiên (không bị nháy).
  final prefs = await AppPrefs.load();
  themeNotifier.value = prefs.isDarkMode ? ThemeMode.dark : ThemeMode.light;
  AppLocale.apply(prefs.appLanguage);
  SpeechService.soundEnabled = prefs.isSoundEnabled;
  // Địa chỉ máy chủ người dùng tự nhập (nếu có) phải nạp trước khi dựng ApiClient.
  await AppConfig.load();

  final db = AppDatabase();
  await BackgroundSync.initialize();
  await HomeWidgetService.init();
  HomeWidgetService.watch(db);
  unawaited(HomeWidgetService.refresh(db)); // cập nhật widget ngay khi mở app

  runApp(ProviderScope(
    overrides: [
      appPrefsProvider.overrideWithValue(prefs),
      dbProvider.overrideWithValue(db),
    ],
    child: const FlashApp(),
  ));
}
