import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/scanner_mode.dart';

part 'scanner_mode_provider.g.dart';

/// Provides the currently active [ScannerMode].
///
/// Defaults to [ScannerMode.search] and is mutated via
/// `ref.read(scannerModeNotifierProvider.notifier).state = ScannerMode.sale`
/// style calls from the home page.
///
/// (Using a `Notifier` keep-around class so the lint rule
/// `avoid_manual_providers_as_generated_provider_dependency` stays satisfied
/// — the previous `StateProvider<Scanner_mode` form made the generated
/// `ScannerController` depend on a manual provider.)
@Riverpod(keepAlive: true)
class ScannerModeNotifier extends _$ScannerModeNotifier {
  @override
  ScannerMode build() => ScannerMode.search;

  /// Changes the active scanner mode. [Notifier.state] is protected, so
  /// callers go through this method instead of writing `state` directly.
  void set(ScannerMode mode) => state = mode;
}

/// Backwards-compatible alias for Riverpod 2 callers.
final scannerModeNotifierProvider = scannerModeProvider;
