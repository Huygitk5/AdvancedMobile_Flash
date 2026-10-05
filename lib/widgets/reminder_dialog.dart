import 'package:flutter/material.dart';

import '../core/clock.dart';
import '../core/theme.dart';
import '../data/local/converters.dart';
import '../data/storage/app_prefs.dart';

class ReminderDialog {
  /// Tự hiện tối đa 1 lần/ngày: đã bật nhắc học, đã qua giờ nhắc và hôm nay chưa học bài nào.
  static void maybeShowDaily(BuildContext context, AppPrefs prefs, {required bool studiedToday}) {
    if (!prefs.isNotificationEnabled || studiedToday) return;
    final now = Clock.now();
    final today = localDateKey(now);
    if (prefs.reminderDialogLastShown == today) return;
    final parts = prefs.dailyReminderTime.split(':');
    final reminderAt = DateTime(now.year, now.month, now.day, int.tryParse(parts.first) ?? 20,
        int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0);
    if (now.isBefore(reminderAt)) return;
    show(context, prefs);
  }

  static void show(BuildContext context, AppPrefs prefs, {VoidCallback? onStart}) {
    prefs.setReminderDialogLastShown(localDateKey(Clock.now()));
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                child: const Icon(Icons.notifications_active, color: AppTheme.primaryColor, size: 40),
              ),
              const SizedBox(height: 20),
              const Text('Nhắc nhở học tập', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text(
                'Hôm nay bạn đã học chưa?\nĐừng quên hoàn thành bài học\nđể duy trì streak nhé!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.greyColor, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    onStart?.call();
                  },
                  child: Text('Bắt đầu học', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).cardColor)),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Để sau', style: TextStyle(color: AppTheme.primaryColor, fontSize: 15, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
