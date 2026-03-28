import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/app_settings.dart';
import '../services/analytics_service.dart';
import '../services/content_service.dart';
import '../services/link_service.dart';
import '../widgets/social_links_wrap.dart';
import 'about_page.dart';
import 'awards_page.dart';
import 'competitions_page.dart';
import 'contact_page.dart';
import 'events_page.dart';
import 'home_page.dart';
import 'sponsors_page.dart';

enum DrawerPage {
  home,
  about,
  events,
  competitions,
  sponsors,
  awards,
  contact,
}

class RootShell extends StatefulWidget {
  const RootShell({super.key, required this.contentService});

  final ContentService contentService;

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell>
  with WidgetsBindingObserver {
  static const String _logoAssetPath = 'assets/images/logo.svg';
  static const Color _logoTintColor = Color(0xFF173A7A);
  static const double _appBarLogoWidth = 140;
  static const double _appBarLogoHeight = 46;
  static const double _drawerLogoWidth = 170;
  static const double _drawerLogoHeight = 56;
  static const String _appVersion = '1.0.2';

  DrawerPage _selected = DrawerPage.home;
  final LinkService _linkService = LinkService();
  final AnalyticsService _analyticsService = AnalyticsService();
  Timer? _analyticsTimer;
  bool _logoPrecached = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAnalytics();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _analyticsService.trackUserOnline().catchError((e) {
          debugPrint('Analytics resume tracking error: $e');
        });
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _analyticsService.trackUserOffline().catchError((e) {
          debugPrint('Analytics offline tracking error: $e');
        });
        break;
      case AppLifecycleState.hidden:
        // No-op: paused/inactive handling already marks offline.
        break;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_logoPrecached) return;
    _logoPrecached = true;
  }

  Future<void> _initializeAnalytics() async {
    try {
      // Track initial online status
      await _analyticsService.trackUserOnline();

      // Set up periodic tracking with a lower frequency to reduce retry noise.
      _analyticsTimer = Timer.periodic(const Duration(minutes: 3), (_) {
        if (mounted) {
          _analyticsService.trackUserOnline().catchError((e) {
            debugPrint('Analytics tracking error: $e');
          });
        }
      });
    } catch (e) {
      debugPrint('Analytics initialization error: $e');
    }
  }

  @override
  void dispose() {
    // Cancel timer first; avoid forced write while app is shutting down.
    _analyticsTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _analyticsService.trackUserOffline().catchError((e) {
      debugPrint('Analytics dispose tracking error: $e');
    });
    super.dispose();
  }

  String get _title {
    switch (_selected) {
      case DrawerPage.home:
        return 'Anasayfa';
      case DrawerPage.about:
        return 'Hakkımızda';
      case DrawerPage.events:
        return 'Etkinlikler';
      case DrawerPage.competitions:
        return 'Yarışmalar';
      case DrawerPage.sponsors:
        return 'Sponsorlar';
      case DrawerPage.awards:
        return 'Ödüller';
      case DrawerPage.contact:
        return 'İletişim';
    }
  }

  Widget _body() {
    switch (_selected) {
      case DrawerPage.home:
        return HomePage(contentService: widget.contentService);
      case DrawerPage.about:
        return AboutPage(contentService: widget.contentService);
      case DrawerPage.events:
        return EventsPage(contentService: widget.contentService);
      case DrawerPage.competitions:
        return CompetitionsPage(contentService: widget.contentService);
      case DrawerPage.sponsors:
        return SponsorsPage(contentService: widget.contentService);
      case DrawerPage.awards:
        return AwardsPage(contentService: widget.contentService);
      case DrawerPage.contact:
        return ContactPage(contentService: widget.contentService);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHome = _selected == DrawerPage.home;

    return Scaffold(
      appBar: AppBar(
        centerTitle: isHome,
        title: isHome
            ? SvgPicture.asset(
                _logoAssetPath,
                colorFilter: const ColorFilter.mode(
                  _logoTintColor,
                  BlendMode.srcIn,
                ),
                width: _appBarLogoWidth,
                height: _appBarLogoHeight,
                fit: BoxFit.contain,
              )
            : Text(
                _title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF102345),
                    ),
              ),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: StreamBuilder<AppSettings>(
            stream: widget.contentService.watchAppSettings(),
            builder: (context, snapshot) {
              final settings = snapshot.data ?? AppSettings.empty();
              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
                    child: Column(
                      children: [
                        SvgPicture.asset(
                          _logoAssetPath,
                          colorFilter: const ColorFilter.mode(
                            _logoTintColor,
                            BlendMode.srcIn,
                          ),
                          width: _drawerLogoWidth,
                          height: _drawerLogoHeight,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Teknoloji Takımları',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: const Color(0xFF153364),
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        _item(context, DrawerPage.home, Icons.home_outlined,
                            'Anasayfa'),
                        _item(context, DrawerPage.about, Icons.info_outline,
                            'Hakkımızda'),
                        _item(context, DrawerPage.events, Icons.event_outlined,
                            'Etkinlikler'),
                        _item(context, DrawerPage.competitions,
                            Icons.emoji_events_outlined, 'Yarışmalar'),
                        _item(context, DrawerPage.sponsors,
                            Icons.handshake_outlined, 'Sponsorlar'),
                        _item(context, DrawerPage.awards,
                            Icons.workspace_premium_outlined, 'Ödüller'),
                        _item(context, DrawerPage.contact,
                            Icons.contact_mail_outlined, 'İletişim'),
                      ],
                    ),
                  ),
                  if (settings.socialLinks.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                      child: SocialLinksWrap(
                        links: settings.socialLinks,
                        linkService: LinkService(),
                      ),
                    ),
                  _drawerFooter(context),
                ],
              );
            },
          ),
        ),
      ),
      body: _body(),
    );
  }

  Widget _item(
      BuildContext context, DrawerPage page, IconData icon, String text) {
    final selected = _selected == page;

    return ListTile(
      leading: Icon(
        icon,
        color: selected ? const Color(0xFF153D82) : const Color(0xFF4A5D7C),
      ),
      title: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              color:
                  selected ? const Color(0xFF102D63) : const Color(0xFF233D68),
            ),
      ),
      selected: selected,
      selectedTileColor: const Color(0xFFEAF0FD),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
      onTap: () {
        setState(() => _selected = page);
        Navigator.of(context).pop();
      },
    );
  }

  Widget _drawerFooter(BuildContext context) {
    final year = DateTime.now().year;
    final primaryFooterColor = const Color(0xFF1B2D4D).withValues(alpha: 0.62);
    final subtleLinkColor = const Color(0xFF1B2D4D).withValues(alpha: 0.26);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '© 1.5 Adana  $year',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: primaryFooterColor,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () => _linkService.openUrl('https://tncy.dev'),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                    child: Text(
                      'tnc4y',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            color: subtleLinkColor,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                            decorationColor: subtleLinkColor,
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'v$_appVersion',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: subtleLinkColor,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
