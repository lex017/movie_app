import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:movie_app/selectchair.dart';

class MovieDetails extends StatefulWidget {
  final int movieId; // movie_id from DB
  final String title;
  final String description;
  final String imageUrl;
  final int theaters; // theaters_id
  final int price;
  final int seat;
  final String date;
  final String uid;
  final String image;

  const MovieDetails({
    super.key,
    required this.movieId,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.theaters,
    required this.price,
    required this.seat,
    required this.date,
    required this.uid, required this.image,
  });

  @override
  State<MovieDetails> createState() => _MovieDetailsState();
}

class _MovieDetailsState extends State<MovieDetails> {
  bool isFavorite = false;

  // Store full showtime objects: each contains showtime_id, showt_ime, etc.
  List<Map<String, dynamic>> availableShowtimes = [];

  int? selectedShowtimeId;        // selected showtime_id
  String? selectedShowtimeTime;   // selected showtime display time

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchShowtimes();
  }

  Future<void> fetchShowtimes() async {
    final url = Uri.parse('http://192.168.0.195:8000/showtime');
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final allShowtimes = List<Map<String, dynamic>>.from(data);

      final filtered = allShowtimes.where((show) =>
          show['theaters_id'] == widget.theaters).toList();

      setState(() {
        availableShowtimes = filtered;
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load showtimes');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.title.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.white,
              size: 28,
            ),
            onPressed: () {
              setState(() {
                isFavorite = !isFavorite;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.45,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(widget.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),
          DraggableScrollableSheet(
            snap: true,
            initialChildSize: 0.6,
            minChildSize: 0.6,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 50,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          widget.title.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Text(
                          "Now in Theaters",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.redAccent,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        widget.description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Select Showtime",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Theaters ${widget.theaters}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    isLoading
                        ? const CircularProgressIndicator()
                        : Wrap(
                            spacing: 10,
                            children: availableShowtimes.map((showtime) {
                              final showtimeId = showtime['showtime_id'];
                              final showtimeStr = showtime['showt_ime'].toString().substring(0, 5);
                              final isSelected = selectedShowtimeId == showtimeId;

                              return ChoiceChip(
                                label: Text(showtimeStr),
                                selected: isSelected,
                                onSelected: (_) {
                                  setState(() {
                                    selectedShowtimeId = showtimeId;
                                    selectedShowtimeTime = showtimeStr;
                                  });
                                },
                                selectedColor: Colors.redAccent,
                                backgroundColor: Colors.grey[200],
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            }).toList(),
                          ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: selectedShowtimeId == null
                            ? null
                            : () {
                                int seatCount = widget.seat;
                                int columns = 5;
                                int rows = (seatCount / columns).ceil();

                                List<List<int>> seatLayout = List.generate(rows, (r) {
                                  return List.generate(columns, (c) {
                                    int seatNumber = r * columns + c;
                                    if (seatNumber >= seatCount) return 0;
                                    return 1;
                                  });
                                });

                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ChairSelection(
                                      selectedTime: selectedShowtimeTime!,
                                      price: widget.price,
                                      theaters: widget.theaters,
                                      seats: seatLayout,
                                      title: widget.title,
                                      date: widget.date,
                                      showtimeId: selectedShowtimeId!,
                                      uid: widget.uid, image: widget.image,
                                    ),
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text(
                          "Book Now",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
