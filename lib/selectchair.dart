import 'package:flutter/material.dart';
// Import your next page or QR page here:
import 'package:movie_app/cash/qr.dart';

class MovieSeatSelectionApp extends StatefulWidget {
  const MovieSeatSelectionApp({Key? key}) : super(key: key);

  @override
  State<MovieSeatSelectionApp> createState() => _MovieSeatSelectionAppState();
}

class _MovieSeatSelectionAppState extends State<MovieSeatSelectionApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Seat Selection',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
      home: const ChairSelection(selectedTime: ''),
    );
  }
}

class ChairSelection extends StatefulWidget {
  final String selectedTime;
  const ChairSelection({Key? key, required this.selectedTime}) : super(key: key);

  @override
  State<ChairSelection> createState() => _ChairSelectionState();
}

class _ChairSelectionState extends State<ChairSelection> {
  // Example data for chairs (1 = available, 0 = reserved)
  final List<List<int>> _seats = List.generate(10, (index) => List.generate(10, (index) => 1)); // 10x10 grid

  // Track selected seats
  final Set<Seat> _selectedSeats = {};

  // You can customize these to match your design or dynamic values:
  final int _seatPrice = 50000;
  final String _showTime = "20:50";

  @override
  Widget build(BuildContext context) {
    // Calculate the total cost and number of seats
    final seatCount = _selectedSeats.length;
    final totalPrice = seatCount * _seatPrice;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Your Seats"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text(
              "Choose Your Seats",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // Seat Grid
            Expanded(
              child: Card(
                color: const Color(0xFF1F1F1F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 10, // Number of columns
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _seats.length * _seats[0].length,
                    itemBuilder: (context, index) {
                      int row = index ~/ _seats[0].length;
                      int col = index % _seats[0].length;
                      bool isReserved = _seats[row][col] == 0;
                      bool isSelected = _selectedSeats.contains(Seat(row, col));

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (!isReserved) {
                              Seat seat = Seat(row, col);
                              if (_selectedSeats.contains(seat)) {
                                _selectedSeats.remove(seat);
                              } else {
                                _selectedSeats.add(seat);
                              }
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isReserved
                                ? Colors.red.shade400
                                : isSelected
                                    ? Colors.greenAccent.shade400
                                    : Colors.grey.shade700,
                            borderRadius: BorderRadius.circular(8.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                offset: const Offset(2, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Center(
                            child: isReserved
                                ? const Icon(Icons.close, color: Colors.white)
                                : isSelected
                                    ? const Icon(Icons.check, color: Colors.white)
                                    : const SizedBox.shrink(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Info panel: seats, price, time, total
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFF1F1F1F),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Left column: seats, price, time
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Seats: $seatCount",
                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Price: $_seatPrice/kip",
                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Time: $_showTime",
                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                  // Right side: total
                  Text(
                    "Total: $totalPrice/kip",
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Book Now Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const qrpage()),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50), // Full-width button
                backgroundColor: Colors.red, // <-- Add your color here
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Book Now',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// Seat model
class Seat {
  final int row;
  final int col;

  Seat(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Seat &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;
}