import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/app_settings.dart';
import '../services/content_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/social_links_wrap.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key, required this.contentService});

  final ContentService contentService;

  static const String _logoAsset = 'assets/images/logo.svg';
  static const Color _logoTintColor = Color(0xFF173A7A);

  Widget _heroCard(BuildContext context, AppSettings settings) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F2A58), Color(0xFF1B4385)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22102A56),
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -36,
            top: -26,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 92,
                  height: 92,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SvgPicture.asset(
                    _logoAsset,
                    fit: BoxFit.contain,
                    colorFilter: const ColorFilter.mode(
                      _logoTintColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    settings.appName,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _aboutContentCard(BuildContext context, AppSettings settings) {
    final theme = Theme.of(context);
    final paragraphs = settings.aboutContent
        .split(RegExp(r'\n\s*\n'))
        .map((text) => text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE3EAF8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F2A56),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF0FD),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.auto_stories_outlined,
                  color: Color(0xFF12366D),
                  size: 17,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Biz Kimiz?',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF102345),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...paragraphs.map(
            (paragraph) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                paragraph,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.65,
                  color: const Color(0xFF1D2A45),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialCard(BuildContext context, AppSettings settings) {
    if (settings.socialLinks.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDCE5F5)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bizi Takip Edin',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF173A7A),
                ),
          ),
          const SizedBox(height: 8),
          SocialLinksWrap(links: settings.socialLinks),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppSettings>(
      stream: contentService.watchAppSettings(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final settings = snapshot.data ?? AppSettings.empty();
        if (settings.aboutContent.isEmpty) {
          return const EmptyState(
              message: 'Hakkımızda içeriği henüz eklenmedi.');
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _heroCard(context, settings),
            const SizedBox(height: 14),
            _aboutContentCard(context, settings),
            const SizedBox(height: 14),
            _socialCard(context, settings),
          ],
        );
      },
    );
  }
}
