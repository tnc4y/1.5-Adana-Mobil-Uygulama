import 'model_helpers.dart';

class TeamProject {
  const TeamProject({
    required this.id,
    required this.title,
    required this.description,
    required this.visible,
    this.teamId = '',
    this.mediaUrl = '',
    this.repoUrl = '',
  });

  final String id;
  final String title;
  final String description;
  final String teamId;
  final String mediaUrl;
  final String repoUrl;
  final bool visible;

  factory TeamProject.fromMap(String id, Map<String, dynamic> map) {
    return TeamProject(
      id: id,
      title: stringOf(map['title']),
      description: stringOf(map['description']),
      teamId: stringOf(map['teamId']),
      mediaUrl: stringOf(
        map['mediaUrl'],
        fallback: stringOf(map['imageUrl']),
      ),
      repoUrl: stringOf(map['repoUrl']),
      visible: boolOf(map['visible'], fallback: true),
    );
  }
}
