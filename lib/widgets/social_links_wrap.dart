import 'package:flutter/material.dart';

import '../models/social_link.dart';
import '../services/link_service.dart';

class SocialLinksWrap extends StatelessWidget {
  const SocialLinksWrap({
    super.key,
    required this.links,
    this.linkService,
  });

  final List<SocialLink> links;
  final LinkService? linkService;

  IconData _iconFor(String platform) {
    final key = platform.toLowerCase();
    if (key.contains('instagram')) {
      return Icons.camera_alt_outlined;
    }
    if (key.contains('youtube')) {
      return Icons.ondemand_video_outlined;
    }
    if (key.contains('x') || key.contains('twitter')) {
      return Icons.alternate_email;
    }
    if (key.contains('linkedin')) {
      return Icons.business_center_outlined;
    }
    if (key.contains('web')) {
      return Icons.language_outlined;
    }
    return Icons.link_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final opener = linkService ?? LinkService();
    if (links.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: links
          .map(
            (item) => ActionChip(
              avatar: Icon(_iconFor(item.platform), size: 18),
              label: Text(item.platform),
              onPressed: () => opener.openUrl(item.url),
            ),
          )
          .toList(),
    );
  }
}
