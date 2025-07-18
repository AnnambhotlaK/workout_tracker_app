import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:main/pages/main_page.dart';
import 'package:main/pages/settings_page.dart';
import 'package:main/session_data/session_data.dart';
import 'package:main/curr_workout_data/curr_workout_data.dart';
import 'package:main/theme/theme_provider.dart';
import 'package:provider/provider.dart';

import 'exercise_db/database_helper.dart';
import 'models/exercise.dart';
import 'models/session.dart';
import 'models/set.dart';
import 'models/workout.dart';
import 'theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Settings.init();
  await Hive.initFlutter();

  Hive.registerAdapter(WorkoutAdapter());
  Hive.registerAdapter(ExerciseAdapter());
  Hive.registerAdapter(SetAdapter());
  Hive.registerAdapter(SessionAdapter());

  // TEST ON DATABASEHELPER
  print("Main: Calling DatabaseHelper.instance.database to initialize.");
  try {
    await DatabaseHelper
        .instance.database; // This triggers the getter and initialization
    print("Main: Database initialization call completed.");
  } catch (e) {
    print("Main: Error during initial database call: $e");
    // Handle critical initialization error if necessary
  }

  var workoutBox = await Hive.openBox("curr_workouts_database");
  var sessionBox = await Hive.openBox("session_database");
  runApp(ChangeNotifierProvider(
      create: (_) => ThemeProvider(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<WorkoutData>(create: (context) => WorkoutData()),
        ChangeNotifierProvider<SessionData>(create: (context) => SessionData()),
      ],
      child: MaterialApp(
        title: 'Forma',
        debugShowCheckedModeBanner: false,
        home: const MainPage(),
        theme: lightMode,
        darkTheme: darkMode,
        themeMode: themeProvider.themeMode,
      ),
    );
  }
}
