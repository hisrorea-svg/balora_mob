import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/sync/database/app_database.dart';

final pendingInventoryItemsProvider = StreamProvider<List<QueueItemEntry>>((ref) {
  final dao = ref.watch(queueDaoProvider);
  return dao.watchPendingItems().map((items) {
    return items.where((item) => 
      item.commandType == 'inventory_scan' || item.commandType == 'inventory_submit'
    ).toList();
  });
});
