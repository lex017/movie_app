import 'package:flutter/material.dart';
import 'package:movie_app/emp_scan.dart';

class EmpMain extends StatefulWidget {
  const EmpMain({super.key});

  @override
  State<EmpMain> createState() => _EmpMainState();
}

class _EmpMainState extends State<EmpMain> {
  final Map<String, String> employee = {
    'name': 'Deang',
    'position': 'Admin',
    'email': 'deang@gmail.com',
    'phone': '020 9999999',
  };

  void _onScanPressed() {
    
     Future.delayed(const Duration(milliseconds: 500), () async {
      String? result = await Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const ScanPage()),
);

if (result != null) {
  print('Scanned QR Code: $result');
  // Do something with result
}

    }); 

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Background color
      appBar: AppBar(
        title: const Text('Employee Profile'),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Container(
        child: Card(
          elevation: 8, // Increased elevation for a more pronounced shadow
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.red,
                  child: Text(
                    employee['name']![0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  employee['name']!,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  employee['position']!,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Divider(
                  height: 32,
                  thickness: 1,
                  indent: 60,
                  endIndent: 60,
                  color: Colors.grey,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.email, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(
                      employee['email']!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.phone, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(
                      employee['phone']!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _onScanPressed,
                  icon: const Icon(Icons.qr_code_scanner,color: Colors.white,),
                  label: const Text('Scan' ,style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      )
    );
  }
}