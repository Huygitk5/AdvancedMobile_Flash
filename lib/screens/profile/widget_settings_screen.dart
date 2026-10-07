import 'dart:async';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/local/app_database.dart';
import '../../data/widget/home_widget_service.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';

/// Cấu hình widget màn hình chính: bật/tắt và chọn nguồn từ vựng.
/// Mỗi thay đổi lưu vào AppPrefs rồi đẩy sang widget ngay.
class WidgetSettingsScreen extends ConsumerStatefulWidget {
  const WidgetSettingsScreen({super.key});

  @override
  ConsumerState<WidgetSettingsScreen> createState() => _WidgetSettingsScreenState();
}

class _WidgetSettingsScreenState extends ConsumerState<WidgetSettingsScreen> {
  late final Future<bool> _canPin = HomeWidgetService.canRequestPin();
  late final Future<List<Topic>> _topics;
  late Future<WidgetSnapshot> _preview;

  @override
  void initState() {
    super.initState();
    final db = ref.read(dbProvider);
    _topics = (db.select(db.topics)..orderBy([(t) => OrderingTerm(expression: t.sortOrder)])).get();
    _preview = _loadPreview();
  }

  WidgetConfig get _config => WidgetConfig.fromPrefs(ref.read(appPrefsProvider));

  Future<WidgetSnapshot> _loadPreview() =>
      HomeWidgetService.load(ref.read(dbProvider), nowMs: Clock.nowMs(), config: _config);

  /// Lưu xong thì vẽ lại màn, tính lại dòng xem trước và cập nhật widget ngay.
  Future<void> _save(Future<void> Function() change) async {
    await change();
    if (!mounted) return;
    setState(() {
      _preview = _loadPreview();
    });
    unawaited(HomeWidgetService.refresh(ref.read(dbProvider)));
  }

  /// Luôn phải còn ít nhất một nguồn được tích.
  void _toggleSource(bool current, bool next, Future<void> Function(bool) setter) {
    final c = _config;
    final checked = [c.srcDefault, c.srcTopics, c.srcSaved].where((v) => v).length;
    if (current && !next && checked <= 1) {
      showAppSnack(context, tr('Cần chọn ít nhất một nguồn từ vựng'), error: true);
      return;
    }
    _save(() => setter(next));
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(appPrefsProvider);
    final c = WidgetConfig.fromPrefs(prefs);
    final enabled = c.enabled;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final sectionStyle = TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text(tr('Widget màn hình chính'),
            style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          _card(context, [
            SwitchListTile(
              key: const Key('widget_enabled'),
              secondary: const Icon(Icons.widgets_outlined, color: AppTheme.primaryColor),
              title: Text(tr('Bật widget'), style: TextStyle(fontSize: 15, color: textColor)),
              subtitle: Text(tr('Tắt thì widget ngừng hiện từ. Muốn gỡ hẳn, hãy gỡ trên màn hình chính.'),
                  style: const TextStyle(fontSize: 12, color: AppTheme.greyColor)),
              value: enabled,
              onChanged: (v) => _save(() => prefs.setWidgetEnabled(v)),
              activeThumbColor: AppTheme.primaryColor,
            ),
          ]),
          const SizedBox(height: 20),
          Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: Text(tr('Nguồn từ vựng'), style: sectionStyle)),
          _card(context, [
            CheckboxListTile(
              key: const Key('widget_src_default'),
              enabled: enabled,
              title: Text(tr('Từ chưa nhớ và ôn hôm nay')),
              value: c.srcDefault,
              onChanged: (v) => _toggleSource(c.srcDefault, v ?? false, prefs.setWidgetSrcDefault),
            ),
            CheckboxListTile(
              key: const Key('widget_src_topics'),
              enabled: enabled,
              title: Text(tr('Chủ đề đã chọn')),
              subtitle: Text(trf('Đã chọn {n} chủ đề', {'n': c.topicIds.length})),
              value: c.srcTopics,
              onChanged: (v) => _toggleSource(c.srcTopics, v ?? false, prefs.setWidgetSrcTopics),
            ),
            if (c.srcTopics) _topicPicker(c, enabled),
            CheckboxListTile(
              key: const Key('widget_src_saved'),
              enabled: enabled,
              title: Text(tr('Từ đã lưu')),
              value: c.srcSaved,
              onChanged: (v) => _toggleSource(c.srcSaved, v ?? false, prefs.setWidgetSrcSaved),
            ),
          ]),
          const SizedBox(height: 16),
          FutureBuilder<WidgetSnapshot>(
            future: _preview,
            builder: (context, snap) => Opacity(
              opacity: enabled ? 1 : 0.5,
              child: Row(
                children: [
                  const Icon(Icons.visibility_outlined, size: 18, color: AppTheme.greyColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      snap.hasData ? trf('Widget sẽ hiện {n} từ', {'n': snap.data!.cards.length}) : '…',
                      style: const TextStyle(color: AppTheme.greyColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
          FutureBuilder<bool>(
            future: _canPin,
            builder: (context, snap) => snap.data != true
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: enabled ? _addWidget : null,
                      icon: const Icon(Icons.add_to_home_screen),
                      label: Text(tr('Thêm widget ra màn hình chính')),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _addWidget() async {
    await ref.read(appPrefsProvider).setHomeWidgetPromptDone(true);
    final ok = await HomeWidgetService.requestPin(ref.read(dbProvider));
    if (!ok && mounted) showAppSnack(context, tr('Không thêm được widget'), error: true);
  }

  Widget _topicPicker(WidgetConfig c, bool enabled) {
    final prefs = ref.read(appPrefsProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: FutureBuilder<List<Topic>>(
        future: _topics,
        builder: (context, snap) {
          final topics = snap.data ?? const <Topic>[];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (c.topicIds.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(tr('Chưa chọn chủ đề nào, nguồn này đang trống.'),
                      style: const TextStyle(fontSize: 12, color: Colors.orange)),
                ),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final t in topics)
                    FilterChip(
                      label: Text(t.title),
                      selected: c.topicIds.contains(t.id),
                      onSelected: !enabled
                          ? null
                          : (sel) {
                              final ids = [...c.topicIds];
                              sel ? ids.add(t.id) : ids.remove(t.id);
                              _save(() => prefs.setWidgetTopicIds(ids));
                            },
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  // Material (không phải Container có màu) để hiệu ứng chạm của các ListTile hiện được.
  Widget _card(BuildContext context, List<Widget> children) => Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      );
}
