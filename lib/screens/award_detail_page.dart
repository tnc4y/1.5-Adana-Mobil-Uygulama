import 'package:flutter/material.dart';

import '../models/award.dart';
import '../services/analytics_service.dart';
import '../widgets/network_image_box.dart';

class AwardDetailPage extends StatefulWidget {
  const AwardDetailPage({super.key, required this.award});

  final Award award;

  @override
  State<AwardDetailPage> createState() => _AwardDetailPageState();
}

class _AwardDetailPageState extends State<AwardDetailPage> {
  @override
  void initState() {
    super.initState();
    // Ödül görüntülenmesini kayıt et
    AnalyticsService().trackAwardView(widget.award.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ödül Detayı')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          NetworkImageBox(
              imageUrl: widget.award.mediaUrl, height: 220, borderRadius: 16),
          const SizedBox(height: 16),
          Text(widget.award.title,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          if (widget.award.year.isNotEmpty) Text('Yıl: ${widget.award.year}'),
          const SizedBox(height: 8),
          if (widget.award.projectName.isNotEmpty)
            Text('Proje: ${widget.award.projectName}',
                style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          Text(widget.award.description),
        ],
      ),
    );
  }
}
