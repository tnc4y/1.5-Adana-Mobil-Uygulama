import 'package:flutter/material.dart';

import '../models/announcement.dart';
import 'network_image_box.dart';

class ImportantAnnouncementPopup extends StatelessWidget {
  const ImportantAnnouncementPopup({
    super.key,
    required this.item,
    required this.onDismissForever,
    required this.onOpenDetail,
  });

  final Announcement item;
  final VoidCallback onDismissForever;
  final VoidCallback onOpenDetail;

  void _handleOpenDetail(BuildContext context) {
    onDismissForever();
    Navigator.of(context).pop();
    onOpenDetail();
  }

  void _handleClose(BuildContext context) {
    onDismissForever();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageWidth = (screenWidth * 0.86).clamp(260.0, 460.0);

    return Material(
      color: Colors.black.withValues(alpha: 0.74),
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _handleClose(context),
            ),
          ),
          Center(
            child: SizedBox(
              width: imageWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () => _handleClose(context),
                      icon: const Icon(Icons.close_rounded),
                      color: Colors.white,
                      iconSize: 28,
                      splashRadius: 20,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _handleOpenDetail(context),
                    child: AspectRatio(
                      aspectRatio: 3.8 / 5,
                      child: NetworkImageBox(
                        imageUrl: item.imageUrl,
                        borderRadius: 16,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
