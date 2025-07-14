import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';

class TicketReward extends StatelessWidget {
  final List<Map<String, dynamic>> selectedCandies;
  final int totalPoints;
  final String uid;

  const TicketReward({
    super.key,
    required this.selectedCandies,
    required this.totalPoints, required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    // Encode ticket data to JSON string for QR
    final ticketData = jsonEncode({
      'u_id':uid,
      'candies': selectedCandies.map((e) => e['name']).toList(),
      'r_point': totalPoints,
      'timestamp': DateTime.now().toIso8601String(),
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reward Ticket'),
        backgroundColor: Colors.red,
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          children: [
            Text(
              'Your Reward QR Ticket',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.red.shade700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 30),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 12,
              shadowColor: Colors.deepPurpleAccent.withOpacity(0.4),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    QrImageView(
                      data: ticketData,
                      version: QrVersions.auto,
                      size: 260,
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Items:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      selectedCandies.map((e) => e['name']).join(', '),
                      style: const TextStyle(fontSize: 16, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Divider(
                      thickness: 1.5,
                      color: Colors.red.shade100,
                      indent: 40,
                      endIndent: 40,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Total Points:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$totalPoints pts',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.red.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                label: const Text(
                  "Back",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 6,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
