import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HistoryPage extends StatefulWidget {
  final String uid;
  const HistoryPage({Key? key, required this.uid}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> historyList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
  try {
    final ticketResponse = await http.get(Uri.parse("http://192.168.126.1:8000/tickets?uid=${widget.uid}"));
    print('Tickets status: ${ticketResponse.statusCode}');
    print('Tickets body: ${ticketResponse.body}');

    final rewardResponse = await http.get(Uri.parse("http://192.168.126.1:8000/reward?uid=${widget.uid}"));
    print('Rewards status: ${rewardResponse.statusCode}');
    print('Rewards body: ${rewardResponse.body}');

    if (ticketResponse.statusCode == 200 && rewardResponse.statusCode == 200) {
      List<dynamic> tickets = jsonDecode(ticketResponse.body);
      List<dynamic> rewards = jsonDecode(rewardResponse.body);

      List<Map<String, dynamic>> combined = [
        ...tickets.map((t) => {...t, 'type': 'ticket'}),
        ...rewards.map((r) => {...r, 'type': 'reward'}),
      ];

      combined.sort((a, b) {
        DateTime dateA = DateTime.tryParse(a['booking_date'] ?? '') ?? DateTime(1970);
        DateTime dateB = DateTime.tryParse(b['booking_date'] ?? '') ?? DateTime(1970);
        return dateB.compareTo(dateA);
      });

      setState(() {
        historyList = combined;
        isLoading = false;
      });
    } else {
      throw Exception("Failed to fetch data");
    }
  } catch (e) {
    print("Error fetching history: $e");
    setState(() {
      isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History'), backgroundColor: Colors.redAccent),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : historyList.isEmpty
              ? const Center(child: Text("No history found"))
              : ListView.builder(
                  itemCount: historyList.length,
                  itemBuilder: (context, index) {
                    final item = historyList[index];
                    final isTicket = item['type'] == 'ticket';

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isTicket ? Colors.redAccent.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                        child: Icon(
                          isTicket ? Icons.movie : Icons.monetization_on,
                          color: isTicket ? Colors.redAccent : Colors.orange,
                        ),
                      ),
                      title: Text(isTicket ? (item['mv_name'] ?? 'Movie Ticket') : (item['re_name'] ?? 'Reward')),
                      subtitle: Text(isTicket
                          ? 'Seat: ${item['seat_num'] ?? '-'} | Theater: ${item['theaters'] ?? '-'}'
                          : 'Points: ${item['r_point'] ?? '-'}'),
                      trailing: Text(
                        isTicket
                            ? '${item['price'] ?? 0} Kip'
                            : '${item['r_point'] ?? 0} pts',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
    );
  }
}
