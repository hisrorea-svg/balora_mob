import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers.dart';
import '../features/auth/presentation/link_screen.dart';
import '../features/counts/domain/count_models.dart';
import '../features/counts/presentation/count_session_screen.dart';
import '../features/counts/presentation/counts_screen.dart';
import '../features/drafts/presentation/draft_entry_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/inventory/presentation/screens/inventory_review_screen.dart';
import '../features/products/presentation/screens/product_form_screen.dart';
import '../features/scanner/domain/product.dart';
import '../features/scanner/presentation/screens/scanner_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/splash/presentation/splash_screen.dart';

/// Provider for the initial route, overridden at startup. The default is
/// `/splash` so the handshake screen always runs first.
final initialLocationProvider = Provider<String>((ref) => '/splash');

/// A lightweight [Listenable] used so the GoRouter re-runs its `redirect`
/// when [authStateProvider] flips. We proxy state changes through it.
class _AuthRedirectListenable extends ChangeNotifier {
  _AuthRedirectListenable(this._ref) {
    _sub = _ref.listen<bool>(authStateProvider, (_, _) => notifyListeners());
  }
  final Ref _ref;
  late final ProviderSubscription<bool> _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}

/// Provides the GoRouter instance for the app.
final routerProvider = Provider<GoRouter>((ref) {
  final initialLocation = ref.watch(initialLocationProvider);
  final refreshListenable = _AuthRedirectListenable(ref);
  ref.onDispose(refreshListenable.dispose);

  return GoRouter(
    initialLocation: initialLocation,
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final linked = ref.read(authStateProvider);
      final path = state.matchedLocation;

      // Guest mode: the app opens without a session. Nothing forces
      // the user to `/pairing` any more — linking is an explicit
      // action from Settings or the Home banner, and `/pairing` is
      // only a deep link. The only redirect left keeps a linked user
      // from lingering on the splash screen.
      if (linked && path == '/splash') return '/home';

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/scan',
        name: 'scan',
        builder: (context, state) => const ScannerScreen(),
      ),
      GoRoute(
        path: '/pairing',
        name: 'pairing',
        builder: (context, state) => const LinkScreen(),
      ),
      // Products routes
      GoRoute(
        path: '/products/add',
        name: 'add_product',
        builder: (context, state) {
          final barcode = state.uri.queryParameters['barcode'];
          return ProductFormScreen(initialBarcode: barcode);
        },
      ),
      GoRoute(
        path: '/products/edit',
        name: 'edit_product',
        builder: (context, state) {
          final product = state.extra as Product?;
          return ProductFormScreen(product: product);
        },
      ),
      // Warehouse Receiving & Staging Drafts route
      GoRoute(
        path: '/drafts/entry',
        name: 'draft_entry',
        builder: (context, state) {
          final barcode = state.uri.queryParameters['barcode'];
          return DraftEntryScreen(initialBarcode: barcode);
        },
      ),
      // Stock count routes
      GoRoute(
        path: '/counts',
        name: 'counts',
        builder: (context, state) => const CountsScreen(),
      ),
      GoRoute(
        path: '/counts/session',
        name: 'count_session',
        builder: (context, state) {
          final count = state.extra;
          if (count is! ActiveCount) return const CountsScreen();
          return CountSessionScreen(count: count);
        },
      ),
      // Inventory routes
      GoRoute(
        path: '/inventory/review',
        name: 'inventory_review',
        builder: (context, state) => const InventoryReviewScreen(),
      ),
      // Settings route
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
