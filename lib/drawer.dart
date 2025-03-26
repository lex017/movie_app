import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


class drawer_menu extends StatefulWidget {
  const drawer_menu({super.key});

  @override
  State<drawer_menu> createState() => _drawer_menuState();
}

class _drawer_menuState extends State<drawer_menu> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
            Card(
              
              
              child: ListTile(
                
                title: Text('ຂໍ້ມູນປະເພດສິນຄ້າ',
                style: TextStyle(fontSize: 22.0,
                color: Colors.black
                ),
                ),
                onTap: () {
                  Navigator.of(context).pop();

                  
                },
              ),
            ),
            Card(
              
              
              child: ListTile(
                
                title: Text('ຫົວຫນ່ວຍ',
                style: TextStyle(fontSize: 22.0,
                color: Colors.black
                ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Card(
              
              
              child: ListTile(

                title: Text('ຂໍ້ມູນສິນຄ້າ',
                style: TextStyle(fontSize: 22.0,
                color: Colors.black
                ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Card(
              
              
              child: ListTile(
                
                title: Text('ຂາຍ',
                style: TextStyle(fontSize: 22.0,
                color: Colors.black
                ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Card(
              
              
              child: ListTile(
               
                title: Text('ສັ່ງຊື່ສຶນຄ້າ',
                style: TextStyle(fontSize: 22.0,
                color: Colors.black
                ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Card(
              
              
              child: ListTile(
                
                title: Text('ນຳເຂົ້າສິນຄ້າ',
                style: TextStyle(fontSize: 22.0,
                color: Colors.black
                ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Card(
              
              
              child: ListTile(
               
                title: Text('ຄົ້ນຫາ',
                style: TextStyle(fontSize: 22.0,
                color: Colors.black
                ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Card(
              
              
              child: ListTile(
               
                title: Text('ລາຍງານ',
                style: TextStyle(fontSize: 22.0,
                color: Colors.black
                ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            )

        ],
      ),
    );
  }
}