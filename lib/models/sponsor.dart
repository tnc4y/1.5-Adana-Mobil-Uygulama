import 'model_helpers.dart';

class Sponsor {
  const Sponsor({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.website,
    required this.visible,
    this.description = '',
    this.teamId = '',
  });

  final String id;
  final String name;
  final String logoUrl;
  final String website;
  final String description;
  final String teamId;
  final bool visible;

  bool get isTeamSponsor => teamId.isNotEmpty;

  factory Sponsor.fromMap(String id, Map<String, dynamic> map) {
    return Sponsor(
      id: id,
      name: stringOf(map['name']),
      logoUrl: stringOf(map['logoUrl']),
      website: stringOf(map['website']),
      description: stringOf(map['description']),
      teamId: stringOf(map['teamId']),
      visible: boolOf(map['visible'], fallback: true),
    );
  }
}
