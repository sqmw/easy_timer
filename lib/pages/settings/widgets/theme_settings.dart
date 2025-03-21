import 'package:flutter/material.dart';
import 'package:easy_timer/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class ThemeSettings extends StatelessWidget {
  const ThemeSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '主题设置',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _buildThemeModeSection(context),
            const Divider(color: Colors.white24),
            _buildThemeStyleSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeModeSection(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '色调模式',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment<ThemeMode>(
              value: ThemeMode.light,
              label: Text('明亮'),
              icon: Icon(Icons.light_mode),
            ),
            ButtonSegment<ThemeMode>(
              value: ThemeMode.dark,
              label: Text('暗黑'),
              icon: Icon(Icons.dark_mode),
            ),
          ],
          selected: {themeProvider.themeMode},
          onSelectionChanged: (Set<ThemeMode> selected) {
            themeProvider.setThemeMode(selected.first);
          },
        ),
      ],
    );
  }

  Widget _buildThemeStyleSection(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '应用风格',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: ThemeStyle.values.map((style) {
            return ChoiceChip(
              label: Text(style.displayName),
              selected: themeProvider.themeStyle == style,
              onSelected: (bool selected) {
                if (selected) {
                  themeProvider.setThemeStyle(style);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}