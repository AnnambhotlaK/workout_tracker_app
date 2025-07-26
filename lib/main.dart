import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:main/auth/auth_wrapper.dart';
import 'package:main/pages/home_page.dart';
import 'package:main/session_data/session_data_provider.dart';
import 'package:main/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'curr_workout_data/workout_data_provider.dart';
import 'exercise_db/database_helper.dart';
import 'firebase_options.dart';
import 'theme/theme.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Settings.init();

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
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProxyProvider<AuthService, WorkoutDataProvider>(
            create: (context) => WorkoutDataProvider(null),
            update: (context, authService, previousWorkoutProvider) {
              final userId = authService.currentUserId;
              if (userId == null) {
                previousWorkoutProvider?.clearDataOnLogout();
                return previousWorkoutProvider ?? WorkoutDataProvider(null);
              }
              if (previousWorkoutProvider == null ||
                  previousWorkoutProvider.currentUserId != userId) {
                return WorkoutDataProvider(userId);
              } else {
                return previousWorkoutProvider;
              }
            }),
        ChangeNotifierProxyProvider<AuthService, SessionDataProvider>(
            create: (context) => SessionDataProvider(null),
            update: (context, authService, previousSessionProvider) {
              final userId = authService.currentUserId;
              if (userId == null) {
                previousSessionProvider?.clearDataOnLogout();
                return previousSessionProvider ?? SessionDataProvider(null);
              }
              if (previousSessionProvider == null ||
                  previousSessionProvider.currentUserId != userId) {
                return SessionDataProvider(userId);
              } else {
                return previousSessionProvider;
              }
            }),
      ],
      child: MaterialApp(
        title: 'Setly',
        debugShowCheckedModeBanner: false,
        home: AuthWrapper(),
        theme: lightMode,
        darkTheme: darkMode,
        themeMode: themeProvider.themeMode,
      ),
    );
  }
}
