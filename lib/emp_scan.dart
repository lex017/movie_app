import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:movie_app/cash/scanpoint.dart';
import 'check.dart'; // หรือเปลี่ยนเป็น DetailTicket page

class ScanPage extends StatefulWidget {
  final String userId;
  const ScanPage({super.key, required this.userId});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  String? scannedCode;
  bool isScanned = false;
  final MobileScannerController _controller = MobileScannerController();

  void handleBarcode(BarcodeCapture capture) async {
  if (!isScanned && capture.barcodes.isNotEmpty) {
    final String code = capture.barcodes.first.rawValue ?? '---';
    setState(() {
      scannedCode = code;
      isScanned = true;
    });

    _controller.stop();

    try {
      final data = json.decode(code); // QR contains JSON: {"ticketId": 123}
      final ticketId = data['ticketId'];

      final res = await http.get(
        Uri.parse('http://192.168.0.195:8000/ticket/$ticketId'),
      );

      if (res.statusCode == 200) {
        final ticket = json.decode(res.body);
        final status = ticket['status'];

        if (status == 'paid') {
          // ✅ ไปหน้า Check หรือ DetailTicket page
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const Check(), 
              ),
            );
          }
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => RedeemPointsPage(userId: widget.userId),
            ),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RedeemPointsPage(userId: widget.userId),
          ),
        );
      }
    } catch (e) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RedeemPointsPage(userId: widget.userId),
        ),
      );
    }
  }
}


  void _restartScan() {
    setState(() => isScanned = false);
    _controller.start();
  }

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
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

class ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double borderSize = 250;
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
