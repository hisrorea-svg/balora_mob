import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/api/models/command.dart';
import '../../../../core/providers.dart';
import '../../auth/domain/auth_repository.dart';
import '../../scanner/domain/product.dart';
import 'product_form_state.dart';

part 'product_form_controller.g.dart';

@riverpod
class ProductFormController extends _$ProductFormController {
  @override
  ProductFormState build() {
    return const ProductFormState.idle();
  }

  /// Submits the product data to the queue.
  /// If [isEdit] is true, it queues an Update command, otherwise an Add command.
  Future<void> submitProduct({
    required bool isEdit,
    required Product product,
  }) async {
    state = const ProductFormState.saving();

    final queueService = ref.read(queueServiceProvider);
    final authRepo = ref.read(authRepositoryProvider);

    try {
      final deviceId = await authRepo.getDeviceId();
      if (deviceId == null) {
        state = const ProductFormState.error('Device ID not found. Please pair again.');
        return;
      }

      await queueService.enqueueCommand(
        type: isEdit ? CommandType.updateProduct : CommandType.addProduct,
        deviceId: deviceId,
        barcode: product.barcode,
        payload: product.toJson(),
      );

      state = const ProductFormState.success();
    } catch (e) {
      state = ProductFormState.error(e.toString());
    }
  }
}
