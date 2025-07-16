import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:movie_app/buttombar/ticket.dart';
import 'package:movie_app/homepage.dart';
import 'package:movie_app/mainpage.dart';
import 'package:movie_app/ticketdetail.dart';

class Pay extends StatefulWidget {
  final String selectedTime;
  final String title;
  final int price;
  final int theaters;
  final String date;
  final List<String> selectedSeats;
  final String uid;
  final int showtimeId;
  final String image;

  const Pay({
    super.key,
    required this.selectedTime,
    required this.price,
    required this.theaters,
    required this.title,
    required this.selectedSeats,
    required this.date,
    required this.uid,
    required this.showtimeId,
    required this.image,
  });

  @override
  State<Pay> createState() => _PayState();
}

class _PayState extends State<Pay> {
  File? _selectedImage;
  Uint8List? _imageBytes;
  bool _isUploading = false;
  bool isLoading = false; // add this to your State class
  String? _imageUrl;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _selectedImage = null;
        });
      } else {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _imageBytes = null;
        });
      }
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        timeController.text = pickedTime.format(context);
      });
    }
  }

  Future<void> _uploadToCloudinary(File imageFile) async {
    const cloudName = 'dwmp7qmqw';
    const uploadPreset = 'ticket';
    final url =
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    setState(() {
      _isUploading = true;
    });

    final response = await request.send();
    final responseData = await response.stream.bytesToString();

    setState(() {
      _isUploading = false;
    });

    if (response.statusCode == 200) {
      final data = json.decode(responseData);
      setState(() {
        _imageUrl = data['secure_url'];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload Success!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload Failed!')),
      );
    }
  }

  Future<void> _submitTicket() async {
    if (nameController.text.isEmpty ||
        timeController.text.isEmpty ||
        (_selectedImage == null && _imageBytes == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    String? imageUrl;

    if (_selectedImage != null) {
      await _uploadToCloudinary(_selectedImage!);
      imageUrl = _imageUrl;
    } else if (_imageBytes != null) {}

    if (imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image upload failed')),
      );
      return;
    }

    final url = Uri.parse("http://192.168.0.198:8000/ticket");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "u_id": widget.uid,
          "showtime_id": widget.showtimeId,
          "seat_num": widget.selectedSeats.join(','),
          "price": widget.price,
          "booking_date": DateTime.now().toIso8601String(),
          "name": nameController.text,
          "time_b": timeController.text,
          "theaters": widget.theaters,
          "selectedTime": widget.selectedTime,
          "image": imageUrl,
          "mv_name": widget.title,
          "show_date": widget.date,
          "status": "pending",
          "posterURL": widget.image,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final ticketId = data['ticket_id'];
        await _waitForVerification(ticketId);
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save ticket')),
        );
        print("Error: ${response.body}");
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred: $e')),
      );
    }
  }

  Future<void> _waitForVerification(int ticketId) async {
    int countdown = 300; // 5 minutes countdown
    bool isVerified = false;
    bool isRejected = false;
    Timer? timer;
    late StateSetter dialogSetState;
    BuildContext dialogContext = context;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        // Start periodic timer that runs every second
        timer = Timer.periodic(const Duration(seconds: 1), (t) async {
          countdown--;

          try {
            final res = await http
                .get(Uri.parse("http://192.168.0.198:8000/ticket/$ticketId"));

            if (res.statusCode == 200) {
              final ticket = jsonDecode(res.body);
              final status = ticket['status'];

              if (status == 'paid') {
                isVerified = true;
                timer?.cancel();
                Navigator.pop(context); // Close the verification dialog

                // Update points
                await http.put(
                  Uri.parse(
                      "http://192.168.0.198:8000/user/updatePoint/${widget.uid}"),
                  headers: {'Content-Type': 'application/json'},
                  body: json.encode({'add_point': 10}),
                );

                // Navigate to detail ticket page
                Navigator.pushReplacement(
                  dialogContext,
                  MaterialPageRoute(
                    builder: (context) => DetailTicket(
                      movieData: {
                        'mv_name': ticket['mv_name'],
                        'show_date': ticket['show_date'],
                        'selectedTime': ticket['selectedTime'],
                      },
                      paymentData: {
                        'price': ticket['price'],
                        'image': ticket['image'],
                        'time_b': ticket['time_b'],
                        'name': ticket['name'],
                      },
                      ticketData: ticket,
                      image: ticket['posterURL'],
                      uid: widget.uid,
                    ),
                  ),
                );
                return;
              } else if (status == 'rejected') {
                isRejected = true;
                timer?.cancel();
                Navigator.pop(context); // Close the verification dialog

                // Delete rejected ticket
                await http.delete(
                    Uri.parse("http://192.168.0.198:8000/ticket/$ticketId"));

                // Show rejection alert and navigate to homepage after OK
                showDialog(
                  context: dialogContext,
                  builder: (_) => AlertDialog(
                    title: const Text('❌ Payment Rejected'),
                    content: const Text(
                        'Your payment was rejected. Please try again.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext)
                              .pop(); // Close rejection dialog
                          Navigator.of(dialogContext, rootNavigator: true)
                              .pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (_) => Homepage(uid: widget.uid)),
                            (route) => false,
                          );
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
                return;
              }
            }
          } catch (e) {
            // You can handle errors here or ignore
          }

          if (countdown <= 0 && !isVerified && !isRejected) {
            timer?.cancel();
            Navigator.pop(context); // Close the verification dialog

            // Delete ticket on timeout
            await http.delete(
                Uri.parse("http://192.168.0.198:8000/ticket/$ticketId"));

            ScaffoldMessenger.of(dialogContext).showSnackBar(
              const SnackBar(content: Text('⏰ Verification timed out.')),
            );

            Navigator.of(dialogContext, rootNavigator: true).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => Homepage(uid: widget.uid)),
              (route) => false,
            );
          }

          // Refresh dialog state to update countdown timer UI
          dialogSetState(() {});
        });

        // StatefulBuilder allows updating dialog content dynamically
        return StatefulBuilder(
          builder: (context, setState) {
            dialogSetState = setState;
            final minutes = (countdown ~/ 60).toString().padLeft(2, '0');
            final seconds = (countdown % 60).toString().padLeft(2, '0');

            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: const [
                  Icon(Icons.timer, color: Colors.deepOrange),
                  SizedBox(width: 10),
                  Text("Waiting for Verification"),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.network(
                    'https://assets9.lottiefiles.com/packages/lf20_x62chJ.json',
                    height: 100,
                    width: 100,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 10),
                  const Text("Please complete your payment within:"),
                  Text(
                    "$minutes:$seconds",
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text("Waiting for admin to verify payment..."),
                ],
              ),
            );
          },
        );
      },
    );

    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment & Booking'),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Payment & Booking Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('${widget.price} Kip', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            TextFormField(
              controller: timeController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Select Transfer Time",
                suffixIcon: IconButton(
                    icon: const Icon(Icons.access_time), onPressed: _pickTime),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Your Name",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Upload Payment Slip",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover))
                    : _imageBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child:
                                Image.memory(_imageBytes!, fit: BoxFit.cover))
                        : const Center(
                            child: Text("Tap to upload",
                                style: TextStyle(color: Colors.grey))),
              ),
            ),
            const SizedBox(height: 40),

// Then update your button like this:

            Center(
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        setState(() {
                          isLoading = true;
                        });

                        await _submitTicket();

                        setState(() {
                          isLoading = false;
                        });
                      },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  backgroundColor: Colors.red,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        "Pay Now",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
