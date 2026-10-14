import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/result/result.dart';
import '../domain/product.dart';

part 'scanner_state.freezed.dart';

/// Represents the state of the scanner processing pipeline.
@freezed
class ScannerState with _$ScannerState {
  /// Waiting for a barcode.
  const factory ScannerState.idle() = _Idle;

  /// Currently processing a barcode (e.g., fetching from API).
  const factory ScannerState.processing(String barcode) = _Processing;

  /// Product was successfully found (Search Mode).
  const factory ScannerState.productFound(Product product) = _ProductFound;

  /// Product was not found in the database (Search Mode).
  const factory ScannerState.productNotFound(String barcode) = _ProductNotFound;

  /// An action was successfully queued (Inventory, Receiving, Product Modes).
  const factory ScannerState.actionQueued(String message) = _ActionQueued;

  /// An error occurred during processing.
  const factory ScannerState.error(AppException exception) = _Error;
}
