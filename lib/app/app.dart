import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';
import '../features/auth/domain/auth_repository.dart';
import 'router.dart';
import 'theme.dart';

/// The root widget of the Balora Mobile application.
///
/// Implements [WidgetsBindingObserver] so that when the user brings the app
/// to the foreground again (e.g. the next morning after it was backgrounded
/// overnight) we immediately re-arm the WebSocket reconnect and trigger a
/// sync cycle. This is the missing "App Resume" sync trigger that was
/// documented in `SyncEngine` but never wired anywhere (audit: BUG-R4).
class BaloraApp extends ConsumerStatefulWidget {
  const BaloraApp({super.key});

  @override
  ConsumerState<BaloraApp> createState() => _BaloraAppState();
}

class _BaloraAppState extends ConsumerState<BaloraApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // App came back to foreground — re-verify session with desktop and try a sync.
      ref.read(authRepositoryProvider).connectFromActiveSession().then((valid) {
        if (!valid && ref.read(authStateProvider)) {
          ref.read(authRepositoryProvider).hasActiveSession().then((
            hasSession,
          ) {
            if (!hasSession) {
              ref.read(authStateProvider.notifier).set(false);
            }
          });
        }
      });
      ref.read(syncEngineProvider).onPossiblyConnected();
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Balora Mobile',
      debugShowCheckedModeBanner: false,
      theme: BaloraTheme.light(),
      themeMode: ThemeMode.light,
      routerConfig: router,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
