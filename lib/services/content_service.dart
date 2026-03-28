import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/announcement.dart';
import '../models/app_settings.dart';
import '../models/award.dart';
import '../models/competition.dart';
import '../models/event.dart';
import '../models/project.dart';
import '../models/sponsor.dart';
import '../models/team.dart';

class ContentService {
  ContentService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<AppSettings> watchAppSettings() {
    return _firestore.collection('settings').doc('app').snapshots().map(
      (doc) {
        final data = doc.data();
        if (data == null) return AppSettings.empty();
        return AppSettings.fromMap(data);
      },
    );
  }

  Stream<List<Announcement>> watchAnnouncements() {
    return _firestore.collection('announcements').snapshots().map(
          (snap) {
            final announcements = snap.docs
                .map((doc) => Announcement.fromMap(doc.id, doc.data()))
                .where((item) => item.visible)
                .toList();
            // Sort by order
            try {
              announcements.sort((a, b) => a.order.compareTo(b.order));
            } catch (e) {
              debugPrint('Announcement sorting error: $e');
            }
            return announcements;
          },
        );
  }

  Stream<List<Team>> watchTeams() {
    return _firestore.collection('teams').snapshots().map(
          (snap) {
            final teams = snap.docs
                .map((doc) => Team.fromMap(doc.id, doc.data()))
                .where((item) => item.visible)
                .toList();
            // Sort by homeOrder if field exists
            try {
              teams.sort((a, b) => a.homeOrder.compareTo(b.homeOrder));
            } catch (e) {
              // If homeOrder doesn't exist or fails, keep original order
              debugPrint('Team sorting error: $e');
            }
            return teams;
          },
        );
  }

  Stream<List<EventItem>> watchEvents() {
    return _firestore.collection('events').snapshots().map(
          (snap) {
            final events = snap.docs
                .map((doc) => EventItem.fromMap(doc.id, doc.data()))
                .where((item) => item.visible)
                .toList();
            // Sort by date descending
            try {
              events.sort((a, b) {
                final dateA = a.date ?? DateTime(1000);
                final dateB = b.date ?? DateTime(1000);
                return dateB.compareTo(dateA);
              });
            } catch (e) {
              debugPrint('Event sorting error: $e');
            }
            return events;
          },
        );
  }

  Stream<List<Sponsor>> watchSponsors() {
    return _firestore.collection('sponsors').snapshots().map(
          (snap) => snap.docs
              .map((doc) => Sponsor.fromMap(doc.id, doc.data()))
              .where((item) => item.visible)
              .toList(),
        );
  }

  Stream<List<Competition>> watchCompetitions() {
    return _firestore.collection('competitions').snapshots().map(
          (snap) => snap.docs
              .map((doc) => Competition.fromMap(doc.id, doc.data()))
              .where((item) => item.visible)
              .toList(),
        );
  }

  Stream<List<Award>> watchAwards() {
    return _firestore.collection('awards').snapshots().map(
          (snap) => snap.docs
              .map((doc) => Award.fromMap(doc.id, doc.data()))
              .where((item) => item.visible)
              .toList(),
        );
  }

  Stream<List<TeamProject>> watchProjects() {
    return _firestore.collection('projects').snapshots().map(
          (snap) => snap.docs
              .map((doc) => TeamProject.fromMap(doc.id, doc.data()))
              .where((item) => item.visible)
              .toList(),
        );
  }
}
