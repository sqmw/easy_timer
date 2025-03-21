import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('zh', 'CN');
  static const String _localeKey = 'app_locale';

  LocaleProvider() {
    _loadSavedLocale();
  }

  Locale get locale => _locale;

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('${_localeKey}_language') ?? 'zh';
    final countryCode = prefs.getString('${_localeKey}_country') ?? 'CN';
    
    _locale = Locale(languageCode, countryCode);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    
    _locale = locale;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_localeKey}_language', locale.languageCode);
    await prefs.setString('${_localeKey}_country', locale.countryCode ?? '');
    
    notifyListeners();
  }

  List<Locale> get supportedLocales => const [
    Locale('zh', 'CN'),
    Locale('en', 'US'),
  ];

  String getDisplayLanguage(Locale locale) {
    switch ('${locale.languageCode}_${locale.countryCode}') {
      case 'zh_CN':
        return '简体中文';
      case 'en_US':
        return 'English';
      default:
        return locale.toString();
    }
  }
}