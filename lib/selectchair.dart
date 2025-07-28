import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:movie_app/cash/qr.dart';

class ChairSelection extends StatefulWidget {
  final String selectedTime;
  final String title;
  final int price;
  final int theaters;
  final String date;
  final List<List<int>> seats;
  final String uid;
  final int showtimeId;
  final String image;

  const ChairSelection({
    Key? key,
    required this.selectedTime,
    required this.price,
    required this.theaters,
    required this.seats,
    required this.title,
    required this.date,
    required this.uid,
    required this.showtimeId,
    required this.image,
  }) : super(key: key);

  @override
  State<ChairSelection> createState() => _ChairSelectionState();
}

class _ChairSelectionState extends State<ChairSelection> {
  late List<List<int>> _seats;
  final Set<Seat> _selectedSeats = {};

  @override
  void initState() {
    super.initState();
    _seats = List.generate(
      widget.seats.length,
      (i) => List<int>.from(widget.seats[i]),
    );

    // ดึงข้อมูลหลัง build เสร็จ เพื่อให้ setState() ทำงานได้
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchBookedSeatsFromApi();
    });
  }

  Future<void> fetchBookedSeatsFromApi() async {
    try {
      final url = Uri.parse(
          'http://192.168.0.196:8000/api/booked-seats/${widget.showtimeId}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> bookedSeats = data['bookedSeats'];

        for (var seatLabel in bookedSeats) {
          int row = seatLabel.codeUnitAt(0) - 65;
          int col = int.parse(seatLabel.substring(1)) - 1;

          if (row >= 0 &&
              row < _seats.length &&
              col >= 0 &&
              col < _seats[row].length) {
            _seats[row][col] = 0; // 0 = reserved
            print("Seat $seatLabel marked reserved at [$row][$col]");
          }
        }

        setState(() {});
      } else {
        print('Error fetching seats: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception fetching seats: $e');
    }
  }

  String getSeatLabel(int row, int col) {
    return '${String.fromCharCode(65 + row)}${col + 1}';
  }

  @override
  Widget build(BuildContext context) {
    final int seatPrice = widget.price;
    final int seatCount = _selectedSeats.length;
    final int totalPrice = seatCount * seatPrice;
    final int columns = _seats.isNotEmpty ? _seats[0].length : 1;

    return Scaffold(
      appBar: AppBar(title: const Text("Select Your Seats")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Theaters: ${widget.theaters}'),
            const SizedBox(height: 10),
            Container(
              width: double.infinity, 
              padding: EdgeInsets.symmetric(vertical: 12), 
              decoration: BoxDecoration(
                color: Colors.redAccent, 
              ),
              child: Text(
                "Screen",
                textAlign: TextAlign.center, 
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Card(
                color: const Color(0xFF1F1F1F),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 10,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _seats.length * columns,
                    itemBuilder: (context, index) {
                      int row = index ~/ columns;
                      int col = index % columns;

                      bool isReserved = _seats[row][col] == 0;
                      Seat seat = Seat(row, col);
                      bool isSelected = _selectedSeats.contains(seat);

                      return GestureDetector(
                        onTap: () {
                          if (isReserved) return;
                          setState(() {
                            isSelected
                                ? _selectedSeats.remove(seat)
                                : _selectedSeats.add(seat);
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isReserved
                                ? Colors.red
                                : isSelected
                                    ? Colors.green
                                    : Colors.grey.shade700,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              getSeatLabel(row, col),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1F1F1F),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Seats: $seatCount",
                            style: const TextStyle(color: Colors.white)),
                        Text("Price/seat: $seatPrice",
                            style: const TextStyle(color: Colors.white)),
                        Text("Time: ${widget.selectedTime}",
                            style: const TextStyle(color: Colors.white)),
                      ]),
                  Text("Total: $totalPrice kip",
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: seatCount == 0
                  ? null
                  : () {
                      List<String> selectedLabels = _selectedSeats
                          .map((seat) => getSeatLabel(seat.row, seat.col))
                          .toList();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => qrpage(
                            selectedTime: widget.selectedTime,
                            price: totalPrice,
                            theaters: widget.theaters,
                            selectedSeats: selectedLabels,
                            title: widget.title,
                            date: widget.date,
                            uid: widget.uid,
                            showtimeId: widget.showtimeId,
                            image: widget.image,
                          ),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.red,
              ),
              child: const Text('Book Now',
                  style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class Seat {
  final int row;
  final int col;

  Seat(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      other is Seat && row == other.row && col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;
}
