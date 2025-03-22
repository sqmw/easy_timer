import 'package:flutter/material.dart';
import 'package:easy_timer/models/timer_item.dart';

class TimerListItem extends StatelessWidget {
  final TimerItem timer;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TimerListItem({
    super.key,
    required this.timer,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.timer),
        title: Text(timer.name),
        subtitle: Text(
          '${timer.duration.inMinutes}分钟 · ${timer.isAutoStart ? "自动" : "手动"}启动',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }
}