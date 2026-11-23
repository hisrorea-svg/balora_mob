import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/bootstrap.dart';
import '../../../../core/result/result.dart';
import '../domain/auth_repository.dart';
import '../domain/desktop_server_source.dart';
import '../domain/link_preferences.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  /// Consecutive failed 6-digit-code attempts before a temporary
  /// lockout (the desktop also enforces its own limit).
  static const maxCodeAttempts = 5;

  /// How long code pairing is locked after [maxCodeAttempts] failures.
  static const codeLockout = Duration(minutes: 1);

  int _codeFailures = 0;
  DateTime? _codeLockedUntil;

  @override
  FutureOr<void> build() {}

  Future<void> pairWithQr(String rawQr, {String? deviceLabel}) async {
    // Prevent multiple requests if already loading
    if (state.isLoading) return;

    state = const AsyncValue.loading();

    final repo = ref.read(authRepositoryProvider);
    final result = await repo.pairWithQr(rawQr, deviceLabel: deviceLabel);

    switch (result) {
      case Success():
        await _rememberPairedServer(repo);
        state = const AsyncValue.data(null);
      case Failure(:final exception):
        state = AsyncValue.error(exception, StackTrace.current);
    }
  }

  /// Pairs with a desktop using a 6-digit code typed by the user.
  ///
  /// Guards the format locally (exactly 6 digits) and rate-limits
  /// repeated failures, then delegates to the repository, which uses
  /// the same pairing exchange as the QR flow.
  Future<void> pairWithCode({
    required String serverUrl,
    required String code,
    String? deviceLabel,
  }) async {
    if (state.isLoading) return;

    final lockedUntil = _codeLockedUntil;
    if (lockedUntil != null && DateTime.now().isBefore(lockedUntil)) {
      state = AsyncValue.error(
        UnknownException(
          'محاولات كثيرة فاشلة. جرّب مرة ثانية بعد دقيقة.',
          StackTrace.current,
        ),
        StackTrace.current,
      );
      return;
    }

    // Reject a malformed code locally — no network call, no attempt
    // counted against the lockout.
    if (!AuthRepository.isSixDigitCode(code.trim())) {
      state = AsyncValue.error(
        UnknownException('كود الربط لازم يكون 6 أرقام.', StackTrace.current),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncValue.loading();

    final repo = ref.read(authRepositoryProvider);
    final result = await repo.pairWithCode(
      serverUrl: serverUrl,
      code: code,
      deviceLabel: deviceLabel,
    );

    switch (result) {
      case Success():
        _codeFailures = 0;
        _codeLockedUntil = null;
        await _rememberPairedServer(repo);
        state = const AsyncValue.data(null);
      case Failure(:final exception):
        _codeFailures++;
        if (_codeFailures >= maxCodeAttempts) {
          _codeFailures = 0;
          _codeLockedUntil = DateTime.now().add(codeLockout);
        }
        state = AsyncValue.error(exception, StackTrace.current);
    }
  }

  /// Desktop servers available for code linking: discovered servers
  /// plus the remembered last-used one. Today discovery is manual-only
  /// (see [ManualDesktopServerSource]); mDNS plugs in later without
  /// changing this API.
  Future<List<DesktopServer>> loadServers() async {
    final prefs = await ref.read(linkPreferencesProvider.future);
    return ManualDesktopServerSource(prefs).discover();
  }

  /// The last server a pairing succeeded with, if any — used to
  /// prefill the manual address field on the code tab.
  Future<String?> lastServerUrl() async {
    final prefs = await ref.read(linkPreferencesProvider.future);
    return prefs.lastServerUrl;
  }

  /// Remembers the server of the session that was just paired, so the
  /// code flow can offer it next time. Best-effort: a failure here
  /// must never fail a pairing that already succeeded.
  Future<void> _rememberPairedServer(AuthRepository repo) async {
    try {
      final session = await repo.getActiveSession();
      final serverUrl = session?.serverUrl;
      if (serverUrl == null || serverUrl.isEmpty) return;
      final prefs = await ref.read(linkPreferencesProvider.future);
      await prefs.rememberServerUrl(serverUrl);
    } catch (e) {
      logger.w('Could not remember paired server: $e');
    }
  }
}
