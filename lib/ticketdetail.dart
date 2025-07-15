import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movie_app/homepage.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';

class DetailTicket extends StatelessWidget {
  final Map<String, dynamic> ticketData;
  final Map<String, dynamic> movieData;
  final Map<String, dynamic> paymentData;
  final String image;
  final String uid;

  const DetailTicket({
    Key? key,
    required this.ticketData,
    required this.movieData,
    required this.paymentData,
    required this.image,
    required this.uid,
  }) : super(key: key);

  String _formatDate(String dateStr) {
    try {
      DateTime dateTime = DateTime.parse(dateStr).toLocal();
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } catch (e) {
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String imageUrl = ticketData['posterURL'] ?? '';

    // ✅ สร้างข้อมูลที่จะแปลงเป็น QR
    final qrData = jsonEncode({
      'ticketId': ticketData['ticket_id'],
      'uid': uid,
      'status': ticketData['status'],
    });

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("Movie Ticket Details"),
        backgroundColor: Colors.redAccent,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey[100]!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 🎬 Poster
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: SizedBox(
                    height: 200,
                    child: imageUrl.isNotEmpty
                        ? Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity)
                        : Image.network(
                            'https://images.ctfassets.net/3sjsytt3tkv5/48dw0Wqg1t7RMqLrtodjqL/d72b35dae2516fa64803f4de2ab8e30f/Avengers-_Endgame_-_Header_Image.jpeg',
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                  ),
                ),

                // 🎫 Details
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        ticketData['mv_name'] ?? 'Unknown Movie',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),

                      // ✅ QR Code with full JSON data
                      QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 160,
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(height: 6),
                     

                      const SizedBox(height: 12),
                      Text(
                        'Show Date: ${_formatDate(ticketData['show_date'] ?? '')}',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),

                      // Info Rows
                      _buildInfoRow('Theater', ticketData['theaters'].toString(), 'Seat', ticketData['seat_num']),
                      const SizedBox(height: 16),
                      _buildInfoRow('Name', ticketData['name'], 'Time', ticketData['selectedTime']),
                      const SizedBox(height: 16),
                      _buildInfoRow('Price', '${ticketData['price']} Kip', 'Status', ticketData['status']),
                      const SizedBox(height: 24),

                      // 🔙 Back Button
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => Homepage(uid: uid)),
                              (Route<dynamic> route) => false,
                            );
                          },
                          child: const Text(
                            'Back',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label1, String? value1, String label2, String? value2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildInfoColumn(label1, value1),
        _buildInfoColumn(label2, value2),
      ],
    );
  }

  Widget _buildInfoColumn(String label, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value ?? 'N/A',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}
