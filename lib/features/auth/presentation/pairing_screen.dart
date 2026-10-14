import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../app/theme.dart';
import '../../../core/providers.dart';
import '../../../core/result/result.dart';
import '../../../shared/widgets/exit_confirmation_dialog.dart';
import '../../../shared/widgets/scanner_overlay.dart';
import 'auth_controller.dart';

class PairingScreen extends ConsumerStatefulWidget {
  const PairingScreen({super.key});

  @override
  ConsumerState<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends ConsumerState<PairingScreen> {
  late MobileScannerController _scannerController;
  final TextEditingController _labelController = TextEditingController(
    text: 'هاتف الصيدلية',
  );
  bool _isProcessing = false;
  String? _lastFailedPayload;
  DateTime? _lastFailedScanTime;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _labelController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  bool _isCandidatePairingPayload(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return false;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed.contains('code=') ||
          trimmed.contains('pairToken=') ||
          trimmed.contains('/m/');
    }
    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      return trimmed.contains('pairToken') || trimmed.contains('code');
    }
    return false;
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty || barcodes.first.rawValue == null) return;

    final qrData = barcodes.first.rawValue!;

    // Accept both Balora Desktop pairing URLs (/m/?code=...) and JSON payloads.
    if (!_isCandidatePairingPayload(qrData)) return;

    // منع تكرار المسح لنفس الرمز المتكرر بسرعة عند الفشل (مهلة 4 ثوانٍ)
    if (_lastFailedPayload == qrData &&
        _lastFailedScanTime != null &&
        DateTime.now().difference(_lastFailedScanTime!) <
            const Duration(seconds: 4)) {
      return;
    }

    setState(() => _isProcessing = true);

    // Haptic feedback for successful read
    HapticFeedback.vibrate();

    // Call controller to pair
    await ref
        .read(authControllerProvider.notifier)
        .pairWithQr(qrData, deviceLabel: _labelController.text.trim());

    // عند حدوث خطأ، نعطي مهلة زمنية قبل السماح بالمسح مجدداً لتجنب الإزعاج وتراكم الرسائل
    if (mounted) {
      final state = ref.read(authControllerProvider);
      if (state.hasError) {
        _lastFailedPayload = qrData;
        _lastFailedScanTime = DateTime.now();
        await Future.delayed(const Duration(milliseconds: 2500));
        if (mounted) {
          setState(() => _isProcessing = false);
        }
      }
    }
  }

  Future<void> _showManualPairingDialog() async {
    final linkOrCodeController = TextEditingController();
    final hostController = TextEditingController();

    final submittedPayload = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('إدخال بيانات الربط يدوياً'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'الصق «رابط الربط» المنسوخ من الكمبيوتر مباشرةً، أو أدخل عنوان الخادم وكود الربط:',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: linkOrCodeController,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    labelText: 'رابط الربط أو كود الربط',
                    hintText: 'https://192.168.1.15:4784/m/?code=...',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.paste),
                      tooltip: 'لصق من الحافظة',
                      onPressed: () async {
                        final clip = await Clipboard.getData('text/plain');
                        if (clip?.text != null) {
                          linkOrCodeController.text = clip!.text!.trim();
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: hostController,
                  textDirection: TextDirection.ltr,
                  decoration: const InputDecoration(
                    labelText: 'عنوان الكمبيوتر (عند إدخال الكود فقط)',
                    hintText: '192.168.1.15:4784',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                final raw = linkOrCodeController.text.trim();
                final host = hostController.text.trim();
                if (raw.isEmpty) return;

                if (raw.contains('code=') ||
                    raw.startsWith('http://') ||
                    raw.startsWith('https://') ||
                    raw.startsWith('{')) {
                  Navigator.of(ctx).pop(raw);
                  return;
                }

                if (host.isNotEmpty) {
                  final normalizedHost =
                      (host.startsWith('http://') ||
                          host.startsWith('https://'))
                      ? host
                      : 'https://$host';
                  final cleanHost = normalizedHost.endsWith('/')
                      ? normalizedHost.substring(0, normalizedHost.length - 1)
                      : normalizedHost;
                  Navigator.of(
                    ctx,
                  ).pop('$cleanHost/m/?code=${Uri.encodeQueryComponent(raw)}');
                }
              },
              child: const Text('اقتران'),
            ),
          ],
        );
      },
    );

    linkOrCodeController.dispose();
    hostController.dispose();

    if (submittedPayload == null || submittedPayload.isEmpty || !mounted) {
      return;
    }

    setState(() => _isProcessing = true);
    await ref
        .read(authControllerProvider.notifier)
        .pairWithQr(
          submittedPayload,
          deviceLabel: _labelController.text.trim(),
        );
    if (mounted && ref.read(authControllerProvider).hasError) {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for state changes (Success / Error)
    ref.listen(authControllerProvider, (previous, next) {
      if (next.hasError) {
        // مسح أي رسائل سابقة فوراً لمنع تراكم الإشعارات
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    getErrorMessage(next.error),
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: BaloraColors.error,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else if (!next.isLoading && !next.hasError && next.hasValue) {
        // Success — flip the router's auth flag so the redirect flips to home
        // instead of bouncing back to /pairing.
        ref.read(authStateProvider.notifier).set(true);
        // إيقاف الكاميرا أولاً وإعطاء وقت بسيط للهاتف لتحرير موارد الكاميرا لتجنب تداخل الشاشتين
        _scannerController.stop().then((_) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (context.mounted) context.go('/home');
          });
        });
      }
    });

    final isLoading = ref.watch(authControllerProvider).isLoading;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
          return;
        }
        final shouldExit = await showExitConfirmationDialog(context);
        if (shouldExit) {
          await SystemNavigator.pop();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('الاقتران بنظام Balora للكمبيوتر'),
          actions: [
            IconButton(
              icon: ValueListenableBuilder(
                valueListenable: _scannerController,
                builder: (context, state, child) {
                  switch (state.torchState) {
                    case TorchState.off:
                      return const Icon(Icons.flash_off, color: Colors.grey);
                    case TorchState.on:
                      return const Icon(Icons.flash_on, color: Colors.amber);
                    default:
                      return const Icon(Icons.flash_off, color: Colors.grey);
                  }
                },
              ),
              onPressed: () => _scannerController.toggleTorch(),
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final scanWindowSize = (constraints.maxWidth * 0.62).clamp(
              200.0,
              260.0,
            );
            final scanWindow = Rect.fromCenter(
              center: Offset(
                constraints.maxWidth / 2,
                constraints.maxHeight * 0.47,
              ),
              width: scanWindowSize,
              height: scanWindowSize,
            );

            return Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(
                  controller: _scannerController,
                  onDetect: _onDetect,
                  scanWindow: scanWindow,
                  errorBuilder: (context, error) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'تعذر تشغيل الكاميرا.\nالخطأ: ${error.errorCode}\nالتفاصيل: ${error.errorDetails?.message}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                ScannerOverlay(scanWindow: scanWindow),

                // حقل اسم الهاتف في الأعلى بعيداً عن مربع المسح
                Positioned(
                  top: 16,
                  left: 24,
                  right: 24,
                  child: TextField(
                    controller: _labelController,
                    maxLength: 60,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'اسم الهاتف على الكمبيوتر',
                      labelStyle: const TextStyle(color: Colors.white70),
                      counterText: '',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: Colors.black54,
                      prefixIcon: const Icon(
                        Icons.phone_android,
                        color: Colors.white70,
                        size: 20,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white38),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                ),

                // التعليمات وزر الإدخال اليدوي في الأسفل بعيداً عن مربع المسح
                Positioned(
                  bottom: 24 + MediaQuery.of(context).padding.bottom,
                  left: 24,
                  right: 24,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'قم بمسح رمز QR المعروض\nعلى نظام Balora للكمبيوتر.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton.icon(
                        onPressed: _isProcessing
                            ? null
                            : _showManualPairingDialog,
                        icon: const Icon(
                          Icons.keyboard_alt_outlined,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'إدخال الرابط أو الكود يدوياً',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.black54,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: Colors.white38),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (isLoading)
                  Container(
                    color: Colors.black54,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
