import 'dart:async';

import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/api/models/command.dart';
import '../../../../core/providers.dart';
import '../../../../core/result/result.dart';
import '../../auth/domain/auth_repository.dart';
import '../domain/product_repository.dart';
import '../domain/scanner_mode.dart';
import 'scanner_mode_provider.dart';
import 'scanner_state.dart';

part 'scanner_controller.g.dart';

@riverpod
class ScannerController extends _$ScannerController {
  String? _lastScannedBarcode;
  DateTime? _lastScanTime;
  bool _isBusy = false;

  static const _sameBarcodeCooldown = Duration(milliseconds: 2500);

  @override
  ScannerState build() {
    return const ScannerState.idle();
  }

  /// Called when the camera detects a barcode.
  Future<void> onBarcodeDetected(
    String barcode, {
    bool forceSameBarcode = false,
  }) async {
    if (_isBusy) return;
    barcode = barcode.trim();
    if (barcode.isEmpty) return;

    // Ignore pairing QR codes if accidentally scanned here
    if (barcode.contains('"pairToken"') ||
        barcode.startsWith('{') ||
        barcode.contains('/m/?code=') ||
        barcode.contains('?code=')) {
      return;
    }

    // Same-barcode cooldown: prevents 30fps camera loop from flooding the
    // server with identical scans while still allowing a *different* barcode
    // to be scanned immediately with zero delay.
    final now = DateTime.now();
    if (!forceSameBarcode &&
        _lastScannedBarcode == barcode &&
        _lastScanTime != null &&
        now.difference(_lastScanTime!) < _sameBarcodeCooldown) {
      return;
    }

    _isBusy = true;
    _lastScannedBarcode = barcode;
    _lastScanTime = now;

    try {
      // Haptic feedback
      HapticFeedback.lightImpact();

      state = ScannerState.processing(barcode);

      final mode = ref.read(scannerModeNotifierProvider);
      final repo = ref.read(productRepositoryProvider);
      final queueService = ref.read(queueServiceProvider);
      final authRepo = ref.read(authRepositoryProvider);

      final deviceId = await authRepo.getDeviceId();
      if (deviceId == null) {
        _clearDedupeMemory();
        state = const ScannerState.error(
          UnknownException('Device ID not found. Please pair again.'),
        );
        return;
      }

      switch (mode) {
        case ScannerMode.search:
          await _handleSearchMode(barcode, repo, authRepo, symbology: 'lookup');
        case ScannerMode.sale:
          await _handleSearchMode(barcode, repo, authRepo, symbology: 'pos');
        case ScannerMode.inventory:
          await queueService.enqueueCommand(
            type: CommandType.inventoryScan,
            deviceId: deviceId,
            payload: {'barcode': barcode, 'timestamp': now.toIso8601String()},
          );
          state = const ScannerState.actionQueued('Inventory count queued');
        case ScannerMode.receiving:
          await queueService.enqueueCommand(
            type: CommandType.inventorySubmit,
            deviceId: deviceId,
            payload: {
              'barcode': barcode,
              'timestamp': now.toIso8601String(),
              'action': 'receive',
            },
          );
          state = const ScannerState.actionQueued('Receiving scan queued');
        case ScannerMode.product:
          state = const ScannerState.actionQueued('Product mode selected');
      }
    } finally {
      // Refresh cooldown timestamp at completion so the 2.5s window starts
      // after the network round-trip finishes.
      if (_lastScannedBarcode == barcode) {
        _lastScanTime = DateTime.now();
      }
      _isBusy = false;
    }
  }

  Future<void> _handleSearchMode(
    String barcode,
    ProductRepository repo,
    AuthRepository authRepo, {
    String symbology = '',
  }) async {
    final result = await repo.getProductByBarcode(
      barcode,
      symbology: symbology,
    );

    switch (result) {
      case Success(:final data):
        state = ScannerState.productFound(data);
      case Failure(:final exception):
        if (exception is NotFoundException) {
          state = ScannerState.productNotFound(barcode);
        } else if (exception is UnauthorizedException) {
          _clearDedupeMemory();
          await authRepo.unpair();
          ref.read(authStateProvider.notifier).set(false);
          state = ScannerState.error(exception);
        } else {
          // Allow immediate retry when the request failed due to a network blip.
          _clearDedupeMemory();
          state = ScannerState.error(exception);
        }
    }
  }

  void _clearDedupeMemory() {
    _lastScannedBarcode = null;
    _lastScanTime = null;
  }

  /// Resets the controller state back to [ScannerState.idle] while keeping
  /// the last-scanned barcode cooldown intact so continuous 30fps camera
  /// frames don't re-fire the same barcode in a loop.
  void reset({bool clearLastBarcode = false}) {
    _isBusy = false;
    if (clearLastBarcode) {
      _clearDedupeMemory();
    }
    state = const ScannerState.idle();
  }
}
