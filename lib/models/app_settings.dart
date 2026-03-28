import 'model_helpers.dart';
import 'social_link.dart';

class AppSettings {
  const AppSettings({
    required this.appName,
    required this.aboutContent,
    required this.contactEmail,
    required this.contactPhone,
    required this.contactAddress,
    required this.socialLinks,
  });

  final String appName;
  final String aboutContent;
  final String contactEmail;
  final String contactPhone;
  final String contactAddress;
  final List<SocialLink> socialLinks;

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      appName:
          stringOf(map['appName'], fallback: '1.5 Adana Teknoloji Takımları'),
      aboutContent: stringOf(map['aboutContent']),
      contactEmail: stringOf(map['contactEmail']),
      contactPhone: stringOf(map['contactPhone']),
      contactAddress: stringOf(map['contactAddress']),
      socialLinks: mapListOf(map['socialLinks'])
          .map(SocialLink.fromMap)
          .where((link) => link.visible && link.url.isNotEmpty)
          .toList(),
    );
  }

  factory AppSettings.empty() {
    return const AppSettings(
      appName: '1.5 Adana Teknoloji Takımları',
      aboutContent: '',
      contactEmail: '',
      contactPhone: '',
      contactAddress: '',
      socialLinks: <SocialLink>[],
    );
  }
}
