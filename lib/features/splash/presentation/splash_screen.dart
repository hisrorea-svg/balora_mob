import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/providers.dart';
import '../../auth/domain/auth_repository.dart';

/// Startup handshake screen shown before any other route.
///
/// Guest mode: the splash never blocks entry. It initializes the sync
/// engine and verifies a persisted session in the background (which
/// also applies sliding renewal and purges a session the desktop
/// revoked with 401), then always goes to `/home`. Whether the device
/// is linked is shown on Home — never by forcing the user to pair.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    // Defer to next frame so `ref` is ready and the router has built once.
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    // 1) Initialize the SyncEngine once (idempotent listeners + stuck-item
    //    recovery). Safe even if there is no session.
    await ref.read(syncEngineProvider).initialize();

    // 2) If a session exists, verify it with the desktop. This is
    //    best-effort: no session, an expired session, or an
    //    unreachable desktop all simply mean "not linked" — the user
    //    still lands on Home and can link from there.
    final auth = ref.read(authRepositoryProvider);
    await auth.connectFromActiveSession();
    final linked = await auth.hasActiveSession();

    // 3) Always go home. Keep the GoRouter guard in sync with the
    //    link state. This is the only place that decides the
    //    post-splash entry route, so it owns the `authStateProvider`
    //    value at startup.
    _go('/home', linked: linked);
  }

  void _go(String location, {required bool linked}) {
    if (_navigated) return;
    _navigated = true;
    if (!mounted) return;
    ref.read(authStateProvider.notifier).set(linked);
    context.go(location);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BaloraColors.surface,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 96,
                    height: 96,
                    child: Image.asset(
                      'assets/images/balora_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(
                            Icons.local_pharmacy_rounded,
                            size: 64,
                            color: BaloraColors.primary,
                          ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Balora',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: BaloraColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'نظام إدارة الصيدليات',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: BaloraColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 36),
                  const SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        BaloraColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'جارٍ التحقق من الاتصال بالكمبيوتر…',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: BaloraColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 16,
              child: Center(
                child: Text(
                  'Balora Mobile Companion • الإصدار 1.0.7',
                  style: TextStyle(
                    fontSize: 11,
                    color: BaloraColors.textMuted.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
