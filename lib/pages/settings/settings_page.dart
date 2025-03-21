import 'package:flutter/material.dart';
import 'package:easy_timer/pages/settings/widgets/theme_settings.dart';
import 'package:easy_timer/pages/settings/widgets/language_settings.dart';
import 'package:easy_timer/pages/settings/widgets/notification_settings.dart';
import 'package:easy_timer/pages/settings/widgets/update_settings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ListView(
        children: [
          const Text(
            '设置',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          const ThemeSettings(),
          const SizedBox(height: 24),
          const LanguageSettings(),
          const SizedBox(height: 24),
          const NotificationSettings(),
          const SizedBox(height: 24),
          const UpdateSettings(),
        ],
      ),
    );
  }
}