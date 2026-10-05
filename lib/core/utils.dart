import 'dart:math';

final Random _secureRandom = Random.secure();

/// UUID v4: id do client sinh (logId, attemptId, noteId...) để server chống xử lý trùng khi gửi lại.
String uuidV4() {
  final bytes = List<int>.generate(16, (_) => _secureRandom.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  String hex(int from, int to) => bytes.sublist(from, to).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}';
}

/// dd/MM/yyyy
String formatDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

/// yyyy-MM-dd, định dạng ngày của API.
String apiDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime? parseApiDate(String? s) => s == null ? null : DateTime.tryParse(s);

/// Chỉ giữ phần ngày (bỏ giờ).
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

bool isEmail(String s) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s.trim());
