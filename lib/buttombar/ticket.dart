import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:movie_app/drawer.dart';
import 'package:movie_app/history.dart';
import 'package:movie_app/ticketdetail.dart';

class Ticket extends StatefulWidget {
  final String uid;
  const Ticket({super.key, required this.uid});

  @override
  State<Ticket> createState() => _TicketState();
}

class _TicketState extends State<Ticket> {
  List<Map<String, dynamic>> historyList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTickets();
  }

 Future<void> fetchTickets() async {
  try {
    final response = await http.get(Uri.parse('http://192.168.0.196:8000/tickets'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      print('Current UID: ${widget.uid}');
      print('All tickets: $data');

      final filteredData = data.where((ticket) {
        print('Checking ticket UID: ${ticket['u_id']}');
        return ticket['u_id'].toString() == widget.uid.toString();
      }).toList();

      print('Filtered tickets: $filteredData');

      setState(() {
        historyList = filteredData.cast<Map<String, dynamic>>();
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load tickets');
    }
  } catch (e) {
    setState(() => isLoading = false);
    print('Error fetching tickets: $e');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Movie Ticket"),
        actions: [
          IconButton(
            icon: const CircleAvatar(
              backgroundImage: AssetImage('assets/history.png'),
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => HistoryPage(uid: widget.uid,)));
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : historyList.isEmpty
              ? const Center(child: Text("No movie history found."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: historyList.length,
                  itemBuilder: (context, index) {
                    final ticket = historyList[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailTicket(
                              ticketData: ticket,
                              movieData: {},
                              paymentData: {},
                              image: ticket['posterURL'] ?? '', uid: widget.uid,
                            ),
                          ),
                        );
                      },
                      child: TicketWidget(
                        title: ticket['mv_name'] ?? 'N/A',
                        subtitle: 'Theater: ${ticket['theaters'] ?? 'N/A'}',
                        date: (ticket['show_date'] ?? '').toString().split('T')[0],
                        seat: ticket['seat_num'] ?? 'N/A',
                      ),
                    );
                  },
                ),
    );
  }
}

class TicketWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String date;
  final String seat;

  const TicketWidget({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.seat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(Icons.movie, color: Colors.white),
              ],
            ),
          ),
          CustomPaint(
            size: const Size(double.infinity, 20),
            painter: DashedLinePainter(),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Show Date'),
                        Text(
                          date,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Seat'),
                        Text(
                          seat,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashWidth = 5.0;
    const dashSpace = 3.0;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
