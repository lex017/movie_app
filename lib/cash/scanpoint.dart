import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;

class RedeemPointsPage extends StatefulWidget {
  
  const RedeemPointsPage({super.key, required String userId});

  @override
  State<RedeemPointsPage> createState() => _RedeemPointsPageState();
}

class _RedeemPointsPageState extends State<RedeemPointsPage> {
  final MobileScannerController _controller = MobileScannerController();

  bool isScanned = false;
  bool isLoading = false;

  // User data from QR + API
  String? userId;
  int? currentPoints;
  int? pointsToDeduct;

  void handleBarcode(BarcodeCapture capture) async {
    if (isScanned || capture.barcodes.isEmpty) return;

    setState(() {
      isScanned = true;
      isLoading = true;
      userId = null;
      currentPoints = null;
      pointsToDeduct = null;
    });

    _controller.stop();

    try {
      final qrData = capture.barcodes.first.rawValue ?? '';
      final data = json.decode(qrData);

      final String scannedUserId = data['u_id'];
      final int pointsNeeded = data['points'];

      // Fetch user info from API
      final res = await http.get(
        Uri.parse('http://192.168.0.195:8000/user/$scannedUserId'),
      );

      if (res.statusCode == 200) {
        final user = json.decode(res.body);
        final int userPoints = user['col_points'] ?? 0;

        setState(() {
          userId = scannedUserId;
          currentPoints = userPoints;
          pointsToDeduct = pointsNeeded;
          isLoading = false;
        });
      } else {
        _showMessage('❌ User not found');
        _resetScan();
      }
    } catch (e) {
      _showMessage('❌ Invalid QR or error: $e');
      _resetScan();
    }
  }

  Future<void> deductPoints() async {
    if (userId == null || pointsToDeduct == null || currentPoints == null) return;

    if (currentPoints! < pointsToDeduct!) {
      _showMessage('❌ Not enough points (current: $currentPoints)');
      return;
    }

    setState(() => isLoading = true);

    try {
      final int newPoints = currentPoints! - pointsToDeduct!;

      final updateRes = await http.put(
        Uri.parse('http://192.168.0.195:8000/user/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'col_points': newPoints}),
      );

      if (updateRes.statusCode == 200) {
        _showMessage('✅ Points deducted successfully! Current points: $newPoints');
        setState(() {
          currentPoints = newPoints;
          pointsToDeduct = 0;
        });
      } else {
        _showMessage('❌ Failed to deduct points');
      }
    } catch (e) {
      _showMessage('❌ Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _resetScan() {
    setState(() {
      isScanned = false;
      isLoading = false;
      userId = null;
      currentPoints = null;
      pointsToDeduct = null;
    });
    _controller.start();
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 3)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildUserInfo() {
    if (userId == null) return const SizedBox();

    return Card(
      margin: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('User ID: $userId', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Current Points: $currentPoints', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Points to Deduct: $pointsToDeduct', style: const TextStyle(fontSize: 18, color: Colors.red)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: isLoading ? null : deductPoints,
              icon: const Icon(Icons.remove_circle_outline),
              label: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Deduct Points'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : _resetScan,
              child: const Text('Scan Again'),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan and Redeem Points'),
        backgroundColor: Colors.green,
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
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: MobileScanner(
              controller: _controller,
              onDetect: handleBarcode,
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(child: _buildUserInfo()),
          ),
        ],
      ),
    );
  }
}
