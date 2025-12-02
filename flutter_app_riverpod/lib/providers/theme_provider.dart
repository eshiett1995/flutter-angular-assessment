import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  static const String _themeKey = 'theme_mode';

  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeString = prefs.getString(_themeKey);
      
      if (themeModeString != null) {
        state = ThemeMode.values.firstWhere(
          (mode) => mode.toString() == themeModeString,
          orElse: () => ThemeMode.system,
        );
      }
    } catch (e) {
      print('Error loading theme preference: $e');
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state == mode) return;
    
    state = mode;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, mode.toString());
    } catch (e) {
      print('Error saving theme preference: $e');
    }
  }

  Future<void> toggleTheme() async {
    if (state == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else if (state == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      // If system, toggle to light
      await setThemeMode(ThemeMode.light);
    }
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

// Light theme
final lightThemeProvider = Provider<ThemeData>((ref) {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Colors.grey[50],
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
  );
});

// Dark theme
final darkThemeProvider = Provider<ThemeData>((ref) {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
    ),
    cardColor: Colors.grey[800],
    textTheme: Typography.whiteMountainView.apply(bodyColor: Colors.white),
    iconTheme: const IconThemeData(color: Colors.white),
  );
});

