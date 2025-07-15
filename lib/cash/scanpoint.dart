import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';

class RedeemPointsPage extends StatefulWidget {
  final String userId;
  final List<Map<String, dynamic>> selectedCandies;
  final int totalPoints;

  const RedeemPointsPage({
    super.key,
    required this.userId,
    required this.selectedCandies,
    required this.totalPoints,
  });

  @override
  State<RedeemPointsPage> createState() => _RedeemPointsPageState();
}

class _RedeemPointsPageState extends State<RedeemPointsPage> {
  bool isLoading = true;
  int? userPoints;
  bool redeemed = false;

  @override
  void initState() {
    super.initState();
    _fetchUserPoints();
  }

  Future<void> _fetchUserPoints() async {
    try {
      final res = await http.get(
        Uri.parse('http://192.168.0.198:8000/user/${widget.userId}'),
      );
      if (res.statusCode == 200) {
        final user = json.decode(res.body);
        setState(() {
          userPoints = user['point'] ?? 0;
        });
      } else {
        _showMessage('Failed to fetch points');
      }
    } catch (e) {
      _showMessage('Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _redeemPoints() async {
    if (userPoints == null || userPoints! < widget.totalPoints) {
      _showMessage('Not enough points');
      return;
    }

    setState(() => isLoading = true);
    final newPoints = userPoints! - widget.totalPoints;

    try {
      final res = await http.put(
        Uri.parse('http://192.168.0.198:8000/user/${widget.userId}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'point': newPoints}),
      );
      if (res.statusCode == 200) {
        setState(() {
          redeemed = true;
          userPoints = newPoints;
        });
        _showMessage('Points redeemed!');
      } else {
        _showMessage('Redeem failed');
      }
    } catch (e) {
      _showMessage('Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ticketData = jsonEncode({
      'u_id': widget.userId,
      'candies': widget.selectedCandies.map((e) => e['name']).toList(),
      'point': widget.totalPoints,
      'timestamp': DateTime.now().toIso8601String(),
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Redeem Rewards'),
        backgroundColor: Colors.redAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : redeemed
              ? _buildQrView(ticketData)
              : _buildRedeemView(),
    );
  }

  Widget _buildRedeemView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _infoCard(
            icon: Icons.account_circle,
            label: 'Current Points',
            value: '${userPoints ?? '-'}',
          ),
          const SizedBox(height: 16),
          _infoCard(
            icon: Icons.redeem,
            label: 'Points Required',
            value: '${widget.totalPoints}',
            valueColor: Colors.redAccent,
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _redeemPoints,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 6,
              ),
              child: Text(
                'Redeem & Generate QR',
                style: TextStyle(fontSize: 18, letterSpacing: 1.1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, size: 36, color: Colors.redAccent),
        title: Text(label, style: const TextStyle(fontSize: 16)),
        trailing: Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildQrView(String data) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            '🎉 Your Reward QR',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent.shade700,
            ),
          ),
          const SizedBox(height: 24),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: QrImageView(
                data: data,
                version: QrVersions.auto,
                size: 260,
                backgroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Items: ${widget.selectedCandies.map((e) => e['name']).join(', ')}',
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Points Used: ${widget.totalPoints}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent.shade700,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back', style: TextStyle(fontSize: 18)),
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
