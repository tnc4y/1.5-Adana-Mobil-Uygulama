import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../models/award.dart';
import '../models/project.dart';
import '../models/sponsor.dart';
import '../models/team.dart';
import '../services/analytics_service.dart';
import '../services/content_service.dart';
import '../services/link_service.dart';
import '../widgets/network_image_box.dart';
import '../widgets/social_links_wrap.dart';
import 'award_detail_page.dart';

class TeamDetailPage extends StatefulWidget {
  const TeamDetailPage({
    super.key,
    required this.team,
    required this.contentService,
  });

  final Team team;
  final ContentService contentService;

  @override
  State<TeamDetailPage> createState() => _TeamDetailPageState();
}

class _TeamDetailPageState extends State<TeamDetailPage> {
  @override
  void initState() {
    super.initState();
    // Takım görüntülenmesini kayıt et
    AnalyticsService().trackTeamView(widget.team.id);
  }

  String get _storyText {
    final source = widget.team.description.trim().isEmpty
        ? widget.team.shortDescription.trim()
        : widget.team.description.trim();

    return source;
  }

  MarkdownStyleSheet _markdownStyle(ThemeData theme, {bool compact = false}) {
    return MarkdownStyleSheet.fromTheme(theme).copyWith(
      p: theme.textTheme.bodyLarge?.copyWith(
        height: compact ? 1.45 : 1.65,
        color: const Color(0xFF1C2842),
      ),
      h1: theme.textTheme.headlineSmall?.copyWith(
        color: const Color(0xFF0F1E39),
        fontWeight: FontWeight.w900,
      ),
      h2: theme.textTheme.titleLarge?.copyWith(
        color: const Color(0xFF0F1E39),
        fontWeight: FontWeight.w800,
      ),
      h3: theme.textTheme.titleMedium?.copyWith(
        color: const Color(0xFF17315F),
        fontWeight: FontWeight.w700,
      ),
      strong: const TextStyle(
        color: Color(0xFFBD1B31),
        fontWeight: FontWeight.w800,
      ),
      code: theme.textTheme.bodyMedium?.copyWith(
        color: const Color(0xFF143A79),
        backgroundColor: const Color(0xFFF1F5FF),
      ),
      blockquoteDecoration: BoxDecoration(
        color: const Color(0xFFF7F9FE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E7F5)),
      ),
      blockSpacing: compact ? 10 : 14,
    );
  }

  Widget _sectionTitle(String title, IconData icon, {String? badge}) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF0FD),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF12366D), size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF102345),
                ),
          ),
        ),
        if (badge != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF0F2350),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              badge,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
      ],
    );
  }

  Widget _glassCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x15132A53),
            blurRadius: 26,
            offset: Offset(0, 14),
          ),
        ],
        border: Border.all(color: const Color(0xFFE4EBF8)),
      ),
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );
  }

  Widget _inlineMarkdown(String data, ThemeData theme) {
    return MarkdownBody(
      data: data,
      selectable: true,
      styleSheet: _markdownStyle(theme, compact: true),
      onTapLink: (text, href, title) {
        if (href != null && href.isNotEmpty) {
          LinkService().openUrl(href);
        }
      },
    );
  }

  Widget _buildActionButton(
      String label, VoidCallback onPressed, String variant) {
    switch (variant) {
      case 'secondary':
        return OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF12366D)),
            foregroundColor: const Color(0xFF12366D),
          ),
          child: Text(label),
        );
      case 'tonal':
        return FilledButton.tonal(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFE8EEFA),
            foregroundColor: const Color(0xFF12366D),
          ),
          child: Text(label),
        );
      default:
        return FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF12366D),
            foregroundColor: Colors.white,
          ),
          child: Text(label),
        );
    }
  }

  Widget _detailBrandCard(ThemeData theme, String markdown) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x15132A53),
            blurRadius: 26,
            offset: Offset(0, 14),
          ),
        ],
        border: Border.all(color: const Color(0xFFE4EBF8)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: Align(
                alignment: Alignment.center,
                child: Opacity(
                  opacity: 0.30,
                  child: FractionallySizedBox(
                    widthFactor: 0.88,
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: NetworkImageBox(
                        imageUrl: widget.team.logoUrl,
                        borderRadius: 0,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MarkdownBody(
                  data: markdown,
                  selectable: true,
                  onTapLink: (text, href, title) {
                    if (href != null && href.isNotEmpty) {
                      LinkService().openUrl(href);
                    }
                  },
                  styleSheet: _markdownStyle(theme),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final markdown = _storyText;
    final hasBanner = widget.team.bannerUrl.isNotEmpty;
    final heroImage = hasBanner ? widget.team.bannerUrl : widget.team.logoUrl;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FB),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 215,
            pinned: true,
            backgroundColor: const Color(0xFF0E2148),
            foregroundColor: Colors.white,
            elevation: 0,
            title: Text(
              widget.team.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  NetworkImageBox(
                    imageUrl: heroImage,
                    borderRadius: 0,
                    fit: BoxFit.cover,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.12),
                          const Color(0xFF0E1F43).withValues(alpha: 0.62),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 74,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            const Color(0xFF0E2148).withValues(alpha: 0.58),
                            const Color(0xFF0E2148).withValues(alpha: 0.84),
                          ],
                          stops: const [0.0, 0.6, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 28),
              child: Column(
                children: [
                  _detailBrandCard(theme, markdown),
                  if (widget.team.socialLinks.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _glassCard(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle('Bağlantılar', Icons.public_outlined),
                          const SizedBox(height: 8),
                          SocialLinksWrap(links: widget.team.socialLinks),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _sectionTitle('Projeler', Icons.rocket_launch_outlined),
                  const SizedBox(height: 8),
                  StreamBuilder<List<TeamProject>>(
                    stream: widget.contentService.watchProjects(),
                    builder: (context, snapshot) {
                      final items = (snapshot.data ?? <TeamProject>[])
                          .where((item) => item.teamId == widget.team.id)
                          .toList();
                      if (items.isEmpty) {
                        return _glassCard(
                          child: const Text('Bu takıma ait proje bulunamadı.'),
                        );
                      }

                      return SizedBox(
                        height: 320,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final project = items[index];
                            return SizedBox(
                              width: 286,
                              child: _glassCard(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (project.mediaUrl.trim().isNotEmpty)
                                      NetworkImageBox(
                                        imageUrl: project.mediaUrl,
                                        height: 130,
                                        borderRadius: 12,
                                        fit: BoxFit.cover,
                                      )
                                    else
                                      Container(
                                        height: 130,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEFF3FB),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.image_outlined,
                                          size: 32,
                                          color: Color(0xFF8A9BB9),
                                        ),
                                      ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            project.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                              color: const Color(0xFF0F1E39),
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                        if (project.repoUrl.isNotEmpty)
                                          IconButton(
                                            constraints: const BoxConstraints(),
                                            padding: const EdgeInsets.all(4),
                                            onPressed: () => LinkService()
                                                .openUrl(project.repoUrl),
                                            icon: const Icon(
                                              Icons.open_in_new,
                                              color: Color(0xFF12366D),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: project.description
                                                .trim()
                                                .isNotEmpty
                                            ? _inlineMarkdown(
                                                project.description, theme)
                                            : const Text(
                                                'Açıklama eklenmemiş.'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _sectionTitle('Ödüller', Icons.workspace_premium_outlined),
                  const SizedBox(height: 8),
                  StreamBuilder<List<Award>>(
                    stream: widget.contentService.watchAwards(),
                    builder: (context, snapshot) {
                      final awards = (snapshot.data ?? <Award>[])
                          .where((item) => item.teamId == widget.team.id)
                          .toList();
                      if (awards.isEmpty) {
                        return _glassCard(
                          child: const Text('Bu takıma ait ödül bulunamadı.'),
                        );
                      }

                      return Column(
                        children: awards
                            .map(
                              (award) => Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: _glassCard(
                                  padding: const EdgeInsets.all(12),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              AwardDetailPage(award: award),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 84,
                                          height: 84,
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF4F7FD),
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          child: award.mediaUrl
                                                  .trim()
                                                  .isNotEmpty
                                              ? NetworkImageBox(
                                                  imageUrl: award.mediaUrl,
                                                  borderRadius: 8,
                                                  fit: BoxFit.cover,
                                                )
                                              : const Icon(
                                                  Icons.emoji_events_outlined,
                                                  size: 36,
                                                  color: Color(0xFF12366D),
                                                ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      award.title,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: theme
                                                          .textTheme.titleSmall
                                                          ?.copyWith(
                                                        color: const Color(
                                                            0xFF0F1E39),
                                                        fontWeight:
                                                            FontWeight.w800,
                                                      ),
                                                    ),
                                                  ),
                                                  const Icon(
                                                    Icons.chevron_right,
                                                    color: Color(0xFF12366D),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              if (award.year.trim().isNotEmpty)
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 10,
                                                    vertical: 6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFFEAF0FD),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Text(
                                                    award.year,
                                                    style: theme
                                                        .textTheme.labelLarge
                                                        ?.copyWith(
                                                      color: const Color(
                                                          0xFF12366D),
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              if (award.projectName
                                                  .trim()
                                                  .isNotEmpty) ...[
                                                const SizedBox(height: 8),
                                                Text(
                                                  award.projectName,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: theme
                                                      .textTheme.bodyMedium
                                                      ?.copyWith(
                                                    color:
                                                        const Color(0xFF17315F),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _sectionTitle('Sponsorlar', Icons.handshake_outlined),
                  const SizedBox(height: 8),
                  StreamBuilder<List<Sponsor>>(
                    stream: widget.contentService.watchSponsors(),
                    builder: (context, snapshot) {
                      final sponsors = (snapshot.data ?? <Sponsor>[])
                          .where((item) => item.teamId == widget.team.id)
                          .toList();
                      if (sponsors.isEmpty) {
                        return _glassCard(
                          child:
                              const Text('Bu takıma ait sponsor bulunamadı.'),
                        );
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: sponsors.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.94,
                        ),
                        itemBuilder: (context, index) {
                          final sponsor = sponsors[index];
                          final hasWebsite = sponsor.website.trim().isNotEmpty;
                          return GestureDetector(
                            onTap: hasWebsite
                                ? () => LinkService().openUrl(sponsor.website)
                                : null,
                            child: _glassCard(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 92,
                                    height: 92,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF4F7FD),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: sponsor.logoUrl.trim().isNotEmpty
                                        ? NetworkImageBox(
                                            imageUrl: sponsor.logoUrl,
                                            borderRadius: 8,
                                            fit: BoxFit.contain,
                                          )
                                        : const Icon(
                                            Icons.handshake_outlined,
                                            size: 40,
                                            color: Color(0xFF12366D),
                                          ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    sponsor.name,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: const Color(0xFF0F1E39),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Text(
                                        sponsor.description,
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: const Color(0xFF17315F),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  if (widget.team.actionLinks.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      alignment: WrapAlignment.center,
                      runAlignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 10,
                      children: widget.team.actionLinks
                          .map(
                            (item) => _buildActionButton(
                              item.label,
                              () => LinkService().openUrl(item.url),
                              item.variant,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
