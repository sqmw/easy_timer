import 'package:flutter/material.dart';
import 'package:easy_timer/models/timer_item.dart';

class TimerListItem extends StatelessWidget {
  final TimerItem timer;
  final String startModeText; // 添加启动模式文案参数
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TimerListItem({
    super.key,
    required this.timer,
    this.startModeText = '手动启动', // 默认为手动启动
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // 格式化时间显示
    final hours = timer.duration.inHours;
    final minutes = timer.duration.inMinutes % 60;
    final seconds = timer.duration.inSeconds % 60;
    
    String durationText = '';
    if (hours > 0) {
      durationText += '$hours小时';
    }
    if (minutes > 0 || (hours > 0 && seconds > 0)) {
      durationText += '$minutes分钟';
    }
    if (seconds > 0 || durationText.isEmpty) {
      durationText += '$seconds秒';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.timer),
        title: Text(timer.name),
        subtitle: Text(
          '$durationText · $startModeText', // 使用传入的启动模式文案
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
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