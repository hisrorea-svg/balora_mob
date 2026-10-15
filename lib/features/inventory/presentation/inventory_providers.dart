import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/sync/database/app_database.dart';

/// Pending (not yet sent) stock count commands produced by the offline
/// fallback of the counting session; the home badge and the review screen
/// read this list. Command types are stored as Dart enum names.
final pendingCountCommandsProvider =
    StreamProvider<List<QueueItemEntry>>((ref) {
      final dao = ref.watch(queueDaoProvider);
      return dao.watchPendingItems().map((items) {
        return items
            .where(
              (item) =>
                  item.commandType == 'countScan' ||
                  item.commandType == 'countSet',
            )
            .toList();
      });
    });
