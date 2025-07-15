import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  File? _selectedImage;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _gender;
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String? userId;
  bool _isUploading = false;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    loadUserId();
  }

  Future<void> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('u_id');
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found')),
      );
      return;
    }

    setState(() {
      userId = uid;
    });

    fetchUser();
  }

  Future<void> fetchUser() async {
    if (userId == null) return;
    try {
      final res = await http.get(Uri.parse('http://192.168.0.198:8000/user/$userId'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          userData = data;
          _nameController.text = data['u_name'] ?? '';
          _emailController.text = data['u_email'] ?? '';
          _phoneController.text = data['u_tel'] ?? '';
          _passwordController.text = data['u_password'] ?? '';
          _gender = data['u_gender'];
          _imageUrl = data['u_profile'];
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load user");
      }
    } catch (e) {
      print("❌ Error: $e");
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error loading user data')),
      );
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _uploadToCloudinary(File imageFile) async {
    const cloudName = 'dwmp7qmqw';
    const uploadPreset = 'ticket';
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

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

  void _saveProfile() async {
    if (userId == null) return;

    try {
      String? finalImageUrl = _imageUrl;

      if (_selectedImage != null) {
        await _uploadToCloudinary(_selectedImage!);
        finalImageUrl = _imageUrl;
      }

      final updatedUser = {
        "u_name": _nameController.text,
        "u_email": _emailController.text,
        "u_tel": _phoneController.text,
        "u_password": _passwordController.text,
        "u_gender": _gender,
        "u_profile": finalImageUrl,
      };

      final res = await http.put(
        Uri.parse("http://192.168.0.198:8000/user/$userId"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(updatedUser),
      );

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Profile updated!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Failed to update profile")),
        );
      }
    } catch (e) {
      print("❌ Error while saving: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error while saving profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 6,
                shadowColor: Colors.blueAccent.withOpacity(0.3),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: _selectedImage != null
                                ? FileImage(_selectedImage!)
                                : (_imageUrl != null && _imageUrl!.isNotEmpty
                                    ? NetworkImage(_imageUrl!) as ImageProvider
                                    : const AssetImage('assets/user.jpeg')),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 4,
                            child: InkWell(
                              onTap: _pickImage,
                              child: CircleAvatar(
                                backgroundColor: Colors.blueAccent,
                                child: const Icon(Icons.edit, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Telephone',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        value: _gender,
                        items: ['Male', 'Female', 'Other']
                            .map((gender) => DropdownMenuItem(
                                  value: gender,
                                  child: Text(gender),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _gender = value;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Gender',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isUploading ? null : _saveProfile,
                          icon: const Icon(Icons.save),
                          label: _isUploading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('Save Profile'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
