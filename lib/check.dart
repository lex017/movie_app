import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Check extends StatefulWidget {
  final String ticketId;
  const Check({super.key, required this.ticketId});

  @override
  State<Check> createState() => _CheckState();
}

class _CheckState extends State<Check> {
  Map<String, dynamic>? ticketData;
  bool isLoading = true;
  bool isVerifying = false;

  @override
  void initState() {
    super.initState();
    _fetchTicket();
  }

  Future<void> _fetchTicket() async {
    setState(() {
      isLoading = true;
      ticketData = null;
    });

    try {
      final res = await http.get(
        Uri.parse('http://192.168.0.198:8000/ticket/${widget.ticketId}'),
      );

      if (res.statusCode == 200) {
        setState(() {
          ticketData = json.decode(res.body);
        });
      } else {
        _showSnackBar('❌ Ticket not found');
      }
    } catch (e) {
      _showSnackBar('❌ Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _verifyCheckIn() async {
    setState(() => isVerifying = true);

    try {
      final res = await http.put(
        Uri.parse('http://192.168.0.198:8000/ticket/${widget.ticketId}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': 'check-in'}),
      );

      if (res.statusCode == 200) {
        _showSnackBar('✅ Ticket checked-in successfully');
        await _fetchTicket(); // Refresh ticket data
      } else {
        final error = jsonDecode(res.body);
        _showSnackBar('❌ Failed: ${error['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      _showSnackBar('❌ Error: $e');
    } finally {
      setState(() => isVerifying = false);
    }
  }

  void _showSnackBar(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎫 Verify Ticket'),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ticketData == null
                ? const Center(child: Text('No ticket data found.'))
                : SingleChildScrollView(
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                "🎬 ${ticketData!['mv_name'] ?? 'Movie'}",
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Divider(),
                            _buildRow('🎟 Ticket ID:', ticketData!['ticket_id'].toString()),
                            _buildRow('🗓 Showtime:',
                                '${ticketData!['show_date']} at ${ticketData!['selectedTime']}'),
                            _buildRow('👤 Name:', ticketData!['name']),
                            _buildRow('💺 Seat:', ticketData!['seat_num']),
                            _buildRow('💰 Price:', '${ticketData!['price']} Kip'),
                            _buildRow('📍 Theater:', ticketData!['theaters'].toString()),
                            _buildRow(
                              '✅ Status:',
                              ticketData!['status'],
                              bold: true,
                              color: ticketData!['status'] == 'check-in'
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                            const SizedBox(height: 24),
                            Center(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.check),
                                label: const Text("Mark as Check-in"),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(50),
                                  backgroundColor: Colors.redAccent,
                                ),
                                onPressed: ticketData!['status'] == 'paid' && !isVerifying
                                    ? _verifyCheckIn
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildRow(String label, String? value,
      {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(
            flex: 3,
            child: Text(
              value ?? 'N/A',
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: color ?? Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
