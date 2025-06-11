import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TicketPage extends StatelessWidget {
  final String movieTitle;
  final String theater;
  final String date;
  final String time;
  final String seat;
  final String ticketId;

  const TicketPage({
    Key? key,
    required this.movieTitle,
    required this.theater,
    required this.date,
    required this.time,
    required this.seat,
    required this.ticketId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a dark background to emphasize the ticket design.
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text("Your Movie Ticket"),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Center(
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Colors.deepPurple, Colors.deepPurpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Movie Title & Theater
              Text(
                movieTitle,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                theater,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Movie Details: Date, Time, Seat
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDetailColumn("Date", date),
                  _buildDetailColumn("Time", time),
                  _buildDetailColumn("Seat", seat),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white54),
              const SizedBox(height: 16),
              // QR Code Section
              QrImageView(
                data: ticketId,
                version: QrVersions.auto,
                size: 150,
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 16),
              Text(
                "Ticket ID: $ticketId",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to build a detail column for Date, Time, Seat.
  Widget _buildDetailColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.white70),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ],
    );
  }
}
