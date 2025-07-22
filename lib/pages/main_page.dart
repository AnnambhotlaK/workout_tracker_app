import 'package:flutter/material.dart';
import 'package:main/pages/settings_page.dart';
import 'package:main/pages/stats_page.dart';
import 'package:provider/provider.dart';

import '../curr_workout_data/curr_workout_data.dart';
import '../curr_workout_data/workout_data_provider.dart';
import '../session_data/session_data.dart';
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
    const SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();

    //Provider.of<WorkoutDataProvider>(context, listen: false).workouts();
    Provider.of<SessionData>(context, listen: false).initializeSessionList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: pages[selectedPage],
      ),
      bottomNavigationBar: NavigationBar(
        height: 70,
        selectedIndex: selectedPage,
        onDestinationSelected: (value) {
          setState(() {
            selectedPage = value;
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
    );
  }
}
