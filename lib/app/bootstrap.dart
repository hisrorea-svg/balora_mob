import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import 'app.dart';
import 'router.dart';

/// Global logger instance.
final logger = Logger(
  printer: PrettyPrinter(methodCount: 0, errorMethodCount: 5, lineLength: 80),
);

/// Initializes all services and runs the app.
///
/// Order matters:
/// 1. System UI configuration
/// 2. Logger setup
/// 3. Run app inside ProviderScope
///
/// Database (Drift) and Dio are initialized lazily via Riverpod providers.
/// The actual connection handshake now happens on the [SplashScreen] — see
/// `lib/features/splash/presentation/splash_screen.dart` — so `bootstrap`
/// no longer needs to peek at the session row before `runApp` only to pick
/// an initial route. The splash screen always handles that decision after
/// the engine is wired up.
Future<void> bootstrap() async {
  // Lock orientation to portrait for scanning ergonomics.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Enable edge-to-edge system UI for modern Android (14/15/16) and iOS.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // System UI style with transparent status and navigation bars.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    ),
  );

  logger.i('🚀 Balora Mobile starting...');

  // Single ProviderContainer — the previous version built *two* containers
  // and discarded the first one's ApiClient wiring (BUG-R6). Now everything
  // lives in the same scope.
  final container = ProviderContainer(
    overrides: [initialLocationProvider.overrideWithValue('/splash')],
  );

  runApp(
    UncontrolledProviderScope(container: container, child: const BaloraApp()),
  );
}
