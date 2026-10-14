import 'package:flutter/material.dart';

class ScannerOverlay extends StatelessWidget {
  final Rect scanWindow;
  
  const ScannerOverlay({
    super.key,
    required this.scanWindow,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ScannerOverlayPainter(
        scanWindow: scanWindow,
        color: Colors.black54,
        borderColor: Theme.of(context).colorScheme.primary,
        borderRadius: 16.0,
      ),
      child: Container(),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  final Rect scanWindow;
  final Color color;
  final Color borderColor;
  final double borderRadius;

  _ScannerOverlayPainter({
    required this.scanWindow,
    required this.color,
    required this.borderColor,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    
    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          scanWindow,
          Radius.circular(borderRadius),
        ),
      );

    final backgroundPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Use Path.combine to subtract the cutout from the background
    final overlayPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    canvas.drawPath(overlayPath, backgroundPaint);

    // Draw corners
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    const cornerLength = 30.0;
    
    // Top Left
    canvas.drawLine(
      Offset(scanWindow.left, scanWindow.top + cornerLength),
      Offset(scanWindow.left, scanWindow.top),
      borderPaint,
    );
    canvas.drawLine(
      Offset(scanWindow.left, scanWindow.top),
      Offset(scanWindow.left + cornerLength, scanWindow.top),
      borderPaint,
    );

    // Top Right
    canvas.drawLine(
      Offset(scanWindow.right - cornerLength, scanWindow.top),
      Offset(scanWindow.right, scanWindow.top),
      borderPaint,
    );
    canvas.drawLine(
      Offset(scanWindow.right, scanWindow.top),
      Offset(scanWindow.right, scanWindow.top + cornerLength),
      borderPaint,
    );

    // Bottom Right
    canvas.drawLine(
      Offset(scanWindow.right, scanWindow.bottom - cornerLength),
      Offset(scanWindow.right, scanWindow.bottom),
      borderPaint,
    );
    canvas.drawLine(
      Offset(scanWindow.right, scanWindow.bottom),
      Offset(scanWindow.right - cornerLength, scanWindow.bottom),
      borderPaint,
    );

    // Bottom Left
    canvas.drawLine(
      Offset(scanWindow.left + cornerLength, scanWindow.bottom),
      Offset(scanWindow.left, scanWindow.bottom),
      borderPaint,
    );
    canvas.drawLine(
      Offset(scanWindow.left, scanWindow.bottom),
      Offset(scanWindow.left, scanWindow.bottom - cornerLength),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter oldDelegate) {
    return oldDelegate.scanWindow != scanWindow ||
           oldDelegate.color != color ||
           oldDelegate.borderColor != borderColor;
  }
}
