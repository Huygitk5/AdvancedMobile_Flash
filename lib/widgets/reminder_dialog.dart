import 'package:flutter/material.dart';
import '../core/theme.dart';

class ReminderDialog {
  static void show(BuildContext context) {
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
                child: Icon(Icons.notifications_active, color: AppTheme.primaryColor, size: 40),
              ),
              const SizedBox(height: 20),
              Text('Nhắc nhở học tập', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, )),
              const SizedBox(height: 10),
              Text(
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
                  onPressed: () => Navigator.pop(context),
                  child: Text('Bắt đầu học', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).cardColor)),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Để sau', style: TextStyle(color: AppTheme.primaryColor, fontSize: 15, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }
}