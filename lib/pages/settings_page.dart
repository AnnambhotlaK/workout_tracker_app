/*
  For UI, data, profile, etc.
 */
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:main/helper/helper_functions.dart';
import 'package:provider/provider.dart';

import '../auth/auth_wrapper.dart';
import '../services/auth_service.dart';
import '../theme/theme_provider.dart';

// Setting keys
const String keyDarkMode = 'key-dark-mode';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future<void> _handleLogout(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      await authService.signOut();
      // After logout, navigate back to login page
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => AuthWrapper()),
          // removes all prev routes
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        displayMessageToUser("Error signing out: ${e.toString()}", context);
      }
      print("Error signing out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize ThemeProvider for dark mode
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        ),
        body: SafeArea(
            child: ListView(
          padding: const EdgeInsets.all(24),
          // SETTINGS OPTIONS
          children: [
            // APPEARANCE
            SettingsGroup(title: 'Appearance', children: [
              _buildDarkModeSwitch(themeProvider),
            ]),
            const SizedBox(height: 20),

            // ACCOUNT
            SettingsGroup(
                title: 'Account',
                children: <Widget>[_buildLogoutButton(context)]),
            const SizedBox(height: 20),
          ],
        )));
  }

  Widget _buildDarkModeSwitch(ThemeProvider themeProvider) {
    bool isCurrentlyDark;

    return SwitchSettingsTile(
      settingKey: keyDarkMode,
      title: 'Dark Mode',
      leading: Icon(Icons.dark_mode, color: Colors.purple),
      onChange: (bool isDarkModeOn) {
        themeProvider.toggleTheme(isDarkModeOn);
      },
      activeColor: Colors.grey.shade800,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SimpleSettingsTile(
        title: 'Logout',
        leading: const Icon(Icons.logout, color: Colors.red),
        onTap: () {
          // Show confirmation dialogue
          showDialog(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                    title: const Text('Confirm Logout'),
                    content: const Text('Are you sure you want to log out?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Logout'),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          _handleLogout(context);
                        },
                      ),
                    ]);
              });
        });
  }
}
