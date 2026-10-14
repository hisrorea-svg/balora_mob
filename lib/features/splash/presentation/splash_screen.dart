import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../auth/domain/auth_repository.dart';

/// Startup handshake screen shown before any other route.
///
/// Responsibilities (in order):
/// 1. Verify a non-expired pairing session exists.
/// 2. If not → redirect to `/pairing`.
/// 3. If yes → open the authenticated WebSocket and wait (≤ 6s) for the
///    desktop's `ready` frame, which is the *verified* link signal.
/// 4. On success → redirect to `/home`.
/// 5. On timeout or handshake failure → redirect to `/pairing` so the user
///    can re-pair, instead of silently landing on Home showing "متصل" while
///    the desktop reports 0 devices.
///
/// This replaces the previous behaviour where `bootstrap()` would `runApp`
/// straight onto `/home` after merely finding a session row, with no
/// splash and no handshake — see the audit report (BUG-A2, BUG-R2,
/// Find-4.1).
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  /// How long to wait for the desktop's `ready` frame before giving up and
  /// asking the user to re-pair.
  static const _handshakeTimeout = Duration(seconds: 6);

  StreamSubscription<bool>? _connSub;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    // Defer to next frame so `ref` is ready and the router has built once.
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  @override
  void dispose() {
    _connSub?.cancel();
    super.dispose();
  }

  Future<void> _run() async {
    // 1) Initialize the SyncEngine once (idempotent listeners + stuck-item
    //    recovery). Safe even if there is no session.
    await ref.read(syncEngineProvider).initialize();

    // 2) Look for a *valid* (non-expired) session and wire the ApiClient.
    final auth = ref.read(authRepositoryProvider);
    final session = await auth.getActiveSession();

    if (session == null) {
      _go('/pairing');
      return;
    }

    // 3) Verify the persisted session with the desktop's `/m/api/session`
    //    endpoint (or WebSocket handshake if used).
    final verified = await auth.connectFromActiveSession();

    // If the link is already verified by the time we get here, short-circuit.
    if (verified || ref.read(webSocketServiceProvider).isConnected) {
      _go('/home');
      return;
    }

    // If the session was purged because of a 401 (revoked/expired on desktop),
    // go straight to `/pairing` without waiting.
    if (!await auth.hasActiveSession()) {
      _go('/pairing');
      return;
    }

    // 4) Otherwise race the connection stream against a timeout.
    final completer = Completer<bool>();
    _connSub = ref.read(webSocketServiceProvider).onConnectionChanged.listen((
      connected,
    ) {
      if (connected && !completer.isCompleted) {
        completer.complete(true);
      }
    });
    Timer(_handshakeTimeout, () {
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    });

    final linked = await completer.future;
    await _connSub?.cancel();
    _connSub = null;

    // 5) Decide.
    _go(linked ? '/home' : '/pairing');
  }

  void _go(String location) {
    if (_navigated) return;
    _navigated = true;
    if (!mounted) return;
    // Keep the GoRouter guard in sync with where we land. This is the only
    // place that decides the post-splash entry route, so it owns the
    // `authStateProvider` value at startup.
    ref.read(authStateProvider.notifier).set(location == '/home');
    context.go(location);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.link,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Balora Mobile',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'جارٍ التحقق من الاتصال…',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
