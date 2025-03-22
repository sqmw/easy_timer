import 'package:easy_timer/widgets/timer_display/timer_display.dart';
import 'package:easy_timer/widgets/timer_display/flip_timer_display.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_timer/providers/timer_provider.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({Key? key}) : super(key: key);

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  bool _isFullScreen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 使用新的翻转式倒计时
                FlipTimerDisplay(
                  remainingTime: const Duration(days: 1, hours: 21, minutes: 34, seconds: 26),
                  isFullScreen: _isFullScreen,
                ),
                const SizedBox(height: 32),
                // 图形化倒计时
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    height: 200,
                    child: CircularProgressIndicator(
                      value: 0.75,
                      strokeWidth: 8,
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      color: Theme.of(context).colorScheme.primary,
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
