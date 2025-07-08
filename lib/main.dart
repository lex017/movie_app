import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movie_app/homepage.dart';
import 'package:movie_app/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Check if user is already logged in
  Future<Widget> _getInitialScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('u_id');

    if (uid != null && uid.isNotEmpty) {
      return Homepage(uid: uid); // Go to homepage with u_id
    } else {
      return const Login(); // Go to login screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'movie',
      home: FutureBuilder<Widget>(
        future: _getInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return snapshot.data!;
          } else {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }
}
