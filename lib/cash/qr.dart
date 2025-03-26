import 'package:flutter/material.dart';
import 'package:movie_app/cash/pay.dart';

class qrpage extends StatefulWidget {
  const qrpage({super.key});

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
                  AssetImage("images/qr.jpeg"), // ใส่ลิงก์ QR Code ที่ต้องการ
              width: 600,
              height: 400,
            ),
            const SizedBox(height: 160),
            Center(
              child: ElevatedButton(
                onPressed: (){
                  Navigator.of(context).pop();
                MaterialPageRoute route =
                    MaterialPageRoute(builder: (c) => Pay());
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
