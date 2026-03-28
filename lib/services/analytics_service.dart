import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();

  factory AnalyticsService() {
    return _instance;
  }

  AnalyticsService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _cachedDeviceId;
  DateTime? _writesSuspendedUntil;

  bool get _isWriteSuspended {
    final until = _writesSuspendedUntil;
    return until != null && DateTime.now().isBefore(until);
  }

  bool _isTransientFirestoreError(Object error) {
    if (error is! FirebaseException) {
      return false;
    }
    return error.code == 'unavailable' ||
        error.code == 'deadline-exceeded' ||
        error.code == 'network-request-failed';
  }

  void _suspendWrites(Duration duration) {
    _writesSuspendedUntil = DateTime.now().add(duration);
  }

  Future<void> _runTrackedWrite(
    String operation,
    Future<void> Function() write,
  ) async {
    if (_isWriteSuspended) {
      return;
    }

    try {
      await write();
    } catch (e) {
      if (_isTransientFirestoreError(e)) {
        // Back off for a short period to avoid retry storms when network is down.
        _suspendWrites(const Duration(minutes: 2));
      }
      debugPrint('Analytics Error - $operation: $e');
    }
  }

  /// Get or create device ID (persisted locally)
  Future<String> _getDeviceId() async {
    try {
      if (_cachedDeviceId != null) {
        return _cachedDeviceId!;
      }

      final prefs = await SharedPreferences.getInstance();
      String? deviceId = prefs.getString('analytics_device_id');
      
      if (deviceId == null) {
        deviceId = const Uuid().v4();
        await prefs.setString('analytics_device_id', deviceId);
      }
      
      _cachedDeviceId = deviceId;
      return deviceId;
    } catch (e) {
      debugPrint('Analytics Error - _getDeviceId: $e');
      // Fallback to UUID if prefs fail
      return const Uuid().v4();
    }
  }

  /// Kullanıcının online olduğunu kayıt et
  Future<void> trackUserOnline() async {
    await _runTrackedWrite('trackUserOnline', () async {
      final deviceId = await _getDeviceId();

      await _firestore
          .collection('analytics')
          .doc('online_users')
          .collection('users')
          .doc(deviceId)
          .set(
        {
          'deviceId': deviceId,
          'lastSeen': Timestamp.now(),
          'isOnline': true,
          'sessionStartTime': Timestamp.now(),
        },
        SetOptions(merge: true),
      );
    });
  }

  /// Kullanıcı çıktığında offline yap
  Future<void> trackUserOffline() async {
    await _runTrackedWrite('trackUserOffline', () async {
      final deviceId = await _getDeviceId();

      await _firestore
          .collection('analytics')
          .doc('online_users')
          .collection('users')
          .doc(deviceId)
          .set(
        {
          'isOnline': false,
          'lastSeen': Timestamp.now(),
          'sessionEndTime': Timestamp.now(),
        },
        SetOptions(merge: true),
      );
    });
  }

  /// Takım görüntülenmesini kayıt et
  Future<void> trackTeamView(String teamId) async {
    await _runTrackedWrite('trackTeamView', () async {
      final deviceId = await _getDeviceId();
      final timestamp = Timestamp.now();

      // Team view count artır
      await _firestore
          .collection('analytics')
          .doc('team_views')
          .collection('teams')
          .doc(teamId)
          .set(
        {
          'teamId': teamId,
          'viewCount': FieldValue.increment(1),
          'lastViewed': timestamp,
          'viewedBy': FieldValue.arrayUnion([
            {
              'deviceId': deviceId,
              'timestamp': timestamp,
            }
          ]),
        },
        SetOptions(merge: true),
      );
    });
  }

  /// Proje/Makale görüntülenmesini kayıt et
  Future<void> trackProjectView(String projectId) async {
    await _runTrackedWrite('trackProjectView', () async {
      final deviceId = await _getDeviceId();
      final timestamp = Timestamp.now();

      await _firestore
          .collection('analytics')
          .doc('project_views')
          .collection('projects')
          .doc(projectId)
          .set(
        {
          'projectId': projectId,
          'viewCount': FieldValue.increment(1),
          'lastViewed': timestamp,
          'viewedBy': FieldValue.arrayUnion([
            {
              'deviceId': deviceId,
              'timestamp': timestamp,
            }
          ]),
        },
        SetOptions(merge: true),
      );
    });
  }

  /// Duyuru görüntülenmesini kayıt et
  Future<void> trackAnnouncementView(String announcementId) async {
    await _runTrackedWrite('trackAnnouncementView', () async {
      final deviceId = await _getDeviceId();
      final timestamp = Timestamp.now();

      await _firestore
          .collection('analytics')
          .doc('announcement_views')
          .collection('announcements')
          .doc(announcementId)
          .set(
        {
          'announcementId': announcementId,
          'viewCount': FieldValue.increment(1),
          'lastViewed': timestamp,
          'viewedBy': FieldValue.arrayUnion([
            {
              'deviceId': deviceId,
              'timestamp': timestamp,
            }
          ]),
        },
        SetOptions(merge: true),
      );
    });
  }

  /// Ödül görüntülenmesini kayıt et
  Future<void> trackAwardView(String awardId) async {
    await _runTrackedWrite('trackAwardView', () async {
      final deviceId = await _getDeviceId();
      final timestamp = Timestamp.now();

      await _firestore
          .collection('analytics')
          .doc('award_views')
          .collection('awards')
          .doc(awardId)
          .set(
        {
          'awardId': awardId,
          'viewCount': FieldValue.increment(1),
          'lastViewed': timestamp,
          'viewedBy': FieldValue.arrayUnion([
            {
              'deviceId': deviceId,
              'timestamp': timestamp,
            }
          ]),
        },
        SetOptions(merge: true),
      );
    });
  }

  /// Real-time online users count
  Stream<int> getOnlineUsersCount() {
    return _firestore
        .collection('analytics')
        .doc('online_users')
        .collection('users')
        .where('isOnline', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Top viewed teams
  Future<List<Map<String, dynamic>>> getTopViewedTeams({int limit = 5}) async {
    try {
      final snapshot = await _firestore
          .collection('analytics')
          .doc('team_views')
          .collection('teams')
          .orderBy('viewCount', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => {'teamId': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      debugPrint('Analytics Error - getTopViewedTeams: $e');
      return [];
    }
  }

  /// Top viewed projects
  Future<List<Map<String, dynamic>>> getTopViewedProjects(
      {int limit = 5}) async {
    try {
      final snapshot = await _firestore
          .collection('analytics')
          .doc('project_views')
          .collection('projects')
          .orderBy('viewCount', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => {'projectId': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      debugPrint('Analytics Error - getTopViewedProjects: $e');
      return [];
    }
  }

  /// Top viewed announcements
  Future<List<Map<String, dynamic>>> getTopViewedAnnouncements(
      {int limit = 5}) async {
    try {
      final snapshot = await _firestore
          .collection('analytics')
          .doc('announcement_views')
          .collection('announcements')
          .orderBy('viewCount', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => {'announcementId': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      debugPrint('Analytics Error - getTopViewedAnnouncements: $e');
      return [];
    }
  }

  /// Top viewed awards
  Future<List<Map<String, dynamic>>> getTopViewedAwards({int limit = 5}) async {
    try {
      final snapshot = await _firestore
          .collection('analytics')
          .doc('award_views')
          .collection('awards')
          .orderBy('viewCount', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => {'awardId': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      debugPrint('Analytics Error - getTopViewedAwards: $e');
      return [];
    }
  }

  /// Belirli bir koleksiyonun total view count'ı
  Future<int> getTotalViewsForCollection(String collectionType) async {
    try {
      final snapshot = await _firestore
          .collection('analytics')
          .doc('${collectionType}_views')
          .collection(collectionType)
          .get();

      int total = 0;
      for (var doc in snapshot.docs) {
        total += (doc.data()['viewCount'] as int?) ?? 0;
      }
      return total;
    } catch (e) {
      debugPrint('Analytics Error - getTotalViewsForCollection: $e');
      return 0;
    }
  }

  /// Belirli bir item'in view count'ı
  Future<int> getViewCount(String collectionType, String itemId) async {
    try {
      final doc = await _firestore
          .collection('analytics')
          .doc('${collectionType}_views')
          .collection(collectionType)
          .doc(itemId)
          .get();

      return doc.data()?['viewCount'] as int? ?? 0;
    } catch (e) {
      debugPrint('Analytics Error - getViewCount: $e');
      return 0;
    }
  }

  /// Belirli bir item'i views geçmişi
  Future<List<Map<String, dynamic>>> getViewHistory(
      String collectionType, String itemId) async {
    try {
      final doc = await _firestore
          .collection('analytics')
          .doc('${collectionType}_views')
          .collection(collectionType)
          .doc(itemId)
          .get();

      final viewedBy = doc.data()?['viewedBy'] as List? ?? [];
      return List<Map<String, dynamic>>.from(
          viewedBy.cast<Map<String, dynamic>>());
    } catch (e) {
      debugPrint('Analytics Error - getViewHistory: $e');
      return [];
    }
  }
}
