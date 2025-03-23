import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class AppConfig extends ChangeNotifier {
  // 单例模式
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  // 配置数据
  Map<String, dynamic> _configData = {};
  
  // 配置文件名
  static const String _configFileName = 'easy_timer_config.json';

  // 获取配置文件路径
  Future<String> get _configFilePath async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$_configFileName';
  }

  // 初始化配置
  Future<void> init() async {
    try {
      final path = await _configFilePath;
      debugPrint('配置文件路径: $path'); // 添加这行来打印路径
      final file = File(path);
      
      // 检查文件是否存在
      if (await file.exists()) {
        // 读取配置文件
        final jsonString = await file.readAsString();
        _configData = jsonDecode(jsonString);
      } else {
        // 创建默认配置
        _configData = _getDefaultConfig();
        await _saveConfig();
      }
    } catch (e) {
      debugPrint('配置初始化错误: $e');
      // 使用默认配置
      _configData = _getDefaultConfig();
    }
  }

  // 获取默认配置
  Map<String, dynamic> _getDefaultConfig() {
    return {
      'theme': 'system', // system, light, dark
      'notification': {
        'sound': true,
        'vibration': true,
        'defaultSoundId': 'default_sound',
      },
      'timer': {
        'defaultDuration': 1800, // 默认30分钟
        'autoStart': true,
        'reminderTime': 10, // 提前10秒提醒
      },
      'display': {
        'showSeconds': true,
        'use24HourFormat': true,
      },
    };
  }

  // 保存配置到文件
  Future<void> _saveConfig() async {
    try {
      final path = await _configFilePath;
      final file = File(path);
      final jsonString = jsonEncode(_configData);
      await file.writeAsString(jsonString);
    } catch (e) {
      debugPrint('保存配置错误: $e');
    }
  }

  // 获取配置值
  T? getValue<T>(String key, [T? defaultValue]) {
    final keys = key.split('.');
    dynamic value = _configData;
    
    for (final k in keys) {
      if (value is Map && value.containsKey(k)) {
        value = value[k];
      } else {
        return defaultValue;
      }
    }
    
    return (value is T) ? value : defaultValue;
  }

  // 设置配置值
  Future<void> setValue<T>(String key, T value) async {
    final keys = key.split('.');
    Map<String, dynamic> current = _configData;
    
    // 遍历嵌套键，直到最后一个键
    for (int i = 0; i < keys.length - 1; i++) {
      final k = keys[i];
      if (!current.containsKey(k) || current[k] is! Map) {
        current[k] = <String, dynamic>{};
      }
      current = current[k] as Map<String, dynamic>;
    }
    
    // 设置最后一个键的值
    current[keys.last] = value;
    
    // 保存配置并通知监听器
    await _saveConfig();
    notifyListeners();
  }
}