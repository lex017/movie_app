import 'package:flutter/material.dart';
import 'package:movie_app/cash/ticket_reward.dart';

class TradeReward extends StatefulWidget {
  final List<Map<String, dynamic>> selectedCandies;
  const TradeReward({super.key, required this.selectedCandies});

  @override
  State<TradeReward> createState() => _TradeRewardState();
}

class _TradeRewardState extends State<TradeReward> {
  @override
  Widget build(BuildContext context) {
    final totalPoints = widget.selectedCandies.fold<int>(
      0,
      (sum, item) => sum + (item['points'] as int),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Trade Reward')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'You selected ${widget.selectedCandies.length} item(s)',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: widget.selectedCandies.length,
                itemBuilder: (context, index) {
                  final candy = widget.selectedCandies[index];
                  return ListTile(
                    leading: Image.asset(candy['image'], width: 40),
                    title: Text(candy['name']),
                    trailing: Text('${candy['points']} pts'),
                  );
                },
              ),
            ),
            const Divider(),
            Text(
              'Total: $totalPoints pts',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                final totalPoints = widget.selectedCandies.fold<int>(
                  0,
                  (sum, item) => sum + (item['points'] as int),
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TicketReward(
                      selectedCandies: widget.selectedCandies,
                      totalPoints: totalPoints,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.redeem),
              label: const Text('Confirm Trade'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
