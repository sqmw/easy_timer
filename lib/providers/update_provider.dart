import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateProvider extends ChangeNotifier {
  static const String _autoCheckKey = 'auto_check_update';
  static const String _lastCheckKey = 'last_check_time';
  
  String _currentVersion = '0.1.0';
  String _latestVersion = '0.1.0';
  bool _updateAvailable = false;
  bool _autoCheckEnabled = true;
  bool _isChecking = false;
  String _releaseUrl = '';
  String _releaseNotes = '';

  UpdateProvider() {
    _initialize();
  }

  String get currentVersion => _currentVersion;
  String get latestVersion => _latestVersion;
  bool get updateAvailable => _updateAvailable;
  bool get autoCheckEnabled => _autoCheckEnabled;
  bool get isChecking => _isChecking;
  String get releaseNotes => _releaseNotes;

  Future<void> _initialize() async {
    // 获取当前版本
    final packageInfo = await PackageInfo.fromPlatform();
    _currentVersion = packageInfo.version;
    
    // 加载自动检查设置
    final prefs = await SharedPreferences.getInstance();
    _autoCheckEnabled = prefs.getBool(_autoCheckKey) ?? true;
    
    // 如果启用了自动检查，且上次检查时间超过24小时，则检查更新
    if (_autoCheckEnabled) {
      final lastCheck = prefs.getInt(_lastCheckKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      if (now - lastCheck > const Duration(hours: 24).inMilliseconds) {
        checkForUpdates();
      }
    }
    
    notifyListeners();
  }

  Future<void> setAutoCheckEnabled(bool enabled) async {
    if (_autoCheckEnabled == enabled) return;
    
    _autoCheckEnabled = enabled;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoCheckKey, enabled);
    
    notifyListeners();
  }

  Future<void> checkForUpdates() async {
    if (_isChecking) return;
    
    _isChecking = true;
    notifyListeners();
    
    try {
      // 记录检查时间
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastCheckKey, DateTime.now().millisecondsSinceEpoch);
      
      // 模拟从服务器获取最新版本信息
      // 实际应用中，这里应该是一个真实的API调用
      await Future.delayed(const Duration(seconds: 1));
      
      // 这里仅作演示，实际应用中应该从服务器获取
      final response = await http.get(
        Uri.parse('https://api.github.com/repos/sqmw/easy_timer/releases/latest'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _latestVersion = data['tag_name'] ?? '0.1.0';
        _releaseUrl = data['html_url'] ?? '';
        _releaseNotes = data['body'] ?? '无更新说明';
        
        // 比较版本号
        _updateAvailable = _compareVersions(_latestVersion, _currentVersion) > 0;
      }
    } catch (e) {
      debugPrint('检查更新失败: $e');
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  int _compareVersions(String v1, String v2) {
    final List<int> version1 = v1.split('.').map(int.parse).toList();
    final List<int> version2 = v2.split('.').map(int.parse).toList();
    
    for (int i = 0; i < version1.length && i < version2.length; i++) {
      if (version1[i] > version2[i]) {
        return 1;
      } else if (version1[i] < version2[i]) {
        return -1;
      }
    }
    
    return version1.length.compareTo(version2.length);
  }

  Future<void> startUpdate() async {
    if (!_updateAvailable || _releaseUrl.isEmpty) return;
    
    final Uri url = Uri.parse(_releaseUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}