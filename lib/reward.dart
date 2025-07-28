import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:movie_app/trade_reward.dart';

class Reward extends StatefulWidget {
  final String uid;
  const Reward({super.key, required this.uid});

  @override
  State<Reward> createState() => _RewardState();
}

class _RewardState extends State<Reward> {
  final List<int> selectedCandyIndexes = [];
  List<Map<String, dynamic>> candies = [];
  int userPoints = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRewards();
    fetchPoints(widget.uid);
  }

  Future<void> fetchRewards() async {
    try {
      final res = await http.get(Uri.parse('http://192.168.0.196:8000/reward'));
      if (res.statusCode == 200) {
        final List<dynamic> data = json.decode(res.body);
        setState(() {
          candies = data.map((r) => {
            'name': r['re_name'],
            'points': r['r_point'],
            'image': r['image_reward'],
          }).toList();
        });
      } else {
        throw Exception('Failed to load rewards');
      }
    } catch (e) {
      print("Reward error: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

Future<void> fetchPoints(String uId) async {
  try {
    final res = await http.get(Uri.parse('http://192.168.0.196:8000/user/$uId'));
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      setState(() {
        userPoints = data['point'] ?? 0;
      });
    } else {
      throw Exception('Failed to load user');
    }
  } catch (e) {
    print("User point fetch error: $e");
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reward Candy'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                '$userPoints pts',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          IconButton(
            icon: const CircleAvatar(
              backgroundImage: AssetImage('assets/dollar.png'),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
                                color: isSelected
                                    ? Colors.orange
                                    : Colors.grey.shade300,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network(
                                  candy['image'],
                                  height: 80,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.image, size: 80),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  candy['name'],
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${candy['points']} pts',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 10),
                                if (isSelected)
                                  const Icon(Icons.check_circle,
                                      color: Colors.green),
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
                        icon: Icon(Icons.payment,color: Colors.white),
                        label:  Text("Next to Pay",style: TextStyle(color: Colors.white),),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () {
                          final selectedCandies = selectedCandyIndexes
                              .map((index) => candies[index])
                              .toList();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TradeReward(
                                selectedCandies: selectedCandies, uid: widget.uid,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
