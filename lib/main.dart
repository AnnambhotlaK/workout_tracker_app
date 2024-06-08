import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:main/data/workout_data.dart';
import 'package:provider/provider.dart';
import 'pages/home_page.dart';

void main() async {
  // Initialize hive
  await Hive.initFlutter();
  
  // Open a hive box
  await Hive.openBox('workout_database');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WorkoutData(),
      child: MaterialApp(
        theme: ThemeData(
          brightness: Brightness.light,
        ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        /* dark theme settings */
      ),
      themeMode: ThemeMode.light, 
      /* ThemeMode.system to follow system theme, 
         ThemeMode.light for light theme, 
         ThemeMode.dark for dark theme
      */
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      ),
    );
  }
}
