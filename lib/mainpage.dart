import 'package:flutter/material.dart';
import 'package:movie_app/buttombar/home.dart';
import 'package:movie_app/buttombar/movie.dart';
import 'package:movie_app/buttombar/setting.dart';
import 'package:movie_app/buttombar/ticket.dart';
import 'package:movie_app/drawer.dart';
import 'package:movie_app/headbar/comingsoon.dart';
import 'package:movie_app/headbar/nowshowing.dart';
import 'package:movie_app/homepage.dart';
import 'package:movie_app/reward.dart';

class Mainpage extends StatefulWidget {
  final String uid;
  const Mainpage({super.key, required this.uid});

  @override
  State<Mainpage> createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {

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
              icon: const CircleAvatar(
                backgroundImage: AssetImage('assets/dollar.png'),
              ),
              onPressed: () {
                Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Reward(uid: widget.uid,)),
                        );
              },
            ),
            const SizedBox(width: 10),
          ],
        ),
        
        body: TabBarView(children: [
          Center(
            child: Nowshowing(uid: widget.uid,),
          ),
          Center(
            child: Comingsoon(),
          ),
          Center(
            child: Text("Comming soon"),
          ),
          Center(
            child: Text("Comming soon"),
          ),
          Center(
            child: Text("Comming soon"),
          ),
          
        ]),
  
      ),
    );
  }
}