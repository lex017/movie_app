import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  String? scannedCode;
  bool isScanned = false;
  final MobileScannerController _controller = MobileScannerController();

  void handleBarcode(BarcodeCapture capture) {
    if (!isScanned && capture.barcodes.isNotEmpty) {
      final String code = capture.barcodes.first.rawValue ?? '---';
      setState(() {
        scannedCode = code;
        isScanned = true;
      });

      _controller.stop();

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('QR Code Scanned'),
          content: Text('Scanned Data:\n$code'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() => isScanned = false);
                _controller.start();
                Navigator.of(context).pop();
              },
              child: const Text('Scan Again'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(code);
              },
              child: const Text('Finish'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.red,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: handleBarcode,
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Point your camera at a QR code',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),

          // ✅ Focus square overlay
          Center(
            child: CustomPaint(
              painter: ScannerOverlay(),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ Painter for the square focus overlay
class ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double borderSize = 250; // Size of the square
    final Paint paint = Paint()..color = Colors.black.withOpacity(0.5);
    final Path overlayPath = Path.combine(
      PathOperation.difference,
      Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
      Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(size.width / 2, size.height / 2),
              width: borderSize,
              height: borderSize,
            ),
            const Radius.circular(16),
          ),
        ),
    );
    canvas.drawPath(overlayPath, paint);

    // Optional: Draw white border around the focus square
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2),
          width: borderSize,
          height: borderSize,
        ),
        const Radius.circular(16),
      ),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
