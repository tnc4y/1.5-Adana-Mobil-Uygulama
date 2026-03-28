import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/event.dart';

class EventParticipationService {
  EventParticipationService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  String? _cachedDeviceId;
  Set<String> _appliedEventIdCache = <String>{};
  bool _cacheLoaded = false;

  Future<String> _getDeviceId() async {
    if (_cachedDeviceId != null) {
      return _cachedDeviceId!;
    }

    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('analytics_device_id');

    if (deviceId == null || deviceId.trim().isEmpty) {
      deviceId = const Uuid().v4();
      await prefs.setString('analytics_device_id', deviceId);
    }

    _cachedDeviceId = deviceId;
    return deviceId;
  }

  Future<String> _docId(String eventId) async {
    final deviceId = await _getDeviceId();
    return '${eventId}_$deviceId';
  }

  Future<bool> hasApplied(String eventId) async {
    if (_cacheLoaded && _appliedEventIdCache.contains(eventId)) {
      return true;
    }

    final id = await _docId(eventId);
    final doc =
        await _firestore.collection('event_participations').doc(id).get();

    if (doc.exists) {
      _appliedEventIdCache = {..._appliedEventIdCache, eventId};
    }

    return doc.exists;
  }

  Future<Set<String>> getAppliedEventIds() async {
    if (_cacheLoaded) {
      return _appliedEventIdCache;
    }

    try {
      final deviceId = await _getDeviceId();
      final snap = await _firestore
          .collection('event_participations')
          .where('deviceId', isEqualTo: deviceId)
          .get();

      _appliedEventIdCache = snap.docs
          .map((doc) => (doc.data()['eventId'] as String?) ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();
      _cacheLoaded = true;
      return _appliedEventIdCache;
    } catch (_) {
      _cacheLoaded = true;
      return _appliedEventIdCache;
    }
  }

  bool isAppliedLocally(String eventId) {
    return _appliedEventIdCache.contains(eventId);
  }

  void markApplied(String eventId) {
    _appliedEventIdCache = {..._appliedEventIdCache, eventId};
  }

  Future<void> submitParticipation({
    required EventItem event,
    required String fullName,
    required String email,
    required String phone,
    String note = '',
  }) async {
    final deviceId = await _getDeviceId();
    final id = '${event.id}_$deviceId';

    final payload = {
      'eventId': event.id,
      'eventTitle': event.title,
      'eventDate': event.date == null ? null : Timestamp.fromDate(event.date!),
      'deviceId': deviceId,
      'fullName': fullName.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'note': note.trim(),
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _firestore
        .collection('event_participations')
        .doc(id)
        .set(payload, SetOptions(merge: true));

    markApplied(event.id);
  }
}
