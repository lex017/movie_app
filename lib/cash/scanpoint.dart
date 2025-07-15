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
    setState(() => isLoading = true);
    try {
      // ตัวอย่าง: เรียก API เพื่อดึงคะแนนที่ต้องใช้สำหรับ reward นี้
      final res = await http.get(
        Uri.parse('http://192.168.0.198:8000/reward/${widget.rewardId}'),
      );
      if (res.statusCode == 200) {
        final reward = json.decode(res.body);
        setState(() {
          pointsToDeduct = reward['required_points'] ?? 0;
        });
      } else {
        // กรณี API ไม่ตอบกลับ ให้ตั้งค่า default (หรือแจ้ง error)
        setState(() {
          pointsToDeduct = 5;
        });
      }
    } catch (e) {
      setState(() {
        pointsToDeduct = 5;
      });
      _showMessage('❌ Error fetching reward points: $e');
    } finally {
      setState(() => isLoading = false);
    }
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
        child: (isLoading && (currentPoints == null || pointsToDeduct == null))
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
                      Text('Current Points: ${currentPoints ?? "-"}', style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 8),
                      Text('Points to Redeem: ${pointsToDeduct ?? "-"}', style: const TextStyle(fontSize: 18, color: Colors.red)),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: (isLoading || currentPoints == null || pointsToDeduct == null || currentPoints! < pointsToDeduct!)
                            ? null
                            : _redeemPoints,
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
