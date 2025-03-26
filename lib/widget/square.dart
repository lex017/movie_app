import 'package:flutter/material.dart';

class mysquare extends StatefulWidget {
  const mysquare({super.key});

  @override
  State<mysquare> createState() => _mysquareState();
}

class _mysquareState extends State<mysquare> {
  @override
  Widget build(BuildContext context) {
    return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              height: 200,
              color: Colors.black,
            ),
          );
  }
}