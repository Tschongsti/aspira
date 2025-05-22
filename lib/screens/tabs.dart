import 'package:flutter/material.dart';

import 'package:aspira/screens/fokustracking_screen.dart';
import 'package:aspira/screens/home_screen.dart';



class TabsScreen extends StatefulWidget {
  const TabsScreen ({super.key});

  @override
  State<TabsScreen> createState() {
    return _TabsScreenState();
  }
}

class _TabsScreenState extends State<TabsScreen> {
  int _selectedPageIndex = 0;

void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

@override
  Widget build(BuildContext context) {

    Widget activePage = HomeScreen();
    var activePageTitle = 'Home';

    if (_selectedPageIndex == 1) {
      activePage = FokustrackingScreen();
      activePageTitle = 'Fokus-Tätigkeiten';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(activePageTitle),
      ),
      body: activePage,
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        currentIndex: _selectedPageIndex, // highlights the selected page
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Fokus-Tätigkeiten',
          )
        ],
      ),
    );   
 }
}