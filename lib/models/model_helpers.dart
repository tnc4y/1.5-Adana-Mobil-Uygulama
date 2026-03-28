import 'package:cloud_firestore/cloud_firestore.dart';

String stringOf(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  return value.toString();
}

bool boolOf(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  return fallback;
}

int intOf(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return fallback;
}

DateTime? dateOf(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

Map<String, dynamic> mapOf(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map(
      (key, val) => MapEntry(key.toString(), val),
    );
  }
  return <String, dynamic>{};
}

List<Map<String, dynamic>> mapListOf(dynamic value) {
  if (value is! List) return <Map<String, dynamic>>[];
  return value.map((item) => mapOf(item)).toList();
}

List<String> stringListOf(dynamic value) {
  if (value is! List) return <String>[];
  return value.map((item) => item.toString()).toList();
}
