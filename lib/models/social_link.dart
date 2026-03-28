import 'model_helpers.dart';

class SocialLink {
  const SocialLink({
    required this.platform,
    required this.url,
    this.icon = '',
    this.visible = true,
  });

  final String platform;
  final String url;
  final String icon;
  final bool visible;

  factory SocialLink.fromMap(Map<String, dynamic> map) {
    return SocialLink(
      platform: stringOf(map['platform']),
      url: stringOf(map['url']),
      icon: stringOf(map['icon']),
      visible: boolOf(map['visible'], fallback: true),
    );
  }
}
