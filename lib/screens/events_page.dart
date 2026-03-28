import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/event.dart';
import '../models/team.dart';
import '../services/content_service.dart';
import '../services/event_participation_service.dart';
import '../services/link_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/network_image_box.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key, required this.contentService});

  final ContentService contentService;

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final LinkService _linkService = LinkService();
  final EventParticipationService _participationService =
      EventParticipationService();
  final Set<String> _submittedEventIds = <String>{};
  bool _isLoadingAppliedIds = true;

  @override
  void initState() {
    super.initState();
    _loadAppliedEventIds();
  }

  Future<void> _loadAppliedEventIds() async {
    final applied = await _participationService.getAppliedEventIds();
    if (!mounted) return;

    setState(() {
      _submittedEventIds
        ..clear()
        ..addAll(applied);
      _isLoadingAppliedIds = false;
    });
  }

  Future<void> _openParticipationForm(EventItem event) async {
    final localKnown = _submittedEventIds.contains(event.id) ||
        _participationService.isAppliedLocally(event.id);
    final alreadyApplied =
        localKnown || await _participationService.hasApplied(event.id);

    if (!mounted) return;

    if (alreadyApplied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Bu etkinlik için başvurunuz zaten alınmış.')),
      );
      setState(() {
        _submittedEventIds.add(event.id);
      });
      return;
    }

    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final noteController = TextEditingController();
    bool isSubmitting = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setInnerState) {
            return AlertDialog(
              title: const Text('Etkinlik Katılım Formu'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Ad Soyad'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'E-posta'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: 'Telefon'),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: noteController,
                      decoration:
                          const InputDecoration(labelText: 'Not (Opsiyonel)'),
                      minLines: 2,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Vazgeç'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final fullName = nameController.text.trim();
                          final email = emailController.text.trim();
                          final phone = phoneController.text.trim();

                          if (fullName.isEmpty ||
                              email.isEmpty ||
                              phone.isEmpty) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Ad, e-posta ve telefon zorunludur.')),
                            );
                            return;
                          }

                          setInnerState(() {
                            isSubmitting = true;
                          });

                          try {
                            await _participationService.submitParticipation(
                              event: event,
                              fullName: fullName,
                              email: email,
                              phone: phone,
                              note: noteController.text,
                            );

                            if (!mounted || !dialogContext.mounted) return;

                            setState(() {
                              _submittedEventIds.add(event.id);
                            });

                            Navigator.of(dialogContext).pop();
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                content: Text('Başvurunuz başarıyla alındı.'),
                              ),
                            );
                          } catch (_) {
                            if (!mounted || !dialogContext.mounted) return;
                            setInnerState(() {
                              isSubmitting = false;
                            });
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Başvuru gönderilemedi, lütfen tekrar deneyin.',
                                ),
                              ),
                            );
                          }
                        },
                  child: Text(isSubmitting ? 'Gönderiliyor...' : 'Başvur'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    noteController.dispose();
  }

  Widget _ownerLabel(BuildContext context, String ownerName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        ownerName,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F2446),
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _metaItem({
    required BuildContext context,
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F6FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDCE6F7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF12366D)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF102345),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isGenericTag(String tag) {
    final normalized = tag.trim().toLowerCase();
    return normalized == 'genel' ||
        normalized == 'takım' ||
        normalized == 'takim' ||
        normalized == 'team';
  }

  bool _isPastEvent(EventItem item, DateTime todayStart) {
    final date = item.date;
    if (date == null) return false;
    return date.isBefore(todayStart);
  }

  int _compareUpcoming(EventItem a, EventItem b) {
    final ad = a.date;
    final bd = b.date;
    if (ad == null && bd == null) return a.title.compareTo(b.title);
    if (ad == null) return 1;
    if (bd == null) return -1;
    final byDate = ad.compareTo(bd);
    if (byDate != 0) return byDate;
    return a.title.compareTo(b.title);
  }

  int _comparePast(EventItem a, EventItem b) {
    final ad = a.date;
    final bd = b.date;
    if (ad == null && bd == null) return a.title.compareTo(b.title);
    if (ad == null) return 1;
    if (bd == null) return -1;
    final byDate = bd.compareTo(ad);
    if (byDate != 0) return byDate;
    return a.title.compareTo(b.title);
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    final icon = title.contains('Yaklaşan')
        ? Icons.event_available_outlined
        : Icons.history_toggle_off_outlined;

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: Row(
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
              fontWeight: FontWeight.w900,
              color: const Color(0xFF102345),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoEventCard(BuildContext context, String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildEventCard({
    required BuildContext context,
    required EventItem item,
    required String ownerName,
    required bool showParticipation,
  }) {
    final dateText =
        item.date == null ? '' : DateFormat('dd.MM.yyyy').format(item.date!);
    final mode = item.participationMode.toLowerCase();
    final titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: const Color(0xFF0F2446),
        );
    final statusLabel = showParticipation ? 'Yaklaşan' : 'Geçmiş';
    final statusColor =
        showParticipation ? const Color(0xFF1B5E20) : const Color(0xFF5D6472);
    final statusBg =
        showParticipation ? const Color(0xFFE7F7EB) : const Color(0xFFECEEF2);

    return Card(
      elevation: 3,
      shadowColor: const Color(0x0F173E70),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE3EAF7)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 190,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    NetworkImageBox(
                      imageUrl: item.imageUrl,
                      height: 190,
                      borderRadius: 0,
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.08),
                              Colors.black.withValues(alpha: 0.42),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      right: 12,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ownerLabel(context, ownerName),
                          const Spacer(),
                          if (!_isGenericTag(item.tag)) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF102345)
                                    .withValues(alpha: 0.82),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                item.tag,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          statusLabel,
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(item.title, style: titleStyle),
            const SizedBox(height: 7),
            Text(
              item.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.35,
                    color: const Color(0xFF364862),
                  ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (dateText.isNotEmpty)
                  _metaItem(
                    context: context,
                    icon: Icons.calendar_today_outlined,
                    text: dateText,
                  ),
                if (item.location.trim().isNotEmpty)
                  _metaItem(
                    context: context,
                    icon: Icons.location_on_outlined,
                    text: item.location,
                  ),
              ],
            ),
            if (showParticipation &&
                mode == 'link' &&
                item.participationUrl.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => _linkService.openUrl(item.participationUrl),
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Etkinlik Linkine Git'),
              ),
            ],
            if (showParticipation && mode == 'form') ...[
              const SizedBox(height: 12),
              Builder(
                builder: (context) {
                  final isDone = _submittedEventIds.contains(item.id) ||
                      _participationService.isAppliedLocally(item.id);
                  final isDisabled = _isLoadingAppliedIds || isDone;
                  return FilledButton.icon(
                    onPressed:
                        isDisabled ? null : () => _openParticipationForm(item),
                    icon: Icon(
                      isDone ? Icons.check_circle_outline : Icons.how_to_reg,
                    ),
                    label: Text(
                      _isLoadingAppliedIds
                          ? 'Kontrol Ediliyor...'
                          : (isDone ? 'Başvuru Alındı' : 'Etkinliğe Katıl'),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<EventItem>>(
      stream: widget.contentService.watchEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Etkinlik yükleme hatası: ${snapshot.error}'),
          );
        }

        final events = snapshot.data ?? <EventItem>[];
        if (events.isEmpty) {
          return const EmptyState(message: 'Etkinlik kaydı bulunamadı.');
        }

        return StreamBuilder<List<Team>>(
          stream: widget.contentService.watchTeams(),
          builder: (context, teamSnapshot) {
            final teams = teamSnapshot.data ?? <Team>[];
            final teamById = {
              for (final team in teams) team.id: team,
            };
            final now = DateTime.now();
            final todayStart = DateTime(now.year, now.month, now.day);

            final upcoming = events
                .where((item) => !_isPastEvent(item, todayStart))
                .toList()
              ..sort(_compareUpcoming);
            final past = events
                .where((item) => _isPastEvent(item, todayStart))
                .toList()
              ..sort(_comparePast);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionHeader(context, 'Yaklaşan Etkinlikler'),
                if (upcoming.isEmpty)
                  _buildNoEventCard(
                    context,
                    'Yakında yeni etkinlikler olacak, lütfen bekleyin.',
                  )
                else
                  ...upcoming.map((item) {
                    final isTeamEvent = item.teamId.trim().isNotEmpty;
                    final ownerName = isTeamEvent
                        ? (teamById[item.teamId]?.name ?? item.teamId)
                        : '1.5 Adana';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildEventCard(
                        context: context,
                        item: item,
                        ownerName: ownerName,
                        showParticipation: true,
                      ),
                    );
                  }),
                const SizedBox(height: 8),
                _buildSectionHeader(context, 'Geçmiş Etkinlikler'),
                if (past.isEmpty)
                  _buildNoEventCard(
                    context,
                    'Henüz geçmiş etkinlik bulunmuyor.',
                  )
                else
                  ...past.map((item) {
                    final isTeamEvent = item.teamId.trim().isNotEmpty;
                    final ownerName = isTeamEvent
                        ? (teamById[item.teamId]?.name ?? item.teamId)
                        : '1.5 Adana';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildEventCard(
                        context: context,
                        item: item,
                        ownerName: ownerName,
                        showParticipation: false,
                      ),
                    );
                  }),
              ],
            );
          },
        );
      },
    );
  }
}
