import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;

class ScanPage extends StatefulWidget {
  final String userId; // รับ userId เพื่อส่ง redeem
  const ScanPage({super.key, required this.userId});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  String? scannedCode;
  bool isScanned = false;
  bool isRedeeming = false;

  final MobileScannerController _controller = MobileScannerController();

  void handleBarcode(BarcodeCapture capture) async {
    if (!isScanned && capture.barcodes.isNotEmpty) {
      final String code = capture.barcodes.first.rawValue ?? '---';
      setState(() {
        scannedCode = code;
        isScanned = true;
      });

      _controller.stop();

      // แสดง Dialog และพร้อม Redeem
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
              onPressed: () async {
                Navigator.of(context).pop();
                await _redeemPoints(code);
              },
              child: isRedeeming
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Redeem Points'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _redeemPoints(String qrData) async {
    setState(() {
      isRedeeming = true;
    });

    try {
      final data = json.decode(qrData);

      final candies = data['candies'];
      final points = data['points'];

      final res = await http.post(
        Uri.parse('http://192.168.126.1:8000/redeem'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'u_id': widget.userId,
          'items': candies,
          'points': points,
        }),
      );

      if (res.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Redeemed successfully!')),
          );
          Navigator.of(context).pop(); // กลับหน้าก่อนหน้า
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Redeem failed: ${res.body}')),
          );
          setState(() {
            isScanned = false; // ให้ลองสแกนใหม่
          });
          _controller.start();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error parsing QR: $e')),
        );
        setState(() {
          isScanned = false;
        });
        _controller.start();
      }
    } finally {
      setState(() {
        isRedeeming = false;
      });
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
            onPressed: () {
              _controller.toggleTorch();
            },
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () {
              _controller.switchCamera();
            },
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

          // Focus square overlay
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
    const double borderSize = 250; // square size
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
