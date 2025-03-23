import 'package:easy_timer/models/timer_item.dart';
import 'package:easy_timer/providers/timer_provider.dart';
import 'package:easy_timer/widgets/timer_display/flip_timer_display.dart';
import 'package:easy_timer/widgets/timer_display/timer_graph/circular_graph.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TimerDetailPage extends StatefulWidget {
  final TimerItem timer;

  const TimerDetailPage({super.key, required this.timer});

  @override
  State<TimerDetailPage> createState() => _TimerDetailPageState();
}

class _TimerDetailPageState extends State<TimerDetailPage> {
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
    final timerProvider = Provider.of<TimerProvider>(context);

    // 检查当前计时器是否是活动计时器
    final isActiveTimer = timerProvider.activeTimer?.id == widget.timer.id;

    // 获取剩余时间和总时间
    final Duration remainingTime =
        isActiveTimer ? timerProvider.remainingTime : widget.timer.duration;

    final Duration totalTime = widget.timer.duration;

    // 获取计时器状态
    final bool isRunning = isActiveTimer && timerProvider.isRunning;
    final bool isPaused = isActiveTimer && timerProvider.isPaused;
    final bool isCompleted = isActiveTimer && timerProvider.isCompleted;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.timer.name),
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
      body: SafeArea(  // 添加 SafeArea 避免系统区域遮挡
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 计算合适的尺寸
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;
            final minDimension =
                screenWidth < screenHeight ? screenWidth : screenHeight;

            // 计算各组件的大小 - 减小尺寸以避免溢出
            final graphSize = minDimension * 0.4; // 减小图表尺寸
            final spacing = minDimension * 0.02; // 减小间距

            return SingleChildScrollView(  // 添加滚动视图防止溢出
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 添加总时长显示
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
                      // 控制按钮 - 使用 Wrap 优化按钮布局
                      Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        alignment: WrapAlignment.center,
                        children: [
                          if (!isRunning && !isCompleted)
                            ElevatedButton.icon(
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('开始'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                              ),
                              onPressed: () {
                                timerProvider.startTimer(widget.timer.id);
                              },
                            ),
                          if (isRunning)
                            ElevatedButton.icon(
                              icon: const Icon(Icons.pause),
                              label: const Text('暂停'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                              ),
                              onPressed: () {
                                timerProvider.pauseTimer();
                              },
                            ),
                          if (isPaused)
                            ElevatedButton.icon(
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('继续'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                              ),
                              onPressed: () {
                                timerProvider.resumeTimer();
                              },
                            ),
                          if (isRunning || isPaused)
                            ElevatedButton.icon(
                              icon: const Icon(Icons.stop),
                              label: const Text('停止'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.error,
                                foregroundColor: theme.colorScheme.onError,
                              ),
                              onPressed: () {
                                timerProvider.stopTimer();
                              },
                            ),
                          if (isPaused)
                            ElevatedButton.icon(
                              icon: const Icon(Icons.refresh),
                              label: const Text('重置'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.secondary,
                                foregroundColor: theme.colorScheme.onSecondary,
                              ),
                              onPressed: () {
                                timerProvider.resetTimer();
                              },
                            ),
                          if (isCompleted)
                            ElevatedButton.icon(
                              icon: const Icon(Icons.refresh),
                              label: const Text('重新开始'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                              ),
                              onPressed: () {
                                timerProvider.resetTimer();
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
