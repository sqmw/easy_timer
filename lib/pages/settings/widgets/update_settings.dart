import 'package:flutter/material.dart';
import 'package:easy_timer/providers/update_provider.dart';
import 'package:provider/provider.dart';

class UpdateSettings extends StatelessWidget {
  const UpdateSettings({super.key});

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
              '软件更新',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Consumer<UpdateProvider>(
              builder: (context, provider, child) {
                return Column(
                  children: [
                    ListTile(
                      title: const Text(
                        '当前版本',
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        provider.currentVersion,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                    if (provider.updateAvailable)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () => provider.startUpdate(),
                          child: const Text('立即更新'),
                        ),
                      ),
                    SwitchListTile(
                      title: const Text(
                        '自动检查更新',
                        style: TextStyle(color: Colors.white),
                      ),
                      value: provider.autoCheckEnabled,
                      onChanged: (bool value) {
                        provider.setAutoCheckEnabled(value);
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}