import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n.dart';
import '../core/theme.dart';
import '../data/widget/home_widget_service.dart';
import '../providers/providers.dart';
import 'common.dart';

/// Thẻ gợi ý đặt widget "thẻ cần ôn" ra màn hình chính (chỉ Android, launcher hỗ trợ ghim widget).
/// Bấm "Thêm widget" hoặc "Để sau" đều lưu cờ vào AppPrefs để Trang chủ không hiện thẻ này nữa;
/// muốn thêm lại thì vào Cài đặt.
class AddHomeWidgetCard extends ConsumerStatefulWidget {
  const AddHomeWidgetCard({super.key});

  @override
  ConsumerState<AddHomeWidgetCard> createState() => _AddHomeWidgetCardState();
}

class _AddHomeWidgetCardState extends ConsumerState<AddHomeWidgetCard> {
  late final Future<bool> _canPin = HomeWidgetService.canRequestPin();
  bool _dismissed = false;

  Future<void> _close({required bool add}) async {
    setState(() => _dismissed = true);
    await ref.read(appPrefsProvider).setHomeWidgetPromptDone(true);
    if (!add) return;
    final ok = await HomeWidgetService.requestPin(ref.read(dbProvider));
    if (!ok && mounted) showAppSnack(context, tr('Không thêm được widget'), error: true);
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed || ref.watch(appPrefsProvider).homeWidgetPromptDone) return const SizedBox.shrink();
    return FutureBuilder<bool>(
      future: _canPin,
      builder: (context, snap) {
        if (snap.data != true) return const SizedBox.shrink();
        final textColor = Theme.of(context).textTheme.bodyLarge?.color;
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: const Color(0xFFF0F5FF), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.widgets_outlined, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tr('Ôn từ ngay trên màn hình chính'),
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor)),
                        const SizedBox(height: 4),
                        Text(tr('Lật thẻ cần ôn mà không cần mở app.'),
                            style: const TextStyle(color: AppTheme.greyColor, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _close(add: false),
                    child: Text(tr('Để sau'), style: const TextStyle(color: AppTheme.greyColor)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () => _close(add: true),
                    child: Text(tr('Thêm widget'), style: const TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
