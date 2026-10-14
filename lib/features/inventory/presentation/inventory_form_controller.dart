import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/api/models/command.dart';
import '../../../../core/providers.dart';
import '../../auth/domain/auth_repository.dart';
import 'inventory_form_state.dart';

part 'inventory_form_controller.g.dart';

@riverpod
class InventoryFormController extends _$InventoryFormController {
  @override
  InventoryFormState build() {
    return const InventoryFormState.idle();
  }

  Future<void> submitInventory({
    required CommandType type,
    required String barcode,
    required int quantity,
  }) async {
    state = const InventoryFormState.saving();

    final queueService = ref.read(queueServiceProvider);
    final authRepo = ref.read(authRepositoryProvider);

    try {
      final deviceId = await authRepo.getDeviceId();
      if (deviceId == null) {
        state = const InventoryFormState.error(
          'Device ID not found. Please pair again.',
        );
        return;
      }

      await queueService.enqueueCommand(
        type: type,
        deviceId: deviceId,
        barcode: barcode,
        payload: {
          'barcode': barcode,
          'quantity': quantity,
          'action': type == CommandType.inventorySubmit ? 'receive' : 'count',
        },
      );

      state = const InventoryFormState.success();
    } catch (e) {
      state = InventoryFormState.error(e.toString());
    }
  }
}
