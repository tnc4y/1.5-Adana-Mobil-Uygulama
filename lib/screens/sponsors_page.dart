import 'package:flutter/material.dart';

import '../models/sponsor.dart';
import '../models/team.dart';
import '../services/content_service.dart';
import '../services/link_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/network_image_box.dart';

class SponsorsPage extends StatelessWidget {
  const SponsorsPage({super.key, required this.contentService});

  final ContentService contentService;

  Widget _sectionTitle(BuildContext context, String title, IconData icon,
      {String? badge}) {
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

  Widget _sectionBlock(
      BuildContext context, String title, IconData icon, List<Sponsor> items,
      {bool showBadge = true}) {
    return Column(
      children: [
        _sectionTitle(
          context,
          title,
          icon,
          badge: showBadge ? '${items.length}' : null,
        ),
        const SizedBox(height: 8),
        ...items.map((item) => _buildSponsorCard(context, item)),
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Sponsor>>(
      stream: contentService.watchSponsors(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Sponsor yükleme hatası: ${snapshot.error}'),
          );
        }

        final sponsors = snapshot.data ?? <Sponsor>[];
        if (sponsors.isEmpty) {
          return const EmptyState(message: 'Sponsor kaydı bulunamadı.');
        }

        return StreamBuilder<List<Team>>(
          stream: contentService.watchTeams(),
          builder: (context, teamSnapshot) {
            final teams = teamSnapshot.data ?? <Team>[];

            final general =
                sponsors.where((item) => !item.isTeamSponsor).toList();
            final byTeamId = <String, List<Sponsor>>{};
            for (final sponsor in sponsors) {
              final teamId = sponsor.teamId.trim();
              if (teamId.isEmpty) continue;
              byTeamId.putIfAbsent(teamId, () => <Sponsor>[]).add(sponsor);
            }

            final sections = <Widget>[];
            if (general.isNotEmpty) {
              sections.add(
                _sectionBlock(
                  context,
                  'Genel Sponsorlar',
                  Icons.public_outlined,
                  general,
                ),
              );
            }

            for (final team in teams) {
              final items = byTeamId.remove(team.id);
              if (items == null || items.isEmpty) continue;
              sections.add(
                _sectionBlock(
                  context,
                  team.name,
                  Icons.groups_2_outlined,
                  items,
                  showBadge: false,
                ),
              );
            }

            final remainingIds = byTeamId.keys.toList()..sort();
            for (final teamId in remainingIds) {
              final items = byTeamId[teamId]!;
              if (items.isEmpty) continue;
              sections.add(
                _sectionBlock(
                  context,
                  teamId,
                  Icons.groups_2_outlined,
                  items,
                  showBadge: false,
                ),
              );
            }

            if (sections.isEmpty) {
              return const EmptyState(
                message: 'Sponsorlar için gösterilecek kategori bulunamadı.',
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: sections,
            );
          },
        );
      },
    );
  }

  Widget _buildSponsorCard(BuildContext context, Sponsor sponsor) {
    final hasWebsite = sponsor.website.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: hasWebsite ? () => LinkService().openUrl(sponsor.website) : null,
        child: _glassCard(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            sponsor.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color: const Color(0xFF0F1E39),
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        if (hasWebsite)
                          const Icon(
                            Icons.open_in_new,
                            size: 18,
                            color: Color(0xFF12366D),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sponsor.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF17315F),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
