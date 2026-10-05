/// Đọc JSON của API một cách an toàn (backend bỏ field null: `default-property-inclusion: non_null`).
int jInt(Object? v, [int fallback = 0]) => v is num ? v.toInt() : fallback;
int? jIntN(Object? v) => v is num ? v.toInt() : null;
double jDouble(Object? v, [double fallback = 0]) => v is num ? v.toDouble() : fallback;
bool jBool(Object? v, [bool fallback = false]) => v is bool ? v : fallback;
String jStr(Object? v, [String fallback = '']) => v is String ? v : fallback;
List<int> jIntList(Object? v) => v is List ? v.whereType<num>().map((e) => e.toInt()).toList() : const [];
DateTime? jDate(Object? v) => v is String ? DateTime.tryParse(v)?.toUtc() : null;
