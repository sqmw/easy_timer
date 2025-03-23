import 'package:flutter/material.dart';
import 'package:easy_timer/theme/app_colors.dart';

class AppTheme {
  // 亮色主题，支持自定义主色调
  static ThemeData lightTheme({Color? primaryColor}) {
    // 如果提供了自定义主色调，则使用它，否则使用默认的薰衣草紫色
    final Color primary = primaryColor ?? AppColors.primary;
    
    // 根据主色调生成其他颜色
    final Color primaryLight = _lightenColor(primary, 0.15);
    final Color primaryDark = _darkenColor(primary, 0.15);
    final Color primaryWithOpacity20 = Color.fromRGBO(
      primary.red,
      primary.green, 
      primary.blue,
      0.2
    );
    
    return ThemeData(
      primaryColor: primary,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: primaryLight,
        tertiary: primaryDark,  // 使用 primaryDark
        background: AppColors.backgroundLight,
        surface: AppColors.cardBackground,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      cardTheme: const CardTheme(
        color: AppColors.cardBackground,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: AppColors.textOnPrimary),
        titleMedium: TextStyle(color: AppColors.textOnPrimary),
        bodyLarge: TextStyle(color: AppColors.textOnPrimary),
        bodyMedium: TextStyle(color: AppColors.textSecondaryOnPrimary),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.textOnPrimary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonBackground,
          foregroundColor: AppColors.buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
        ),
      ),
      // 修改 switchTheme 使用动态生成的颜色
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primary;  // 使用动态的 primary 而不是常量
          }
          return null;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryWithOpacity20;  // 使用动态生成的透明色
          }
          return null;
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
      ),
      // 添加侧边栏主题设置
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: primary,
        selectedIconTheme: const IconThemeData(color: AppColors.textOnPrimary),
        unselectedIconTheme: IconThemeData(color: AppColors.textOnPrimary.withOpacity(0.7)),
        selectedLabelTextStyle: const TextStyle(color: AppColors.textOnPrimary),
        unselectedLabelTextStyle: TextStyle(color: AppColors.textOnPrimary.withOpacity(0.7)),
        indicatorColor: AppColors.textOnPrimary.withOpacity(0.2),
      ),
      // 添加底部导航栏主题
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: primary,
        selectedItemColor: AppColors.textOnPrimary,
        unselectedItemColor: AppColors.textOnPrimary.withOpacity(0.7),
      ),
    );
  }

  // 深色主题，支持自定义主色调
  static ThemeData darkTheme({Color? primaryColor}) {
    // 如果提供了自定义主色调，则使用它，否则使用默认的薰衣草紫色
    // 深色主题中
    final Color primary = primaryColor ?? AppColors.primary;
    
    // 根据主色调生成其他颜色
    final Color primaryLight = _lightenColor(primary, 0.15);
    final Color primaryDark = _darkenColor(primary, 0.15);
    final Color primaryWithOpacity20 = primary.withOpacity(0.2);
    
    return ThemeData(
      primaryColor: primary,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: primaryLight,
        tertiary: primaryDark,
        background: AppColors.backgroundDark,
        surface: AppColors.cardBackground,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      // 修改这里，使用动态的primary而不是常量
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      cardTheme: const CardTheme(
        color: AppColors.cardBackground,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: AppColors.textOnPrimary),
        titleMedium: TextStyle(color: AppColors.textOnPrimary),
        bodyLarge: TextStyle(color: AppColors.textOnPrimary),
        bodyMedium: TextStyle(color: AppColors.textSecondaryOnPrimary),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.textOnPrimary,
      ),
      // 修改按钮主题，使用动态颜色
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: AppColors.textOnPrimary,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
        ),
      ),
      // 添加导航栏主题
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: primary,
        selectedIconTheme: const IconThemeData(color: AppColors.textOnPrimary),
        unselectedIconTheme: IconThemeData(color: AppColors.textOnPrimary.withOpacity(0.7)),
        selectedLabelTextStyle: const TextStyle(color: AppColors.textOnPrimary),
        unselectedLabelTextStyle: TextStyle(color: AppColors.textOnPrimary.withOpacity(0.7)),
        indicatorColor: AppColors.textOnPrimary.withOpacity(0.38),
      ),
      // 添加浮动按钮主题
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      // 添加底部导航栏主题
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: primary,
        selectedItemColor: AppColors.textOnPrimary,
        unselectedItemColor: AppColors.textOnPrimary.withOpacity(0.7),
      ),
      // 修改开关主题，使用动态颜色
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primary;
          }
          return null;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryWithOpacity20;
          }
          return null;
        }),
      ),
      dividerTheme: DividerThemeData(
        color: primaryWithOpacity20,
      ),
    );
  }
  
  // 辅助方法：使颜色变亮
  static Color _lightenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }
  
  // 辅助方法：使颜色变暗
  static Color _darkenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }
}