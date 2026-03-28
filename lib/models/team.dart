import 'model_helpers.dart';
import 'social_link.dart';
import 'team_action_link.dart';

class Team {
  const Team({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.shortDescription,
    required this.description,
    required this.homeOrder,
    required this.visible,
    required this.socialLinks,
    this.actionLinks = const [],
    this.bannerUrl = '',
  });

  final String id;
  final String name;
  final String logoUrl;
  final String shortDescription;
  final String description;
  final String bannerUrl;
  final int homeOrder;
  final bool visible;
  final List<SocialLink> socialLinks;
  final List<TeamActionLink> actionLinks;

  factory Team.fromMap(String id, Map<String, dynamic> map) {
    return Team(
      id: id,
      name: stringOf(map['name']),
      logoUrl: stringOf(map['logoUrl']),
      shortDescription: stringOf(map['shortDescription']),
      description: stringOf(map['description']),
      bannerUrl: stringOf(map['bannerUrl']),
      homeOrder: intOf(map['homeOrder']),
      visible: boolOf(map['visible'], fallback: true),
      socialLinks: mapListOf(map['socialLinks'])
          .map(SocialLink.fromMap)
          .where((link) => link.visible && link.url.isNotEmpty)
          .toList(),
      actionLinks: mapListOf(map['actionLinks'])
          .map(TeamActionLink.fromMap)
          .where((link) =>
              link.visible && link.url.isNotEmpty && link.label.isNotEmpty)
          .toList(),
    );
  }
}
