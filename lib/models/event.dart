import 'model_helpers.dart';

class EventItem {
  const EventItem({
    required this.id,
    required this.title,
    required this.description,
    required this.tag,
    required this.date,
    required this.visible,
    this.imageUrl = '',
    this.location = '',
    this.teamId = '',
    this.participationMode = 'none',
    this.participationUrl = '',
  });

  final String id;
  final String title;
  final String description;
  final String tag;
  final DateTime? date;
  final bool visible;
  final String imageUrl;
  final String location;
  final String teamId;
  final String participationMode;
  final String participationUrl;

  factory EventItem.fromMap(String id, Map<String, dynamic> map) {
    return EventItem(
      id: id,
      title: stringOf(map['title']),
      description: stringOf(map['description']),
      tag: stringOf(map['tag'], fallback: 'Genel'),
      date: dateOf(map['date']),
      visible: boolOf(map['visible'], fallback: true),
      imageUrl: stringOf(map['imageUrl']),
      location: stringOf(map['location']),
      teamId: stringOf(map['teamId']),
      participationMode:
          stringOf(map['participationMode'], fallback: 'none').toLowerCase(),
      participationUrl: stringOf(map['participationUrl']),
    );
  }
}
