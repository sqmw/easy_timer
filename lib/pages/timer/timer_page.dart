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
    // 修改初始时间设置
    final remainingTime = const Duration(minutes: 1);
    final totalTime = const Duration(minutes: 1);

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 添加总时长显示
                Text(
                  '总时长: ${_formatDuration(totalTime)}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                FlipTimerDisplay(
                  remainingTime: remainingTime,
                  isFullScreen: _isFullScreen,
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    height: 300,
                    child: CircularGraph(
                      remainingTime: remainingTime,
                      totalTime: totalTime,
                      size: 300,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 右上角全屏按钮
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: Icon(
                _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                size: 28,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _isFullScreen = !_isFullScreen;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
