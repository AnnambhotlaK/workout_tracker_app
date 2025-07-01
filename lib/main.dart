import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:main/pages/main_page.dart';
import 'package:main/session_data/session_data.dart';
import 'package:main/workout_data/curr_workout_data.dart';
import 'package:provider/provider.dart';

import 'models/exercise.dart';
import 'models/session.dart';
import 'models/set.dart';
import 'models/workout.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(WorkoutAdapter());
  Hive.registerAdapter(ExerciseAdapter());
  Hive.registerAdapter(SetAdapter());
  Hive.registerAdapter(SessionAdapter());
  var workoutBox = await Hive.openBox("curr_workouts_database");
  var sessionBox = await Hive.openBox("session_database");
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
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.black,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
        ),
        themeMode: ThemeMode.dark,
        debugShowCheckedModeBanner: false,
        home: const MainPage(),
      ),
    );
  }
}
