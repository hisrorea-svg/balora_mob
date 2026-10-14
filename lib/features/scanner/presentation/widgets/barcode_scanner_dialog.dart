import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

Future<String?> showBarcodeScannerDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (context) => const _BarcodeScannerDialog(),
  );
}

class _BarcodeScannerDialog extends StatefulWidget {
  const _BarcodeScannerDialog();

  @override
  State<_BarcodeScannerDialog> createState() => _BarcodeScannerDialogState();
}

class _BarcodeScannerDialogState extends State<_BarcodeScannerDialog> {
  final MobileScannerController _controller = MobileScannerController();
  bool _hasScanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 400,
        child: Stack(
          children: [
            MobileScanner(
              controller: _controller,
              onDetect: (capture) {
                if (_hasScanned) return;
                final barcode = capture.barcodes.firstOrNull?.rawValue;
                if (barcode != null && barcode.isNotEmpty) {
                  _hasScanned = true;
                  Navigator.of(context).pop(barcode);
                }
              },
              errorBuilder: (context, error) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'تعذر تشغيل الكاميرا.\nالخطأ: ${error.errorCode}\nالتفاصيل: ${error.errorDetails?.message}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'وجه الكاميرا نحو الباركود',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
