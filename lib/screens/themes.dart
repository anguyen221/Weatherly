import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppThemes {
  static const String _themeKey = 'selected_background';

  static const Map<String, String> themeImages = {
    'blue': 'assets/blue.jpg',
    'yellow': 'assets/yellow.png',
    'green': 'assets/green.png',
    'pink': 'assets/pink.jpg',
  };

  static ValueNotifier<String?>? selectedTheme;

  static BoxDecoration getBackgroundDecoration(String? themeName) {
    final imagePath = themeImages[themeName];
    if (imagePath != null) {
      return BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      );
    } else {
      return const BoxDecoration(color: Colors.white);
    }
  }

  static Future<void> saveTheme(String themeName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, themeName);
    selectedTheme?.value = themeName;
  }

  static Future<String?> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey);
  }
}