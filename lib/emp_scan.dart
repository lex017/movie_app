import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:movie_app/cash/scanpoint.dart';
import 'check.dart';

class ScanPage extends StatefulWidget {
  final String userId;
  const ScanPage({super.key, required this.userId});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  bool isScanned = false;
  final MobileScannerController _controller = MobileScannerController();

  void handleBarcode(BarcodeCapture capture) async {
    if (!isScanned && capture.barcodes.isNotEmpty) {
      final String code = capture.barcodes.first.rawValue ?? '';
      setState(() => isScanned = true);
      _controller.stop();

      try {
        final data = json.decode(code);

        // 🎟 Ticket QR logic
        if (data.containsKey('ticketId')) {
          final ticketId = data['ticketId'];

          final res = await http.get(
            Uri.parse('http://192.168.0.196:8000/ticket/$ticketId'),
          );

          if (res.statusCode == 200) {
            final ticket = json.decode(res.body);
            if (ticket['status'] == 'paid') {
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Check(ticketId: ticketId.toString()),
                  ),
                );
              }
            } else {
              _showMessage("❌ Ticket is not paid");
            }
          } else {
            _showMessage("❌ Ticket not found");
          }
        }

        // 🎁 Reward QR logic
        else if (data.containsKey('u_id') && data.containsKey('point')) {
          final userId = data['u_id'].toString();
          final totalPoints = data['point'];
          final candies = List<String>.from(data['candies'] ?? []);

          final selectedCandies =
              candies.map((name) => {"name": name}).toList();

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => RedeemPointsPage(
                  userId: userId,
                 
                  selectedCandies: selectedCandies,
                  totalPoints: totalPoints,
                ),
              ),
            );
          }
        } else {
          _showMessage("❌ Unrecognized QR");
        }
      } catch (e) {
        _showMessage("❌ Invalid QR or error: $e");
      }
    }
  }

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
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
          Center(
            child: CustomPaint(
              painter: ScannerOverlay(),
              child: const SizedBox.expand(),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 40),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Scan your ticket QR code',
                style: TextStyle(color: Colors.white),
              ),
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
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
