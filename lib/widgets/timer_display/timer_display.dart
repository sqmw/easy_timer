import 'package:flutter/material.dart';

class TimerDisplay extends StatelessWidget {
  final Duration remainingTime;
  final double progress;
  final bool isFullScreen;
  final VoidCallback? onToggleFullScreen;

  const TimerDisplay({
    super.key,
    required this.remainingTime,
    required this.progress,
    this.isFullScreen = false,
    this.onToggleFullScreen,
  });

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 上方数字倒计时
              DigitalTimerDisplay(
                remainingTime: remainingTime,
                isFullScreen: isFullScreen,
              ),
              const SizedBox(height: 32),
              // 下方图形化倒计时，占据更多空间
              Expanded(
                flex: 3,
                child: GraphicalTimerDisplay(
                  progress: progress,
                  isFullScreen: isFullScreen,
                ),
              ),
            ],
          ),
          // 右上角全屏按钮
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: Icon(
                isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                size: 28,
              ),
              onPressed: onToggleFullScreen,
            ),
          ),
        ],
      ),
    );
  }
}

// 数字倒计时显示
class DigitalTimerDisplay extends StatelessWidget {
  final Duration remainingTime;
  final bool isFullScreen;

  const DigitalTimerDisplay({
    super.key,
    required this.remainingTime,
    required this.isFullScreen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = remainingTime.inDays;
    final hours = remainingTime.inHours.remainder(24);
    final minutes = remainingTime.inMinutes.remainder(60);
    final seconds = remainingTime.inSeconds.remainder(60);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTimeUnit('Days', days, isFullScreen),
            _buildSeparator(':'),
            _buildTimeUnit('Hours', hours, isFullScreen),
            _buildSeparator(':'),
            _buildTimeUnit('Minutes', minutes, isFullScreen),
            _buildSeparator(':'),
            _buildTimeUnit('Seconds', seconds, isFullScreen),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeUnit(String label, int value, bool isFullScreen) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isFullScreen ? 16 : 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            style: TextStyle(
              fontSize: isFullScreen ? 48 : 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeparator(String separator) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        separator,
        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// 图形化倒计时显示
class GraphicalTimerDisplay extends StatelessWidget {
  final double progress;
  final bool isFullScreen;
  final VoidCallback? onToggleFullScreen;

  const GraphicalTimerDisplay({
    super.key,
    required this.progress,
    required this.isFullScreen,
    this.onToggleFullScreen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = isFullScreen ? 300.0 : 200.0;

    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        value: progress,
        strokeWidth: isFullScreen ? 12 : 8,
        backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
        color: theme.colorScheme.primary,
      ),
    );
  }
}
