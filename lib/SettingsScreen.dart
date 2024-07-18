import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'MyHomePage.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkModeEnabled = false; // Default to light mode

  @override
  void initState() {
    super.initState();
    _loadDarkModePreference();
  }

  // Load dark mode preference from shared preferences
  Future<void> _loadDarkModePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkModeEnabled = prefs.getBool('darkMode') ?? false;
    });
  }

  // Save dark mode preference to shared preferences
  Future<void> _saveDarkModePreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: <Widget>[
          SwitchListTile(
            title: Text('Dark Mode'),
            value: _darkModeEnabled,
            onChanged: (value) {
              setState(() {
                _darkModeEnabled = value;
                _saveDarkModePreference(value);
                _changeTheme(value);
              });
            },
          ),
        ],
      ),
    );
  }

  void _changeTheme(bool value) {
    ThemeData themeData = value ? ThemeData.dark() : ThemeData.light();
    // Apply the theme globally to the app
    MaterialApp app = MaterialApp(
      theme: themeData,
      home: MyHomePage(), // Use your actual home page widget
    );
    setState(() {
      // Update the app with the new theme
      runApp(app);
    });
  }
}

void main() => runApp(MaterialApp(
  home: MyHomePage(),
));
