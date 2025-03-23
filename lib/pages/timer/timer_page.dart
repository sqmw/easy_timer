// 将原来的 CircularProgress 替换为 TimerGraphContainer
import 'package:easy_timer/widgets/timer_display/timer_graph/circular_graph.dart';
import 'package:easy_timer/widgets/timer_display/flip_timer_display.dart';
import 'package:flutter/material.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  bool _isFullScreen = false;

  String _formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    final parts = <String>[];
    if (days > 0) parts.add('$days天');
    if (hours > 0) parts.add('$hours小时');
    if (minutes > 0) parts.add('$minutes分钟');
    if (seconds > 0) parts.add('$seconds秒');
    
    return parts.isEmpty ? '0秒' : parts.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remainingTime = const Duration(minutes: 1);
    final totalTime = const Duration(minutes: 1);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // 计算合适的尺寸
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;
          final minDimension = screenWidth < screenHeight ? screenWidth : screenHeight;

          // 计算各组件的大小
          final graphSize = minDimension * 0.5;
          final spacing = minDimension * 0.03;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '总时长: ${_formatDuration(totalTime)}',
                  style: TextStyle(
                    fontSize: minDimension * 0.04,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: spacing),
                FlipTimerDisplay(
                  remainingTime: remainingTime,
                  isFullScreen: _isFullScreen,
                ),
                SizedBox(height: spacing * 2),
                SizedBox(
                  width: graphSize,
                  height: graphSize,
                  child: CircularGraph(
                    remainingTime: remainingTime,
                    totalTime: totalTime,
                    size: graphSize,
                  ),
                ),
                SizedBox(height: spacing * 2),
                // 示例按钮 - 你可以根据需要添加更多按钮
                Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('开始'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                      ),
                      onPressed: () {
                        // 添加开始逻辑
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      // 将全屏按钮移到 AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
              size: 28,
            ),
            onPressed: () {
              setState(() {
                _isFullScreen = !_isFullScreen;
              });
            },
          ),
        ],
      ),
    );
  }
}
