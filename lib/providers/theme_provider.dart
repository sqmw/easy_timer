import 'package:flutter/material.dart';

enum ThemeStyle {
  purple('默认紫色优雅风'),
  blue('静谧蓝调风'),
  orange('活力橙光风'),
  green('自然森林风');

  const ThemeStyle(this.displayName);
  final String displayName;
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  ThemeStyle _themeStyle = ThemeStyle.purple;

  ThemeMode get themeMode => _themeMode;
  ThemeStyle get themeStyle => _themeStyle;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setThemeStyle(ThemeStyle style) {
    _themeStyle = style;
    notifyListeners();
  }
}