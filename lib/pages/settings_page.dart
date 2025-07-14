/*
  For UI, data, profile, etc.
 */
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
        ),
        body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(24),
              // SETTINGS OPTIONS
              children: [
                SettingsGroup(
                    title: 'General',
                    children: [
                      //buildDarkMode(),
                    ]
                )
              ],
            )
        )
    );
  }

  /*
  Widget buildDarkMode() =>
      SwitchSettingsTile(
        title: 'Dark Mode',
        //settingKey: SettingsPage.keyDarkMode,
        leading: Icon(Icons.dark_mode, color: Colors.purple),
        onChange: (isDarkMode) {
          setState(() {
            isDarkMode = !isDarkMode;
          });
        },
      );
      */
}