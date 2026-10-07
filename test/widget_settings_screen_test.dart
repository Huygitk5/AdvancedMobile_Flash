import 'package:drift/native.dart';
import 'package:flash/core/l10n.dart';
import 'package:flash/data/local/app_database.dart';
import 'package:flash/data/storage/app_prefs.dart';
import 'package:flash/providers/providers.dart';
import 'package:flash/screens/profile/widget_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures.dart';

void main() {
  late AppDatabase db;
  late AppPrefs prefs;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    prefs = (await fakeStorage()).prefs;
  });
  tearDown(() => db.close());

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        appPrefsProvider.overrideWithValue(prefs),
        dbProvider.overrideWithValue(db),
      ],
      child: const MaterialApp(home: WidgetSettingsScreen()),
    ));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
  }

  CheckboxListTile checkbox(WidgetTester tester, String key) => tester.widget<CheckboxListTile>(find.byKey(Key(key)));

  testWidgets('không bỏ tích được nguồn cuối cùng', (tester) async {
    await pump(tester);
    // Mặc định chỉ bật nguồn "Từ chưa nhớ và ôn hôm nay".
    expect(checkbox(tester, 'widget_src_default').value, isTrue);
    expect(checkbox(tester, 'widget_src_topics').value, isFalse);
    expect(checkbox(tester, 'widget_src_saved').value, isFalse);

    await tester.tap(find.byKey(const Key('widget_src_default')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(checkbox(tester, 'widget_src_default').value, isTrue);
    expect(prefs.widgetSrcDefault, isTrue);
    expect(find.text(tr('Cần chọn ít nhất một nguồn từ vựng')), findsOneWidget);

    // Có nguồn khác thì bỏ được nguồn mặc định.
    await tester.tap(find.byKey(const Key('widget_src_saved')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('widget_src_default')));
    await tester.pump();
    expect(prefs.widgetSrcSaved, isTrue);
    expect(prefs.widgetSrcDefault, isFalse);
    await unmount(tester);
  });

  testWidgets('tắt switch thì các mục nguồn bị làm mờ', (tester) async {
    await pump(tester);
    for (final k in ['widget_src_default', 'widget_src_topics', 'widget_src_saved']) {
      expect(checkbox(tester, k).enabled, isTrue, reason: k);
    }

    await tester.tap(find.byKey(const Key('widget_enabled')));
    await tester.pump();

    expect(prefs.widgetEnabled, isFalse);
    for (final k in ['widget_src_default', 'widget_src_topics', 'widget_src_saved']) {
      expect(checkbox(tester, k).enabled, isFalse, reason: k);
    }
    await unmount(tester);
  });

  testWidgets('tích "Chủ đề đã chọn" khi chưa có chủ đề nào → hiện cảnh báo', (tester) async {
    await db.customStatement(
        "INSERT INTO topics (id, title, icon_path, server_updated_at) VALUES ('t1', 'Daily Life', 'x', 1)");
    await pump(tester);

    await tester.tap(find.byKey(const Key('widget_src_topics')));
    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text(tr('Chưa chọn chủ đề nào, nguồn này đang trống.')), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'Daily Life'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilterChip, 'Daily Life'));
    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(prefs.widgetTopicIds, ['t1']);
    expect(find.text(trf('Đã chọn {n} chủ đề', {'n': 1})), findsOneWidget);
    expect(find.text(tr('Chưa chọn chủ đề nào, nguồn này đang trống.')), findsNothing);
    await unmount(tester);
  });
}
