// Đọc JSON an toàn: thiếu field hoặc sai kiểu thì dùng giá trị mặc định thay vì làm app lỗi.

String jStr(Map<String, dynamic> m, String key, [String fallback = '']) {
  final v = m[key];
  return v == null ? fallback : v.toString();
}

String? jStrOrNull(Map<String, dynamic> m, String key) {
  final v = m[key];
  if (v == null) return null;
  final s = v.toString();
  return s.isEmpty ? null : s;
}

int jInt(Map<String, dynamic> m, String key, [int fallback = 0]) {
  final v = m[key];
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse('$v') ?? fallback;
}

double jDouble(Map<String, dynamic> m, String key, [double fallback = 0]) {
  final v = m[key];
  if (v is num) return v.toDouble();
  return double.tryParse('$v') ?? fallback;
}

bool jBool(Map<String, dynamic> m, String key, [bool fallback = false]) {
  final v = m[key];
  if (v is bool) return v;
  if (v is String) return v.toLowerCase() == 'true';
  return fallback;
}

DateTime? jDate(Map<String, dynamic> m, String key) {
  final v = m[key];
  if (v == null) return null;
  return DateTime.tryParse('$v');
}

List<Map<String, dynamic>> jList(Map<String, dynamic> m, String key) {
  final v = m[key];
  if (v is! List) return const [];
  return v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
}

List<Map<String, dynamic>> asMapList(dynamic v) {
  if (v is! List) return const [];
  return v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
}

Map<String, dynamic> asMap(dynamic v) => v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};
