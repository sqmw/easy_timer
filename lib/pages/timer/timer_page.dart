import 'package:easy_timer/widgets/timer_display/timer_display.dart';
import 'package:flutter/material.dart';

class TimerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TimerDisplay(
          remainingTime: const Duration(days: 1, hours: 23, minutes: 59, seconds: 47),
          progress: 0.75,
          onToggleFullScreen: () {
            // 处理全屏切换
          },
        ),
      ),
    );
  }
}
