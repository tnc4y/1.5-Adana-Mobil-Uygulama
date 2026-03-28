import 'package:flutter/material.dart';

import '../models/competition.dart';
import '../models/team.dart';
import '../services/content_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/network_image_box.dart';

class CompetitionsPage extends StatelessWidget {
  const CompetitionsPage({super.key, required this.contentService});

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

  Widget _competitionCard(BuildContext context, Competition item) {
    return _glassCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 90,
            height: 90,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F7FD),
              borderRadius: BorderRadius.circular(14),
            ),
            child: item.imageUrl.trim().isNotEmpty
                ? NetworkImageBox(
                    imageUrl: item.imageUrl,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF0F1E39),
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF0FD),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    item.year,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: const Color(0xFF12366D),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.performance,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF17315F),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionBlock(BuildContext context, String title, IconData icon,
      List<Competition> items,
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
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _competitionCard(context, item),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Competition>>(
      stream: contentService.watchCompetitions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Yarışma yükleme hatası: ${snapshot.error}'),
          );
        }

        final competitions = snapshot.data ?? <Competition>[];
        if (competitions.isEmpty) {
          return const EmptyState(message: 'Yarışma kaydı bulunamadı.');
        }
        return StreamBuilder<List<Team>>(
          stream: contentService.watchTeams(),
          builder: (context, teamSnapshot) {
            final teams = teamSnapshot.data ?? <Team>[];

            final generalCompetitions = competitions
                .where((item) => item.teamId.trim().isEmpty)
                .toList();
            final byTeamId = <String, List<Competition>>{};
            for (final item in competitions) {
              final teamId = item.teamId.trim();
              if (teamId.isEmpty) continue;
              byTeamId.putIfAbsent(teamId, () => <Competition>[]).add(item);
            }

            final sections = <Widget>[];
            if (generalCompetitions.isNotEmpty) {
              sections.add(
                _sectionBlock(
                  context,
                  'Genel Yarışmalar',
                  Icons.public_outlined,
                  generalCompetitions,
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
                message: 'Yarışmalar için gösterilecek kategori bulunamadı.',
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
}
