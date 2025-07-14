import 'package:flutter/material.dart';
import 'package:movie_app/emp_scan.dart'; // import หน้า scan ของคุณ
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmpMain extends StatefulWidget {
  final String adminEmail;
  final String uid;

  const EmpMain({super.key, required this.adminEmail, required this.uid});

  @override
  State<EmpMain> createState() => _EmpMainState();
}

class _EmpMainState extends State<EmpMain> {
  Map<String, dynamic>? employee;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAdminData(widget.adminEmail);
  }

  Future<void> fetchAdminData(String email) async {
  try {
    final url = Uri.parse('http://192.168.0.195:8000/admin/email/$email');
    final response = await http.get(url);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Parsed data: $data');
      setState(() {
        employee = data;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('dont see admin')),
      );
    }
  } catch (e) {
    setState(() {
      isLoading = false;
    });
    print('Error fetching admin: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('err: $e')),
    );
  }
}


 void _onScanPressed() async {
  String? result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ScanPage(userId: widget.uid)),
  );

  if (result != null) {
    print('Scanned QR Code: $result');

  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Employee Profile'),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : employee == null
              ? const Center(child: Text('dont see emp'))
              : Card(
                  elevation: 8,
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
                            (employee!['admin_name'] ?? 'U')[0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          employee!['admin_name'] ?? '',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Employee scan', 
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
                              employee!['admin_email'] ?? '',
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
                              employee!['admin_tel'] ?? '',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: _onScanPressed,
                          icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                          label: const Text(
                            'Scan',
                            style: TextStyle(color: Colors.white),
                          ),
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
    );
  }
}
