import 'package:flutter/material.dart';
import 'package:movie_app/emp_scan.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmpMain extends StatefulWidget {
  final String empEmail;
  final String empName;
  final String empId;

  const EmpMain({
    super.key,
    required this.empEmail,
    required this.empId,
    required this.empName,
  });

  @override
  State<EmpMain> createState() => _EmpMainState();
}

class _EmpMainState extends State<EmpMain> {
  Map<String, dynamic>? employee;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAdminData(widget.empEmail);
  }

  Future<void> fetchAdminData(String email) async {
    try {
      final url = Uri.parse('http://192.168.0.196:8000/emp/email/$email');
      final response = await http.get(url);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic>) {
          setState(() {
            employee = data;
            isLoading = false;
          });
        } else {
          throw Exception('Invalid data format from server');
        }
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Employee not found')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching emp: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _onScanPressed() async {
    String? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ScanPage(userId: widget.empId)),
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
              ? const Center(child: Text('Employee data not available'))
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
                            (employee?['emp_name'] != null && employee!['emp_name'].toString().isNotEmpty)
                                ? employee!['emp_name'][0]
                                : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          employee?['emp_name']?.toString() ?? 'No Name',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Employee scan',
                          style: TextStyle(
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
                              employee?['emp_email']?.toString() ?? 'No email',
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
                              employee?['emp_tel']?.toString() ?? 'No phone',
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
