
import 'package:flutter/material.dart';
import 'package:movie_app/homepage.dart';

void main(){
  runApp(myapp());
}

class myapp extends StatelessWidget {
  const myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'movie',
      home:const Homepage()
    );
  }
}