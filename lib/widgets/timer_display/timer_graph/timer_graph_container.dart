import 'package:flutter/material.dart';
import 'circular_graph.dart';
import 'hourglass_graph.dart';

enum TimerGraphType { circular, hourglass }

class TimerGraphContainer extends StatefulWidget {
  final Duration remainingTime;
  final Duration totalTime;
  final double size;
  final Color? color;
  final TimerGraphType initialType;

  const TimerGraphContainer({
    super.key,
    required this.remainingTime,
    required this.totalTime,
    this.size = 200,
    this.color,
    this.initialType = TimerGraphType.circular,
  });

  @override
  State<TimerGraphContainer> createState() => _TimerGraphContainerState();
}

class _TimerGraphContainerState extends State<TimerGraphContainer> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialType.index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // 如果不需要在页面切换时执行任何操作，可以完全移除 _onPageChanged 方法
  // 并在 PageView 中移除 onPageChanged 属性

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          // 向右滑动，显示上一个
          _pageController.previousPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else if (details.primaryVelocity! < 0) {
          // 向左滑动，显示下一个
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
      child: PageView(
        controller: _pageController,
        // 移除 onPageChanged 属性
        physics: const NeverScrollableScrollPhysics(),
        children: [
          HourglassGraph(
            remainingTime: widget.remainingTime,
            totalTime: widget.totalTime,
            size: widget.size,
            color: widget.color,
          ),
          CircularGraph(
            remainingTime: widget.remainingTime,
            totalTime: widget.totalTime,
            size: widget.size,
            foregroundColor: widget.color,
          ),
        ],
      ),
    );
  }
}
