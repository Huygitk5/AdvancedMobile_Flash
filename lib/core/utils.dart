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
