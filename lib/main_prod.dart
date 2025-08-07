import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:main/auth/auth_wrapper.dart';
import 'package:main/data_providers/session_data_provider.dart';
import 'package:main/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'data_providers/workout_data_provider.dart';
import 'exercise_db/database_helper.dart';
import 'helper_functions.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase(isProd: true);
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),

        ChangeNotifierProxyProvider<AuthService, WorkoutDataProvider>(
            create: (context) => WorkoutDataProvider(
              Provider.of<AuthService>(context, listen: false).currentUserId,
            ),
            update: (context, authService, previousWorkoutProvider) {
              final newUserId = authService.currentUserId;
              print("ProxyProvider fo SessionDataProvider: Updating user to $newUserId");
              previousWorkoutProvider!.updateUser(newUserId);
              return previousWorkoutProvider;
            }),

        ChangeNotifierProxyProvider<AuthService, SessionDataProvider>(
            create: (context) => SessionDataProvider(
              Provider.of<AuthService>(context, listen: false).currentUserId,
            ),
            update: (context, authService, previousSessionProvider) {
              final newUserId = authService.currentUserId;
              print("ProxyProvider for SessionDataProvider: Updating user to $newUserId");
              previousSessionProvider!.updateUser(newUserId);
              return previousSessionProvider;
            }),

      ],
      child: MaterialApp(
        title: 'Onfinity',
        debugShowCheckedModeBanner: false,
        home: AuthWrapper(),
        theme: Provider.of<ThemeProvider>(context).themeData,
      ),
    );
  }
}
