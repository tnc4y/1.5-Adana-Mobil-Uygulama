import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'services/content_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _BootstrapApp());
}

class _BootstrapApp extends StatefulWidget {
  const _BootstrapApp();

  @override
  State<_BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<_BootstrapApp> {
  late final Future<void> _initFuture;
  late final ContentService _contentService;
  static const String _logoAssetPath = 'assets/images/logo.svg';
  static const Color _logoTintColor = Color(0xFF173A7A);
  static const Duration _minimumSplashDuration = Duration(milliseconds: 1400);
  static const Duration _initialDataTimeout = Duration(seconds: 4);

  Future<void> _warmUpLogo() async {
    try {
      await rootBundle.loadString(_logoAssetPath);
    } catch (_) {
      // Ignore warmup failures; app should still start normally.
    }
  }

  Future<void> _awaitFirstOrTimeout<T>(Stream<T> stream) async {
    try {
      await stream.first.timeout(_initialDataTimeout);
    } catch (_) {
      // If initial data is delayed, continue boot to avoid hard-blocking app start.
    }
  }

  Future<void> _preloadInitialContent(ContentService contentService) async {
    await Future.wait<void>([
      _awaitFirstOrTimeout(contentService.watchAppSettings()),
      _awaitFirstOrTimeout(contentService.watchAnnouncements()),
      _awaitFirstOrTimeout(contentService.watchTeams()),
    ]);
  }

  Future<void> _initializeApp() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    _contentService = ContentService();

    await Future.wait<void>([
      _warmUpLogo(),
      _preloadInitialContent(_contentService),
      Future<void>.delayed(_minimumSplashDuration),
    ]);
  }

  @override
  void initState() {
    super.initState();
    _initFuture = _initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Başlatma hatası: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        }

        if (snapshot.connectionState != ConnectionState.done) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: const Color(0xFFF4F6FA),
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      _logoAssetPath,
                      colorFilter: const ColorFilter.mode(
                        _logoTintColor,
                        BlendMode.srcIn,
                      ),
                      width: 170,
                      height: 56,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 18),
                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: _logoTintColor
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return BirbucukAdanaApp(
          contentService: _contentService,
        );
      },
    );
  }
}
