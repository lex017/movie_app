import 'package:flutter/material.dart';
import 'package:movie_app/buttombar/home.dart';
import 'package:movie_app/buttombar/movie.dart';
import 'package:movie_app/buttombar/setting.dart';
import 'package:movie_app/buttombar/ticket.dart';
import 'package:movie_app/drawer.dart';
import 'package:movie_app/headbar/comingsoon.dart';
import 'package:movie_app/headbar/nowshowing.dart';
import 'package:movie_app/mainpage.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int selectidx = 1;

  void onTabTapped(int idx) {
    setState(() {
      selectidx = idx;
    });
  }
  
  
  
 final List<Widget> _pages = [
    const Mainpage(),
    const Movie(),
    const Ticket(),
    const Setting()  
  ];
  





  Widget BNavigateBar(int selectIdx, Function(int) onTabTapped) {
    return Container(
      
      height: 80,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        child: BottomNavigationBar(
          selectedItemColor: Colors.redAccent,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          currentIndex: selectIdx,
          onTap: onTabTapped,
          selectedLabelStyle:
              TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home, color: Colors.redAccent),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.movie_outlined),
              activeIcon: Icon(Icons.movie, color: Colors.redAccent),
              label: 'Movies',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_number_outlined),
              activeIcon:
                  Icon(Icons.confirmation_number, color: Colors.redAccent),
              label: 'Tickets',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings, color: Colors.redAccent),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(   
      child: _pages[selectidx]), // แสดงหน้าตาม index ที่เลือก
      bottomNavigationBar: BNavigateBar(selectidx, onTabTapped)
    );
  }
}
