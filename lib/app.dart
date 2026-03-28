import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'screens/root_shell.dart';
import 'services/content_service.dart';

class BirbucukAdanaApp extends StatelessWidget {
  const BirbucukAdanaApp({super.key, required this.contentService});

  final ContentService contentService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '1.5 Adana Teknoloji Takımları',
      theme: AppTheme.build(),
      home: RootShell(contentService: contentService),
    );
  }
}
