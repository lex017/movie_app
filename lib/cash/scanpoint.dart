import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RedeemPointsPage extends StatefulWidget {
  final String userId;
  final String rewardId;

  const RedeemPointsPage({
    super.key,
    required this.userId,
    required this.rewardId,
  });

  @override
  State<RedeemPointsPage> createState() => _RedeemPointsPageState();
}

class _RedeemPointsPageState extends State<RedeemPointsPage> {
  bool isLoading = false;
  int? currentPoints;
  int? pointsToDeduct;

  @override
  void initState() {
    super.initState();
    _fetchUserPoints();
    _fetchRewardPoints();
  }

  Future<void> _fetchUserPoints() async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(
        Uri.parse('http://192.168.0.198:8000/user/${widget.userId}'),
      );
      if (res.statusCode == 200) {
        final user = json.decode(res.body);
        setState(() {
          currentPoints = user['col_points'] ?? 0;
        });
      } else {
        _showMessage('❌ User not found');
      }
    } catch (e) {
      _showMessage('❌ Error fetching user points: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchRewardPoints() async {
    // TODO: Replace with real API call to get points needed for reward
    // Example mock: set fixed 50 points to deduct
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      pointsToDeduct = 50; 
    });
  }

  Future<void> _redeemPoints() async {
    if (currentPoints == null || pointsToDeduct == null) return;

    if (currentPoints! < pointsToDeduct!) {
      _showMessage('❌ Not enough points (current: $currentPoints)');
      return;
    }

    setState(() => isLoading = true);

    final newPoints = currentPoints! - pointsToDeduct!;

    try {
      final res = await http.put(
        Uri.parse('http://192.168.0.198:8000/user/${widget.userId}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'col_points': newPoints}),
      );

      if (res.statusCode == 200) {
        setState(() {
          currentPoints = newPoints;
          pointsToDeduct = 0;
        });
        _showMessage('✅ Points deducted successfully! New points: $newPoints');
      } else {
        _showMessage('❌ Failed to deduct points');
      }
    } catch (e) {
      _showMessage('❌ Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Redeem Points'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Card(
                margin: const EdgeInsets.all(20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('User ID: ${widget.userId}', style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 8),
                      Text('Current Points: $currentPoints', style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 8),
                      Text('Points to Redeem: $pointsToDeduct', style: const TextStyle(fontSize: 18, color: Colors.red)),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: isLoading ? null : _redeemPoints,
                        icon: const Icon(Icons.redeem),
                        label: const Text('Redeem Points'),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
