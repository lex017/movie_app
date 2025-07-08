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
                    leading: Image.network(
                      candy['image'],
                      width: 40,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image),
                    ),
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
              icon: Icon(Icons.redeem,color: Colors.white,),
              label: Text('Confirm Trade',style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
