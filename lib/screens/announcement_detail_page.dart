import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/announcement.dart';
import '../services/analytics_service.dart';
import '../services/link_service.dart';
import '../widgets/network_image_box.dart';

class AnnouncementDetailPage extends StatefulWidget {
  const AnnouncementDetailPage({super.key, required this.item});

  final Announcement item;

  @override
  State<AnnouncementDetailPage> createState() =>
      _AnnouncementDetailPageState();
}

class _AnnouncementDetailPageState extends State<AnnouncementDetailPage> {
  @override
  void initState() {
    super.initState();
    // Duyuru görüntülenmesini kayıt et
    AnalyticsService().trackAnnouncementView(widget.item.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Duyuru Detayı')),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (notification) {
          // Prevent Android glow artifacts while pulling past scroll extents.
          notification.disallowIndicator();
          return true;
        },
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 290,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    NetworkImageBox(
                      imageUrl: widget.item.imageUrl,
                      borderRadius: 0,
                      fit: BoxFit.cover,
                    ),
                    ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.22),
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.28),
                            ),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: NetworkImageBox(
                            imageUrl: widget.item.imageUrl,
                            height: 220,
                            borderRadius: 12,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.item.title, style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.item.summary,
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(widget.item.content),
                    if (widget.item.buttonUrl.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: () => LinkService().openUrl(widget.item.buttonUrl),
                        icon: const Icon(Icons.open_in_new),
                        label: Text(
                          widget.item.buttonText.isEmpty
                              ? 'Bağlantıyı Aç'
                              : widget.item.buttonText,
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
    );
  }
}
