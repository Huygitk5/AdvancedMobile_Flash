import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/theme.dart';
import 'data/local/app_database.dart';
import 'data/sync/background_sync.dart';
import 'data/storage/app_prefs.dart';
import 'providers/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Đọc cài đặt TRƯỚC runApp để theme đúng ngay khung hình đầu tiên (không bị nháy).
  final prefs = await AppPrefs.load();
  themeNotifier.value = prefs.isDarkMode ? ThemeMode.dark : ThemeMode.light;

  final db = AppDatabase();
  await BackgroundSync.initialize();

  runApp(ProviderScope(
    overrides: [
      appPrefsProvider.overrideWithValue(prefs),
      dbProvider.overrideWithValue(db),
    ],
    child: const FlashApp(),
  ));
}
