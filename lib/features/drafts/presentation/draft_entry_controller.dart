import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers.dart';
import '../../../core/result/result.dart';
import '../../auth/domain/auth_repository.dart';
import '../../products/data/drug_suggestion_service.dart';
import '../../products/domain/models/drug_suggestion.dart';
import '../../scanner/domain/product.dart';
import '../../scanner/domain/product_repository.dart';
import '../domain/draft_product.dart';
import 'draft_entry_state.dart';

part 'draft_entry_controller.g.dart';

sealed class BarcodeCheckResult {
  const BarcodeCheckResult();
}

class BarcodeFoundInPharmacy extends BarcodeCheckResult {
  final Product product;
  const BarcodeFoundInPharmacy(this.product);
}

class BarcodeFoundInReference extends BarcodeCheckResult {
  final DrugSuggestion suggestion;
  const BarcodeFoundInReference(this.suggestion);
}

class BarcodeNotFound extends BarcodeCheckResult {
  const BarcodeNotFound();
}

@riverpod
class DraftEntryController extends _$DraftEntryController {
  @override
  DraftEntryState build() {
    return const DraftEntryState.idle();
  }

  /// Submits the drafted product into the local sync queue for desktop staging.
  Future<String?> submitDraft(DraftProduct draft) async {
    state = const DraftEntryState.saving();

    final queueService = ref.read(queueServiceProvider);
    final authRepo = ref.read(authRepositoryProvider);

    try {
      final deviceId = await authRepo.getDeviceId();
      if (deviceId == null) {
        state = const DraftEntryState.error(
          'لم يتم العثور على معرّف الجهاز. يرجى إعادة الاقتران بالحاسوب.',
        );
        return null;
      }

      final draftMap = draft.toJson();

      final commandId = await queueService.enqueueProductDraft(
        deviceId: deviceId,
        draftData: draftMap,
        barcode: draft.barcode,
      );

      state = DraftEntryState.success(draftId: commandId);
      return commandId;
    } catch (e) {
      state = DraftEntryState.error('فشل حفظ المسودة: $e');
      return null;
    }
  }

  /// Performs dual-check on a barcode:
  /// 1. First against existing pharmacy inventory via desktop API.
  /// 2. Then against the offline pharmaceutical reference database (19,300+ items).
  Future<BarcodeCheckResult> checkBarcode(String barcode) async {
    final cleanBarcode = barcode.trim();
    if (cleanBarcode.isEmpty) {
      return const BarcodeNotFound();
    }

    try {
      // 1. Check live pharmacy catalog
      final pharmacyCheck = await ref
          .read(productRepositoryProvider)
          .getProductByBarcode(cleanBarcode);

      if (pharmacyCheck case Success(:final data)) {
        return BarcodeFoundInPharmacy(data);
      }
    } catch (_) {
      // If network is offline or server unreachable, proceed gracefully to offline catalog
    }

    // 2. Check offline pharmaceutical reference catalog
    final drugService = ref.read(drugSuggestionServiceProvider);
    final referenceDrug = drugService.lookupByBarcode(cleanBarcode);
    if (referenceDrug != null) {
      return BarcodeFoundInReference(referenceDrug);
    }

    return const BarcodeNotFound();
  }

  void resetState() {
    state = const DraftEntryState.idle();
  }
}
