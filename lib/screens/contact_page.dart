import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../services/content_service.dart';
import '../widgets/social_links_wrap.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key, required this.contentService});

  final ContentService contentService;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppSettings>(
      stream: contentService.watchAppSettings(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final settings = snapshot.data ?? AppSettings.empty();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('İletişim',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    if (settings.contactEmail.isNotEmpty)
                      Text('E-posta: ${settings.contactEmail}'),
                    if (settings.contactPhone.isNotEmpty)
                      Text('Telefon: ${settings.contactPhone}'),
                    if (settings.contactAddress.isNotEmpty)
                      Text('Adres: ${settings.contactAddress}'),
                    if (settings.contactEmail.isEmpty &&
                        settings.contactPhone.isEmpty &&
                        settings.contactAddress.isEmpty)
                      const Text('İletişim bilgisi henüz eklenmedi.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SocialLinksWrap(links: settings.socialLinks),
          ],
        );
      },
    );
  }
}
