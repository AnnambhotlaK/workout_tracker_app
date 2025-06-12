import 'package:flutter/material.dart';
import 'package:main/pages/stats_page.dart';

import 'home_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedPage = 0;
  final List<Widget> pages = [
    const HomePage(),
    const StatsPage(),
    const HomePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedPage],
      bottomNavigationBar: NavigationBar(
        indicatorColor: Colors.blue,
        shadowColor: Colors.blue,
        height: 70,
        selectedIndex: selectedPage,
        onDestinationSelected: (value) {
          setState(() {
            selectedPage = value;
            print(pages[selectedPage]);
          });
        },
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(Icons.home), // Icon when selected
            icon: Icon(Icons.home_outlined), // Icon when not selected
            label: "Home",
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.stacked_line_chart),
            icon: Icon(Icons.stacked_line_chart_outlined),
            label: "Stats",
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.settings),
            icon: Icon(Icons.settings_outlined),
            label: "Settings",
          ),
        ]
      )
      /*
      BottomNavigationBar(
          currentIndex: currentPage,
          onTap: (value) {
            setState(() {
              currentPage = value;
            });
          },
          items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.stacked_line_chart), label: "Stats"),
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
          ],
      ),
    */
    );
  }
}
