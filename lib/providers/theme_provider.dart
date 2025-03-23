import 'package:flutter/material.dart';

enum ThemeStyle {
  purple('默认紫色优雅风'),
  blue('静谧蓝调风'),
  orange('活力橙光风'),
  green('自然森林风'),
  pink('樱花飘雪风'); // 更改为樱花主题的名称

  const ThemeStyle(this.displayName);
  final String displayName;
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  ThemeStyle _themeStyle = ThemeStyle.purple;

  // 添加背景色映射，为每种主题风格提供匹配的背景色
  Map<ThemeStyle, Color> get backgroundColors => {
    ThemeStyle.purple: const Color(0xFF2D2B52),
    ThemeStyle.blue: const Color(0xFF1A2B3C),
    ThemeStyle.orange: const Color(0xFF2D2217),
    ThemeStyle.green: const Color(0xFF1A2E1A),
    ThemeStyle.pink: const Color(0xFF2B1F2B), // 樱花粉对应的深色背景
  };
  
  // 添加内容区域背景色映射
  Map<ThemeStyle, Color> get contentBackgroundColors => {
    ThemeStyle.purple: const Color(0xFF3D3B62),
    ThemeStyle.blue: const Color(0xFF2A3B4C),
    ThemeStyle.orange: const Color(0xFF3D3227),
    ThemeStyle.green: const Color(0xFF2A3E2A),
    ThemeStyle.pink: const Color(0xFF3B2F3B), // 樱花粉对应的内容区域背景
  };
  
  // 添加卡片背景色映射
  Map<ThemeStyle, Color> get cardBackgroundColors => {
    ThemeStyle.purple: const Color(0xFF4D4B72),
    ThemeStyle.blue: const Color(0xFF3A4B5C),
    ThemeStyle.orange: const Color(0xFF4D4237),
    ThemeStyle.green: const Color(0xFF3A4E3A),
    ThemeStyle.pink: const Color(0xFF4B3F4B), // 樱花粉对应的卡片背景
  };

  ThemeMode get themeMode => _themeMode;
  ThemeStyle get themeStyle => _themeStyle;
  
  // 获取当前主题的背景色
  Color get currentBackgroundColor => backgroundColors[_themeStyle]!;
  
  // 获取当前主题的内容区域背景色
  Color get currentContentBackgroundColor => contentBackgroundColors[_themeStyle]!;
  
  // 获取当前主题的卡片背景色
  Color get currentCardBackgroundColor => cardBackgroundColors[_themeStyle]!;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setThemeStyle(ThemeStyle style) {
    _themeStyle = style;
    notifyListeners();
  }
}