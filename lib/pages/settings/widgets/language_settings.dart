import 'package:flutter/material.dart';
import 'package:easy_timer/providers/locale_provider.dart';
import 'package:provider/provider.dart';

class LanguageSettings extends StatelessWidget {
  const LanguageSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '语言设置',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Consumer<LocaleProvider>(
              builder: (context, provider, child) {
                return DropdownButton<Locale>(
                  value: provider.locale,
                  dropdownColor: Colors.grey[850],
                  items: [
                    DropdownMenuItem(
                      value: const Locale('zh', 'CN'),
                      child: const Text(
                        '简体中文',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    DropdownMenuItem(
                      value: const Locale('en', 'US'),
                      child: const Text(
                        'English',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                  onChanged: (Locale? newLocale) {
                    if (newLocale != null) {
                      provider.setLocale(newLocale);
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}