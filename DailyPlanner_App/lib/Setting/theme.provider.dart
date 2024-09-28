import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  Color _primaryColor = Colors.blue;
  String _fontFamily = 'Roboto';

  bool get isDarkMode => _isDarkMode;
  Color get primaryColor => _primaryColor;
  String get fontFamily => _fontFamily;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setPrimaryColor(Color color) {
    _primaryColor = color;
    notifyListeners();
  }

  void setFontFamily(String font) {
    _fontFamily = font;
    notifyListeners();
  }

  ThemeMode get currentThemeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  // Áp dụng theme cho chế độ sáng
  ThemeData get currentTheme {
    return ThemeData(
      primaryColor: _primaryColor,
      fontFamily: _fontFamily,
      brightness: Brightness.light,
      appBarTheme: AppBarTheme(
        backgroundColor: _primaryColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor, 
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _primaryColor,
      ),
    );
  }

  // Áp dụng theme cho chế độ tối
  ThemeData get darkTheme {
    return ThemeData(
      primaryColor: _primaryColor,
      fontFamily: _fontFamily,
      brightness: Brightness.dark,
      appBarTheme: AppBarTheme(
        backgroundColor: _primaryColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _primaryColor,
      ),
    );
  }
}
