import 'package:flutter/material.dart';
import '../services/client_config_service.dart';

class ThemeProvider extends ChangeNotifier {
  final ClientConfigService _configService = ClientConfigService();
  ThemeData? _theme;

  ThemeData get theme {
    if (_theme == null) {
      _buildTheme();
    }
    return _theme!;
  }

  void _buildTheme() {
    final config = _configService;
    
    // Criar MaterialColor a partir da cor primária
    final primarySwatch = _createMaterialColor(config.primaryColor);
    
    _theme = ThemeData(
      primarySwatch: primarySwatch,
      colorScheme: ColorScheme.fromSwatch(primarySwatch: primarySwatch).copyWith(
        primary: config.primaryColor,
        secondary: config.accentColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      fontFamily: 'Roboto',
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
          color: config.primaryColor,
        ),
        displayMedium: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: config.primaryDarkColor,
        ),
        bodyLarge: TextStyle(fontSize: 16.0, color: Colors.black87),
        bodyMedium: TextStyle(fontSize: 14.0, color: Colors.black54),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: config.primaryColor,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: config.primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: config.accentColor,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: config.primaryColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
      ),
    );
  }

  MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }

  void reloadTheme() {
    _buildTheme();
    notifyListeners();
  }
}