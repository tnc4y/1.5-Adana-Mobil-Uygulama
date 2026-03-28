import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../models/announcement.dart';
import '../models/team.dart';
import '../services/content_service.dart';
import '../services/popup_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/important_announcement_popup.dart';
import '../widgets/network_image_box.dart';
import 'announcement_detail_page.dart';
import 'team_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.contentService});

  final ContentService contentService;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _popupChecked = false;

  Widget _sectionHeader(String title, IconData icon) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF0FD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF12366D), size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF102345),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _checkAndShowPopup(List<Announcement> announcements) async {
    if (_popupChecked || announcements.isEmpty || !mounted) return;
    _popupChecked = true;

    final popup = announcements.firstWhere(
      (item) => item.showAsPopup && item.popupDismissKey.isNotEmpty,
      orElse: () => const Announcement(
        id: '',
        title: '',
        summary: '',
        content: '',
        imageUrl: '',
        order: 0,
        visible: false,
      ),
    );

    if (popup.id.isEmpty) return;

    final popupService = PopupService();
    final dismissed = await popupService.isDismissed(popup.popupDismissKey);
    if (dismissed || !mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ImportantAnnouncementPopup(
        item: popup,
        onDismissForever: () => popupService.dismiss(popup.popupDismissKey),
        onOpenDetail: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AnnouncementDetailPage(item: popup),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _sectionHeader('Duyurular', Icons.campaign_outlined),
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<Announcement>>(
          stream: widget.contentService.watchAnnouncements(),
          builder: (context, snapshot) {
            final items = snapshot.data ?? <Announcement>[];
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _checkAndShowPopup(items);
            });

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 220,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (items.isEmpty) {
              return const SizedBox(
                height: 120,
                child: EmptyState(message: 'Aktif duyuru bulunamadı.'),
              );
            }

            return CarouselSlider.builder(
              itemCount: items.length,
              options: CarouselOptions(
                height: 236,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 5),
                viewportFraction: 0.88,
                padEnds: true,
                enlargeCenterPage: true,
                enlargeFactor: 0.16,
              ),
              itemBuilder: (_, index, __) {
                final item = items[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Card(
                    margin: EdgeInsets.zero,
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AnnouncementDetailPage(item: item),
                          ),
                        );
                      },
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: NetworkImageBox(
                              imageUrl: item.imageUrl,
                              borderRadius: 0,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.1),
                                    Colors.black.withValues(alpha: 0.72),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 14,
                            right: 14,
                            bottom: 14,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item.summary,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _sectionHeader('Takımlar', Icons.groups_2_outlined),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: StreamBuilder<List<Team>>(
            stream: widget.contentService.watchTeams(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Takım yükleme hatası: ${snapshot.error}'),
                );
              }

              final teams = snapshot.data ?? <Team>[];
              if (teams.isEmpty) {
                return const EmptyState(
                    message: 'Takım bilgisi henüz eklenmedi.');
              }

              return GridView.builder(
                itemCount: teams.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),
                itemBuilder: (context, index) {
                  final team = teams[index];
                  return Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TeamDetailPage(
                              team: team,
                              contentService: widget.contentService,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Expanded(
                              child: NetworkImageBox(
                                imageUrl: team.logoUrl,
                                borderRadius: 50,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              team.name,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
