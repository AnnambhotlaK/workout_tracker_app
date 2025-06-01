import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:main/session_data/session_data.dart';
import 'package:main/workout_data/curr_workout_data.dart';
import 'package:provider/provider.dart';
import 'pages/home_page.dart';

List<Box> boxList = [];
Future<List<Box>> _openBox() async {
  var workout_box = await Hive.openBox("curr_workouts_database");
  var session_box = await Hive.openBox("session_database");
  boxList.add(workout_box);
  boxList.add(session_box);
  return boxList;
}

void main() async {
  // Initialize hive
  await Hive.initFlutter();
  await _openBox();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<WorkoutData>(create: (context) => WorkoutData()),
        ChangeNotifierProvider<SessionData>(create: (context) => SessionData()),
      ],
      child: MaterialApp(
        theme: ThemeData(
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
        ),
        themeMode: ThemeMode.dark,
        debugShowCheckedModeBanner: false,
        home: const HomePage(),
      ),
    );
  }
}
