import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/result/result.dart';
import '../domain/auth_repository.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
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
        state = const AsyncValue.data(null);
      case Failure(:final exception):
        state = AsyncValue.error(exception, StackTrace.current);
    }
  }
}
