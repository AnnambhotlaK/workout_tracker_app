/*
  For UI, data, profile, etc.
 */
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:provider/provider.dart';

import '../theme/theme_provider.dart';

// Setting keys
const String keyDarkMode = 'key-dark-mode';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
                SettingsGroup(
                    title: 'Appearance',
                    children: [
                      _buildDarkModeSwitch(themeProvider),
                    ]
                )
              ],
            )
        )
    );
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
    );
  }

}