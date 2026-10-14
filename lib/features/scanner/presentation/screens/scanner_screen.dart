import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../app/theme.dart';
import '../../../../shared/widgets/scanner_overlay.dart';
import '../../domain/product.dart';
import '../../domain/scanner_mode.dart';
import '../scanner_controller.dart';
import '../scanner_mode_provider.dart';
import '../scanner_state.dart';
import '../widgets/product_bottom_sheet.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    formats: const [BarcodeFormat.all],
  );

  bool _isProcessing = false;
  Product? _lastLivePosProduct;
  String? _lastMissingPosBarcode;
  Timer? _livePosBannerTimer;

  @override
  void dispose() {
    _livePosBannerTimer?.cancel();
    _scannerController.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (_isProcessing) return;
    final barcode = capture.barcodes.firstOrNull?.rawValue;
    if (barcode == null) return;

    ref.read(scannerControllerProvider.notifier).onBarcodeDetected(barcode);
  }

  @override
  Widget build(BuildContext context) {
    final currentMode = ref.watch(scannerModeNotifierProvider);

    ref.listen(scannerControllerProvider, (previous, next) {
      final mode = ref.read(scannerModeNotifierProvider);
      next.maybeWhen(
        processing: (barcode) {
          setState(() => _isProcessing = true);
          if (mode != ScannerMode.sale) {
            _scannerController.stop();
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) =>
                  const Center(child: CircularProgressIndicator()),
            );
          }
        },
        productFound: (product) {
          if (mode == ScannerMode.sale) {
            _showLivePosResult(product: product);
            return;
          }
          if (Navigator.canPop(context)) Navigator.pop(context);

          ProductBottomSheet.show(
            context,
            barcode: product.barcode,
            product: product,
            onDismiss: _resumeScanning,
            onEditProduct: () {
              context.push('/products/edit', extra: product);
            },
          );
        },
        productNotFound: (barcode) {
          if (mode == ScannerMode.sale) {
            _showLivePosResult(missingBarcode: barcode);
            return;
          }
          if (Navigator.canPop(context)) Navigator.pop(context);

          ProductBottomSheet.show(
            context,
            barcode: barcode,
            onDismiss: _resumeScanning,
            onAddProduct: () {
              context.push('/products/add?barcode=$barcode');
            },
          );
        },
        actionQueued: (message) {
          if (_isProcessing && Navigator.canPop(context)) {
            Navigator.pop(context);
          }

          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: BaloraColors.primary,
              duration: const Duration(milliseconds: 1500),
            ),
          );
          _resumeScanning();
        },
        error: (exception) {
          if (mode != ScannerMode.sale && Navigator.canPop(context)) {
            Navigator.pop(context);
          }

          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ: ${exception.message}'),
              backgroundColor: BaloraColors.error,
              duration: const Duration(milliseconds: 1500),
            ),
          );
          _resumeScanning();
        },
        orElse: () {},
      );
    });

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          currentMode.arabicTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.black54,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _scannerController,
              builder: (context, state, child) {
                switch (state.torchState) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.white);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.amber);
                  default:
                    return const Icon(Icons.flash_off, color: Colors.white54);
                }
              },
            ),
            tooltip: 'الفلاش',
            onPressed: () => _scannerController.toggleTorch(),
          ),
          if (currentMode == ScannerMode.inventory ||
              currentMode == ScannerMode.receiving)
            IconButton(
              icon: const Icon(Icons.list_alt_rounded, color: Colors.white),
              onPressed: () => context.push('/inventory/review'),
              tooltip: 'مراجعة المعلق',
            ),
          IconButton(
            icon: const Icon(Icons.cameraswitch_outlined, color: Colors.white),
            tooltip: 'تبديل الكاميرا',
            onPressed: () => _scannerController.switchCamera(),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final scanSize = (constraints.maxWidth * 0.64).clamp(200.0, 265.0);
          final scanWindow = Rect.fromCenter(
            center: Offset(
              constraints.maxWidth / 2,
              constraints.maxHeight * 0.46,
            ),
            width: scanSize,
            height: scanSize,
          );

          return Stack(
            fit: StackFit.expand,
            children: [
              MobileScanner(
                controller: _scannerController,
                onDetect: _handleBarcode,
                scanWindow: scanWindow,
                errorBuilder: (context, error) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'تعذر تشغيل الكاميرا.\nالخطأ: ${error.errorCode}\nالتفاصيل: ${error.errorDetails?.message ?? ''}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  );
                },
              ),
              ScannerOverlay(scanWindow: scanWindow),

              // شريط تبديل وضع المسح الفوري أعلى الشاشة تحت الـ AppBar
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: _buildModeSwitcher(currentMode),
                  ),
                ),
              ),

              if (currentMode == ScannerMode.sale &&
                  (_lastLivePosProduct != null ||
                      _lastMissingPosBarcode != null))
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 24 + MediaQuery.of(context).padding.bottom,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: _buildLivePosBanner(context),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton:
          (currentMode == ScannerMode.inventory ||
              currentMode == ScannerMode.receiving)
          ? Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: FloatingActionButton.extended(
                onPressed: () => context.push('/inventory/manual'),
                backgroundColor: BaloraColors.primary,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.edit_outlined, size: 20),
                label: const Text(
                  'إدخال يدوي',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildModeSwitcher(ScannerMode currentMode) {
    const modes = [
      (ScannerMode.sale, 'الكاشير', Icons.point_of_sale_rounded),
      (ScannerMode.search, 'فحص سعر', Icons.search_rounded),
      (ScannerMode.inventory, 'جرد', Icons.inventory_2_outlined),
      (ScannerMode.receiving, 'استلام', Icons.move_to_inbox_outlined),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: modes.map((entry) {
          final (mode, label, icon) = entry;
          final selected = mode == currentMode;
          return Flexible(
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                if (selected) return;
                _livePosBannerTimer?.cancel();
                setState(() {
                  _lastLivePosProduct = null;
                  _lastMissingPosBarcode = null;
                });
                ref.read(scannerModeNotifierProvider.notifier).set(mode);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: selected ? BaloraColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 15,
                      color: selected ? Colors.white : Colors.white70,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.white70,
                          fontSize: 12,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showLivePosResult({Product? product, String? missingBarcode}) {
    _livePosBannerTimer?.cancel();
    setState(() {
      _lastLivePosProduct = product;
      _lastMissingPosBarcode = missingBarcode;
      _isProcessing = false;
    });
    ref.read(scannerControllerProvider.notifier).reset();
    _livePosBannerTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _lastLivePosProduct = null;
          _lastMissingPosBarcode = null;
        });
      }
    });
  }

  String _formatIqdPrice(Product p) {
    if (p.description == 'بدون تسعير') return 'غير معرف';
    final currency = (p.description != null && p.description!.isNotEmpty)
        ? p.description!
        : 'IQD';
    if (currency.toUpperCase() == 'IQD') {
      final formatted = p.price.round().toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (m) => ',',
      );
      return '$formatted د.ع';
    }
    return '${p.price.toStringAsFixed(2)} $currency';
  }

  Widget _buildLivePosBanner(BuildContext context) {
    final p = _lastLivePosProduct;
    if (p == null) {
      return Card(
        color: Colors.red.shade900.withValues(alpha: 0.92),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'الباركود غير مسجل في الأصناف',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      _lastMissingPosBarcode ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      color: BaloraColors.surface.withValues(alpha: 0.96),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 22),
                const SizedBox(width: 6),
                const Text(
                  'أُرسل إلى الكاشير',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: BaloraColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    p.category,
                    style: const TextStyle(
                      color: BaloraColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              p.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: BaloraColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'السعر: ${_formatIqdPrice(p)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: BaloraColors.primary,
                  ),
                ),
                Text(
                  'الرصيد: ${p.quantity}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: p.quantity > 0 ? Colors.green.shade700 : Colors.red,
                  ),
                ),
                TextButton.icon(
                  onPressed: _isProcessing
                      ? null
                      : () {
                          ref
                              .read(scannerControllerProvider.notifier)
                              .onBarcodeDetected(
                                p.barcode,
                                forceSameBarcode: true,
                              );
                        },
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text(
                    '+1 قطعة',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: BaloraColors.primary,
                    backgroundColor: BaloraColors.primarySoft,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _resumeScanning() {
    setState(() => _isProcessing = false);
    _scannerController.start();
    ref.read(scannerControllerProvider.notifier).reset();
  }
}
