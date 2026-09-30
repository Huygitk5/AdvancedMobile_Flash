import 'package:flutter/material.dart';

class Quest {
  final String id;
  final String title;
  final int current;
  final int target;
  final int xp;
  bool isClaimed; // Có thể thay đổi
  final IconData icon; // Tạm thời dùng IconData, sau này có API sẽ map từ String

  Quest({
    required this.id,
    required this.title,
    required this.current,
    required this.target,
    required this.xp,
    required this.isClaimed,
    required this.icon,
  });

  // Sẵn sàng cho Backend API
  factory Quest.fromJson(Map<String, dynamic> json) {
    return Quest(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      current: json['current'] ?? 0,
      target: json['target'] ?? 1,
      xp: json['xp'] ?? 0,
      isClaimed: json['isClaimed'] ?? false,
      icon: Icons.star, // Map icon thật từ API sau
    );
  }
}