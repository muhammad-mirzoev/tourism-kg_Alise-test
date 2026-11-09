import 'package:flutter/material.dart';

import 'home_page.dart';
import 'hotel_add_page.dart';
import 'info_page.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> visual_pages = [HomePage(), HotelAddPage(), InfoPage()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: visual_pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "All"),

          BottomNavigationBarItem(
            icon: Icon(Icons.add_business),
            label: "Add Hotel",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: "Info"),
        ],
      ),
    );
  }
}
