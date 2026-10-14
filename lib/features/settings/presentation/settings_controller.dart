import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers.dart';
import '../../auth/domain/auth_repository.dart';
import 'settings_state.dart';

part 'settings_controller.g.dart';

@riverpod
class SettingsController extends _$SettingsController {
  @override
  SettingsState build() {
    _loadData();
    _listenToQueue();
    _listenToConnectivity();

    // Seed with the current WS latch so the card is correct on first paint,
    // instead of briefly flashing `false`.
    final webSocket = ref.read(webSocketServiceProvider);
    return SettingsState(isLoading: true, isConnected: webSocket.isConnected);
  }

  Future<void> _loadData() async {
    final db = ref.read(appDatabaseProvider);
    final session = await db.select(db.sessions).getSingleOrNull();

    state = state.copyWith(isLoading: false, session: session);
  }

  void _listenToQueue() {
    final dao = ref.read(queueDaoProvider);
    final subscription = dao.watchPendingCount().listen((count) {
      state = state.copyWith(pendingQueueCount: count);
    });
    ref.onDispose(subscription.cancel);
  }

  void _listenToConnectivity() {
    ref.listen<bool>(connectionStateProvider, (previous, next) {
      state = state.copyWith(isConnected: next);
    });
  }

  /// Unpairs the device, purges the offline queue (it carried the old
  /// `deviceId` baked in), and flips the auth flag so the router redirects
  /// to `/pairing` — the actual navigation is performed by the guard, so we
  /// don't need to `context.go` here.
  Future<void> unpair() async {
    state = state.copyWith(isLoading: true);
    try {
      await ref.read(authRepositoryProvider).unpair();
      // Flip the router guard's auth flag — let the GoRouter `redirect` take
      // the user to `/pairing`. Doing the navigation here (the old way) would
      // race with the guard and skip the redirect logic.
      ref.read(authStateProvider.notifier).set(false);
    } finally {
      // Reset loading so the screen doesn't get stuck on the spinner if the
      // redirect hasn't fired yet (audit: BUG-U2).
      state = state.copyWith(isLoading: false);
    }
  }
}
