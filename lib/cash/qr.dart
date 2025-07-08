import 'package:flutter/material.dart';
import 'package:movie_app/cash/pay.dart';

class qrpage extends StatefulWidget {
  final String selectedTime;
  final String title;
  final int price;
  final int theaters;
  final String date;
  final List<String> selectedSeats;
  final String uid;
  final int showtimeId;
  final String image;
  const qrpage(
      {super.key,
      required this.selectedTime,
      required this.price,
      required this.theaters,
      required this.selectedSeats,
      required this.title, required this.date, required this.uid, required this.showtimeId, required this.image});

  @override
  State<qrpage> createState() => _PaypageState();
}

class _PaypageState extends State<qrpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paypage')),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Scan QR for payments",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Image(
              image:
                  AssetImage("images/qr.jpeg"), 
              width: 600,
              height: 400,
            ),
            const SizedBox(height: 160),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  MaterialPageRoute route = MaterialPageRoute(
                      builder: (c) => Pay(
                            selectedTime: widget.selectedTime,
                            price: widget.price,
                            theaters: widget.theaters,
                            title: widget.title, selectedSeats: widget.selectedSeats, date: widget.date, uid: widget.uid, showtimeId: widget.showtimeId, image: widget.image,
                          ));
                  Navigator.of(context).push(route);
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  backgroundColor: Colors.red,
                ),
                child: const Text("Next",
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
