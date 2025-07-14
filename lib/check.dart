import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Check extends StatefulWidget {
  const Check({super.key});

  @override
  State<Check> createState() => _CheckState();
}

class _CheckState extends State<Check> {
  final TextEditingController _ticketIdController = TextEditingController();
  Map<String, dynamic>? ticketData;
  bool isLoading = false;
  bool isVerifying = false;

  Future<void> _fetchTicket() async {
    final ticketId = _ticketIdController.text.trim();

    if (ticketId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❗ Please enter ticket ID')),
      );
      return;
    }

    setState(() {
      isLoading = true;
      ticketData = null;
    });

    try {
      final res = await http.get(
        Uri.parse('http://192.168.0.195:8000/ticket/$ticketId'),
      );

      if (res.statusCode == 200) {
        setState(() {
          ticketData = json.decode(res.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Ticket not found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _verifyCheckIn() async {
    final ticketId = _ticketIdController.text.trim();

    setState(() => isVerifying = true);

    try {
      final res = await http.put(
        Uri.parse('http://192.168.0.195:8000/ticket/$ticketId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': 'check-in'}),
      );

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Ticket status updated to check-in')),
        );
        _fetchTicket(); // Refresh ticket data
      } else {
        final error = jsonDecode(res.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Failed: ${error['error'] ?? 'Unknown error'}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    } finally {
      setState(() => isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Ticket')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _ticketIdController,
              decoration: InputDecoration(
                labelText: 'Enter Ticket ID',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _fetchTicket,
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const CircularProgressIndicator()
            else if (ticketData != null) ...[
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text("🎬 ${ticketData!['mv_name']}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text("Showtime: ${ticketData!['show_date']} at ${ticketData!['selectedTime']}"),
                      Text("Name: ${ticketData!['name']}"),
                      Text("Price: ${ticketData!['price']}"),
                      Text("Status: ${ticketData!['status']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle),
                        label: const Text("Mark as Check-in"),
                        onPressed: ticketData!['status'] == 'paid' && !isVerifying ? _verifyCheckIn : null,
                      ),
                    ],
                  ),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
