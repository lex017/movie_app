
import 'package:flutter/material.dart';
import 'package:movie_app/homepage.dart';
import 'package:movie_app/login.dart';

void main(){
  runApp(myapp());
}

class myapp extends StatelessWidget {
  const myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'movie',
      home:const Login()
    );
  }
}