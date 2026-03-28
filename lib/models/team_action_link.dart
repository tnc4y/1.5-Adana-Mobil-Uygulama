import 'model_helpers.dart';

class TeamActionLink {
  const TeamActionLink({
    required this.label,
    required this.url,
    this.variant = 'primary',
    this.visible = true,
  });

  final String label;
  final String url;
  final String variant;
  final bool visible;

  factory TeamActionLink.fromMap(Map<String, dynamic> map) {
    return TeamActionLink(
      label: stringOf(map['label'], fallback: stringOf(map['title'])),
      url: stringOf(map['url']),
      variant: stringOf(map['variant'], fallback: 'primary').toLowerCase(),
      visible: boolOf(map['visible'], fallback: true),
    );
  }
}
