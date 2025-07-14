import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:movie_app/homepage.dart';
import 'package:movie_app/register.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLoading = false;

   Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://192.168.0.195:8000/login'), // Update your IP
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'u_email': email, 'u_password': password}),
      );

      if (response.statusCode == 200) {
  final data = json.decode(response.body);
  final String uId = data['u_id'].toString(); // ✅ FIXED
  final String uName = data['u_name'];

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('u_id', uId);

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Login successful!')),
  );

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => Homepage(uid: uId)),
    (route) => false,
  );


      } else {
        final err = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${err['error'] ?? 'Unknown error'}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Colors.red),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 8,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      'Login',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Register()),
                        );
                      },
                      child: const Text(
                        'Don\'t have an account? Register',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
