import 'package:easy_timer/providers/timer_provider.dart';
import 'package:flutter/material.dart';
import 'package:easy_timer/models/timer_item.dart';
import 'package:provider/provider.dart';

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
  // 在计时器列表项中添加开始时间显示
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 格式化时间显示
    final hours = timer.duration.inHours;
    final minutes = timer.duration.inMinutes % 60;
    final seconds = timer.duration.inSeconds % 60;
    final timeString =
        '${hours > 0 ? '$hours小时 ' : ''}${minutes > 0 ? '$minutes分钟 ' : ''}${seconds > 0 ? '$seconds秒' : ''}';

    // 计算并显示计时器状态
    Widget statusWidget = const SizedBox.shrink();

    // 检查开始时间
    if (timer.isEnabled) {
      // 修改条件判断
      // 只有启用的计时器才会显示状态
      if (timer.startTime != null) {
        final now = DateTime.now();
        final startTime = timer.startTime!;

        if (startTime.isAfter(now)) {
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
            timeToStart = '${difference.inSeconds}秒后'; // 修改为显示秒数
          }

          statusWidget = _buildStatusChip('$timeToStart', Colors.amber);
        } else {
          // 已过开始时间但未启动
          statusWidget = _buildStatusChip('已过期', Colors.red); // 修改文案
        }
      } else {
        // 启用但没有开始时间的计时器
        statusWidget = _buildStatusChip('已启用', Colors.teal);
      }
    } else {
      // 未启用的计时器
      statusWidget = _buildStatusChip('未启用', Colors.grey);
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        title: Row(
          children: [
            Expanded(
              child: Text(timer.name, style: theme.textTheme.titleMedium),
            ),
            // 将状态标签改为可点击的组件
            statusWidget,
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('时长: $timeString'),
            if (timer.isEnabled && timer.startTime != null)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '开始时间: ${_formatDateTime(timer.startTime!)}',
                      style: TextStyle(color: theme.colorScheme.primary),
                    ),
                  ),
                  // 添加一个刷新按钮，用于手动刷新状态显示
                  if (timer.startTime!.isAfter(DateTime.now()))
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 16),
                      onPressed: () {
                        // 使用 Provider 强制刷新
                        Provider.of<TimerProvider>(
                          context,
                          listen: false,
                        ).notifyListeners();
                      },
                      tooltip: '刷新倒计时',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 启用/禁用开关
            Switch(
                value: timer.isEnabled,
                onChanged: (value) {
                  // 需要在 timer_list_page.dart 中添加 onEnabledChanged 回调
                  Provider.of<TimerProvider>(
                      context,
                      listen: false,
                    ).updateTimer(timer.copyWith(isEnabled: value));
                },
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  // 辅助方法：创建状态标签
  // 修改状态标签样式，使其看起来更像按钮
  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
        // 添加轻微的阴影效果，使其看起来更像按钮
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
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
