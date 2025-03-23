import 'package:flutter/material.dart';
import 'package:easy_timer/config/app_config.dart';

class ConfigProvider extends ChangeNotifier {
  final AppConfig _config = AppConfig();
  
  // 初始化
  Future<void> init() async {
    await _config.init();
    notifyListeners();
  }
  
  // 获取主题模式
  ThemeMode get themeMode {
    final theme = _config.getValue<String>('theme', 'system');
    switch (theme) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
  
  // 设置主题模式
  Future<void> setThemeMode(ThemeMode mode) async {
    String themeValue;
    switch (mode) {
      case ThemeMode.light:
        themeValue = 'light';
        break;
      case ThemeMode.dark:
        themeValue = 'dark';
        break;
      default:
        themeValue = 'system';
    }
    
    await _config.setValue('theme', themeValue);
    notifyListeners();
  }
  
  // 获取通知声音设置
  bool? get notificationSound => 
      _config.getValue<bool>('notification.sound', true);
  
  // 设置通知声音
  Future<void> setNotificationSound(bool enabled) async {
    await _config.setValue('notification.sound', enabled);
    notifyListeners();
  }
  
  // 获取振动设置
  bool? get vibration => 
      _config.getValue<bool>('notification.vibration', true);
  
  // 设置振动
  Future<void> setVibration(bool enabled) async {
    await _config.setValue('notification.vibration', enabled);
    notifyListeners();
  }
  
  // 获取默认声音ID
  String? get defaultSoundId => 
      _config.getValue<String>('notification.defaultSoundId', 'default_sound');
  
  // 设置默认声音ID
  Future<void> setDefaultSoundId(String soundId) async {
    await _config.setValue('notification.defaultSoundId', soundId);
    notifyListeners();
  }
  
  // 获取默认计时器时长（秒）
  int? get defaultTimerDuration => 
      _config.getValue<int>('timer.defaultDuration', 1800);
  
  // 设置默认计时器时长
  Future<void> setDefaultTimerDuration(int seconds) async {
    await _config.setValue('timer.defaultDuration', seconds);
    notifyListeners();
  }
  
  // 获取自动启动设置
  bool? get autoStart => 
      _config.getValue<bool>('timer.autoStart', true);
  
  // 设置自动启动
  Future<void> setAutoStart(bool enabled) async {
    await _config.setValue('timer.autoStart', enabled);
    notifyListeners();
  }
  
  // 获取提醒时间（秒）
  int? get reminderTime => 
      _config.getValue<int>('timer.reminderTime', 10);
  
  // 设置提醒时间
  Future<void> setReminderTime(int seconds) async {
    await _config.setValue('timer.reminderTime', seconds);
    notifyListeners();
  }
  
  // 显示秒数设置
  bool? get showSeconds => 
      _config.getValue<bool>('display.showSeconds', true);
  
  // 设置显示秒数
  Future<void> setShowSeconds(bool show) async {
    await _config.setValue('display.showSeconds', show);
    notifyListeners();
  }
  
  // 24小时制设置
  bool? get use24HourFormat => 
      _config.getValue<bool>('display.use24HourFormat', true);
  
  // 设置24小时制
  Future<void> setUse24HourFormat(bool use24Hour) async {
    await _config.setValue('display.use24HourFormat', use24Hour);
    notifyListeners();
  }
}