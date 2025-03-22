import 'package:easy_timer/providers/timer_provider.dart';
import 'package:flutter/material.dart';
import 'package:easy_timer/models/timer_item.dart';
import 'package:provider/provider.dart';

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
  // 在计时器列表项中添加开始时间显示
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timerProvider = Provider.of<TimerProvider>(context);
    
    // 格式化时间显示
    final hours = timer.duration.inHours;
    final minutes = timer.duration.inMinutes % 60;
    final seconds = timer.duration.inSeconds % 60;
    final timeString = '${hours > 0 ? '$hours小时 ' : ''}${minutes > 0 ? '$minutes分钟 ' : ''}${seconds > 0 ? '$seconds秒' : ''}';
    
    // 计算并显示计时器状态
    Widget statusWidget = const SizedBox.shrink();
    
    // 检查是否是活动计时器
    final isActive = timerProvider.activeTimer?.id == timer.id;
    
    // 检查开始时间
    if (timer.startTime != null) {
      final now = DateTime.now();
      final startTime = timer.startTime!;
      
      if (isActive) {
        // 如果是活动计时器
        if (timerProvider.isRunning) {
          statusWidget = _buildStatusChip('运行中', Colors.green);
        } else if (timerProvider.isPaused) {
          statusWidget = _buildStatusChip('已暂停', Colors.orange);
        } else if (timerProvider.isCompleted) {
          statusWidget = _buildStatusChip('已完成', Colors.blue);
        }
      } else if (startTime.isAfter(now)) {
        // 计算还有多久开始
        final difference = startTime.difference(now);
        String timeToStart;
        
        if (difference.inDays > 0) {
          timeToStart = '${difference.inDays}天后';
        } else if (difference.inHours > 0) {
          timeToStart = '${difference.inHours}小时后';
        } else if (difference.inMinutes > 0) {
          timeToStart = '${difference.inMinutes}分钟后';
        } else {
          timeToStart = '即将开始';
        }
        
        statusWidget = _buildStatusChip('$timeToStart', Colors.amber);
      } else if (timer.isAutoStart) {
        // 已过开始时间但未启动
        statusWidget = _buildStatusChip('未启动', Colors.red);
      }
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        title: Row(
          children: [
            Expanded(child: Text(timer.name, style: theme.textTheme.titleMedium)),
            statusWidget, // 在这里使用状态标签
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('时长: $timeString'),
            if (timer.isAutoStart && timer.startTime != null)
              Text('开始时间: ${_formatDateTime(timer.startTime!)}', 
                  style: TextStyle(color: theme.colorScheme.primary)),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }
  
  // 辅助方法：创建状态标签
  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  // 辅助方法：格式化日期时间
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    
    if (dateTime.year == now.year && 
        dateTime.month == now.month && 
        dateTime.day == now.day) {
      // 如果是今天，只显示时间
      return '今天 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (dateTime.year == now.year) {
      // 如果是今年，显示月日时间
      return '${dateTime.month}月${dateTime.day}日 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      // 其他情况显示完整日期
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}