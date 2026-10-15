import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers.dart';
import '../data/count_api.dart';
import '../domain/count_models.dart';

part 'counts_providers.g.dart';

@Riverpod(keepAlive: true)
CountApi countApi(Ref ref) => CountApi(ref.watch(apiClientProvider));

/// The open (draft) counts visible to the phone's session site.
@riverpod
Future<List<ActiveCount>> activeCounts(Ref ref) {
  return ref.watch(countApiProvider).listActiveCounts();
}
