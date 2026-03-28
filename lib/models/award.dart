import 'model_helpers.dart';

class Award {
  const Award({
    required this.id,
    required this.title,
    required this.description,
    required this.projectName,
    required this.visible,
    this.teamId = '',
    this.mediaUrl = '',
    this.year = '',
  });

  final String id;
  final String title;
  final String description;
  final String projectName;
  final String teamId;
  final String mediaUrl;
  final String year;
  final bool visible;

  factory Award.fromMap(String id, Map<String, dynamic> map) {
    return Award(
      id: id,
      title: stringOf(map['title']),
      description: stringOf(map['description']),
      projectName: stringOf(map['projectName']),
      teamId: stringOf(map['teamId']),
      mediaUrl: stringOf(map['mediaUrl']),
      year: stringOf(map['year']),
      visible: boolOf(map['visible'], fallback: true),
    );
  }
}
