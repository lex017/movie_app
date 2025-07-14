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
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchHistory();
    print('🔍 uid = ${widget.uid}');
  }

  Future<void> fetchHistory() async {
    try {
      final ticketResponse = await http.get(
        Uri.parse("http://192.168.0.198:8000/tickets?u_id=${widget.uid}"),
      );
      final rewardResponse = await http.get(
        Uri.parse("http://192.168.0.198:8000/reward?u_id=${widget.uid}"),
      );

      if (ticketResponse.statusCode == 200 && rewardResponse.statusCode == 200) {
        List<dynamic> tickets = jsonDecode(ticketResponse.body);
        List<dynamic> rewards = jsonDecode(rewardResponse.body);

        // Combine and mark type for UI
        List<Map<String, dynamic>> combined = [
          ...tickets.map((t) => {...t, 'type': 'ticket'}),
          ...rewards.map((r) => {...r, 'type': 'reward'}),
        ];

        // Sort by date descending (newest first)
        combined.sort((a, b) {
          DateTime dateA = DateTime.tryParse(
                a['booking_date'] ?? a['redeem_date'] ?? '',
              ) ??
              DateTime(1970);
          DateTime dateB = DateTime.tryParse(
                b['booking_date'] ?? b['redeem_date'] ?? '',
              ) ??
              DateTime(1970);
          return dateB.compareTo(dateA);
        });

        setState(() {
          historyList = combined;
          isLoading = false;
          errorMessage = null;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to fetch data. Server responded with status codes: ${ticketResponse.statusCode}, ${rewardResponse.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      print("❌ Error fetching history: $e");
      setState(() {
        errorMessage = 'Error fetching history: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: Colors.redAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.red)))
              : historyList.isEmpty
                  ? const Center(child: Text("No history found"))
                  : ListView.builder(
                      itemCount: historyList.length,
                      itemBuilder: (context, index) {
                        final item = historyList[index];
                        final isTicket = item['type'] == 'ticket';

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isTicket
                                ? Colors.redAccent.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            child: Icon(
                              isTicket ? Icons.movie : Icons.monetization_on,
                              color: isTicket ? Colors.redAccent : Colors.orange,
                            ),
                          ),
                          title: Text(isTicket
                              ? (item['mv_name'] ?? 'Movie Ticket')
                              : (item['re_name'] ?? 'Reward')),
                          subtitle: Text(isTicket
                              ? 'Seat: ${item['seat_num'] ?? '-'} | Theater: ${item['theaters'] ?? '-'}\nDate: ${item['booking_date'] ?? '-'}'
                              : 'Points: ${item['r_point'] ?? '-'}\nDate: ${item['redeem_date'] ?? '-'}'),
                          trailing: Text(
                            isTicket
                                ? '${item['price'] ?? 0} ₭'
                                : '${item['r_point'] ?? 0} pts',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
    );
  }
}
