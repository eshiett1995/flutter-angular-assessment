import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static ThemeService? _instance;
  
  static ThemeService get instance {
    _instance ??= ThemeService._internal();
    return _instance!;
  }
  
  ThemeService._internal();

  ThemeMode _themeMode = ThemeMode.system;
  bool _isInitialized = false;

  ThemeMode get themeMode => _themeMode;

  // Light theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Colors.grey[50],
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }

  // Dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: Colors.grey[900],
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.grey[850],
        foregroundColor: Colors.white,
      ),
    );
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeString = prefs.getString(_themeKey);
      
      if (themeModeString != null) {
        _themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.toString() == themeModeString,
          orElse: () => ThemeMode.system,
        );
      }
      _isInitialized = true;
    } catch (e) {
      print('Error loading theme preference: $e');
      _isInitialized = true;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, mode.toString());
    } catch (e) {
      print('Error saving theme preference: $e');
    }
  }

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      // If system, toggle to light
      await setThemeMode(ThemeMode.light);
    }
  }
}

