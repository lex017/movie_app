import 'package:flutter/material.dart';
import 'package:movie_app/trade_reward.dart';

class Reward extends StatefulWidget {
  const Reward({super.key});

  @override
  State<Reward> createState() => _RewardState();
}

class _RewardState extends State<Reward> {
  final List<int> selectedCandyIndexes = [];

  final List<Map<String, dynamic>> candies = [
    {
      'name': 'ເລຍ',
      'points': 15,
      'image': 'assets/lay1.jpeg',
    },
    {
      'name': 'Lay chili lemon',
      'points': 15,
      'image': 'assets/lay2.jpeg',
    },
    {
      'name': 'Pepsi',
      'points': 15,
      'image': 'assets/pep1.jpeg',
    },
    {
      'name': 'small popkorn',
      'points': 20,
      'image': 'assets/popkorn.jpeg',
    },
    {
      'name': 'Big popkorn',
      'points': 25,
      'image': 'assets/bigpop.jpeg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reward Candy'),
        actions: [
          const Center(
            child: Text('100', style: TextStyle(fontSize: 20)),
          ),
          IconButton(
            icon: const CircleAvatar(
              backgroundImage: AssetImage('assets/dollar.png'),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                itemCount: candies.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 3 / 4,
                ),
                itemBuilder: (context, index) {
                  final candy = candies[index];
                  final isSelected = selectedCandyIndexes.contains(index);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedCandyIndexes.remove(index);
                        } else {
                          selectedCandyIndexes.add(index);
                        }
                      });
                    },
                    child: Card(
                      elevation: isSelected ? 8 : 2,
                      color: isSelected ? Colors.amber[100] : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color:
                              isSelected ? Colors.orange : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            candy['image'],
                            height: 80,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            candy['name'],
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${candy['points']} pts',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 10),
                          if (isSelected)
                            const Icon(Icons.check_circle, color: Colors.green),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (selectedCandyIndexes.isNotEmpty)
  Padding(
    padding: const EdgeInsets.all(16.0),
    child: SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.payment),
        label: const Text("Next to Pay"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
        ),
        onPressed: () {
          final selectedCandies = selectedCandyIndexes
              .map((index) => candies[index])
              .toList();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TradeReward(selectedCandies: selectedCandies),
            ),
          );
        },
      ),
    ),
  )
        ]
      ),
    );
  }
}
