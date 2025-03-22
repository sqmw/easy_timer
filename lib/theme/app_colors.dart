import 'package:flutter/material.dart';

/// 应用程序颜色主题
class AppColors {
  // 主色调 - 薰衣草紫色
  static const Color primary = Color(0xFF9683EC);
  
  // 主色调的不同透明度变体
  static const Color primaryLight = Color(0xFFB5A6F2);
  static const Color primaryDark = Color(0xFF7A68C9);
  static const Color primaryWithOpacity20 = Color(0x209683EC);
  
  // 背景色渐变
  static const Color backgroundDark = Color(0xFF1F1D36);
  static const Color backgroundLight = Color(0xFF2D2B52);
  
  // 文本颜色
  static const Color textOnPrimary = Colors.white;
  static const Color textSecondaryOnPrimary = Color(0xFFE6E1FB);
  
  // 指示器颜色
  static const Color indicatorOnPrimary = Color(0x60FFFFFF); // 白色38%透明度
  
  // 卡片颜色
  static const Color cardBackground = Color(0xFF2A2845);
  
  // 按钮颜色
  static const Color buttonBackground = primary;
  static const Color buttonText = Colors.white;
  
  // 分隔线颜色
  static const Color divider = Color(0x40FFFFFF);
  
  // 错误颜色
  static const Color error = Color(0xFFFF5252);
  
  // 成功颜色
  static const Color success = Color(0xFF4CAF50);
  
  // 警告颜色
  static const Color warning = Color(0xFFFFC107);
  
  // 信息颜色
  static const Color info = Color(0xFF2196F3);
}