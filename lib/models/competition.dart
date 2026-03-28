import 'model_helpers.dart';

class Competition {
  const Competition({
    required this.id,
    required this.title,
    required this.performance,
    required this.year,
    required this.visible,
    this.teamId = '',
    this.imageUrl = '',
  });

  final String id;
  final String title;
  final String performance;
  final String year;
  final String teamId;
  final String imageUrl;
  final bool visible;

  factory Competition.fromMap(String id, Map<String, dynamic> map) {
    return Competition(
      id: id,
      title: stringOf(map['title']),
      performance: stringOf(map['performance']),
      year: stringOf(map['year']),
      teamId: stringOf(map['teamId']),
      imageUrl: stringOf(map['imageUrl']),
      visible: boolOf(map['visible'], fallback: true),
    );
  }
}
