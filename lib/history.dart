import 'package:flutter/material.dart';
import 'package:movie_app/drawer.dart';
import 'package:movie_app/history.dart';
import 'package:movie_app/ticketdetail.dart';


class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  final List<Map<String, dynamic>> historyList = [
    {
      'movie': {
        'title': 'Avengers: Endgame',
        'showDate': '2025-03-14',
        'theater': 'Deanger',
        'seat': 'A10',
      },
      'payment': {
        'amount': 50000,
        'status': 'Paid',
      },
      'ticketDocId': '1',
    },
    {
      'movie': {
        'title': 'Spider-Man: No Way Home',
        'showDate': '2025-03-12',
        'theater': 'Deanger',
        'seat': 'B5',
      },
      'payment': {
        'amount': 20000,
        'status': 'Paid',
      },
      'ticketDocId': '2',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("History"),
        
      ),
      body: historyList.isEmpty
          ? const Center(child: Text("No movie history found."))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: historyList.length,
              itemBuilder: (context, index) {
                var movieData = historyList[index]['movie'];
                var paymentData = historyList[index]['payment'];
                var ticketDocId = historyList[index]['ticketDocId']; 

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailTicket(
                          movieData: movieData,
                          paymentData: paymentData,
                          
                        ),
                      ),
                    );
                  },
                  child: TicketWidget(
                    title: movieData['title'],
                    subtitle: 'Theater: ${movieData['theater']}',
                    date: movieData['showDate'],
                    seat: movieData['seat'],
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
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: const BorderRadius.only(
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
