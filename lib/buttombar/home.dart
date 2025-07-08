import 'package:flutter/material.dart';
import 'package:movie_app/buttombar/movie.dart';
import 'package:movie_app/drawer.dart';
import 'package:movie_app/headbar/comingsoon.dart';
import 'package:movie_app/headbar/nowshowing.dart';
import 'package:movie_app/homepage.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _MainpageState();
}

class _MainpageState extends State<Home> {
  int selectidx = 1;

  void onTabTapped(int idx) {
    setState(() {
      selectidx = idx;
    });
  }

  List item = ["NOW SHOWING", "COMING SOON", "2D", "3D", "KIDS CINEMA"];

  Widget TabBarMenu() {
    return TabBar(
        isScrollable: true,
        labelStyle: TextStyle(color: Colors.black, fontSize: 21),
        unselectedLabelStyle: TextStyle(fontSize: 18),
        tabs: [
          Tab(
            text: item[0],
          ),
          Tab(
            text: item[1],
          ),
          Tab(
            text: item[2],
          ),
          Tab(
            text: item[3],
          ),
          Tab(
            text: item[4],
          ),
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: item.length,
      child: Scaffold(
        appBar: AppBar(
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: TabBarMenu(),
          ),
          title: Text('Popular'),
          actions: [
            IconButton(
              icon: CircleAvatar(
                child: ClipOval(
                  child: Image.asset(
                    "assets/dollar.png",
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.error, color: Colors.red);
                    },
                  ),
                ),
              ),
              onPressed: () {},
            ),
          ],
        ),
        body: TabBarView(children: [
          Center(
            child: Nowshowing(uid: '',),
          ),
          Center(
            child: Comingsoon(),
          ),
          Center(
            child: Text("preorder"),
          ),
          Center(
            child: Text("ນຳເຂົ້າ"),
          ),
          Center(
            child: Text("ຄົ້ນຫາ"),
          ),
        ]),
      ),
    );
  }
}
