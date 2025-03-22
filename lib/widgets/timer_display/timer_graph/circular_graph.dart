import 'dart:math';
import 'package:flutter/material.dart';
import 'base_timer_graph.dart';

enum CircularDisplayMode {
  pie,
  ring,
}

class CircularGraph extends BaseTimerGraph {
  final double strokeWidth;
  final bool clockwise;
  final Gradient? gradient;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CircularGraph({
    super.key,
    required super.remainingTime,
    required super.totalTime,
    required super.size,
    this.strokeWidth = 8,
    this.clockwise = true,
    this.gradient,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  State<CircularGraph> createState() => _CircularGraphState();
}

class _CircularGraphState extends BaseTimerGraphState<CircularGraph> {
  CircularDisplayMode _displayMode = CircularDisplayMode.ring;

  void _toggleDisplayMode() {
    setState(() {
      _displayMode = _displayMode == CircularDisplayMode.ring
          ? CircularDisplayMode.pie
          : CircularDisplayMode.ring;
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = 1 - (currentTime.inSeconds / widget.totalTime.inSeconds);
    
    return GestureDetector(
      onDoubleTap: _toggleDisplayMode,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: CircularGraphPainter(
            progress: progress.clamp(0.0, 1.0),
            strokeWidth: widget.strokeWidth,
            clockwise: widget.clockwise,
            gradient: widget.gradient,
            backgroundColor: widget.backgroundColor ?? Theme.of(context).colorScheme.primary.withOpacity(0.2),
            foregroundColor: widget.foregroundColor ?? Theme.of(context).colorScheme.primary,
            displayMode: _displayMode,
          ),
        ),
      ),
    );
  }
}

class CircularGraphPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final bool clockwise;
  final Gradient? gradient;
  final Color backgroundColor;
  final Color foregroundColor;
  final CircularDisplayMode displayMode;

  CircularGraphPainter({
    required this.progress,
    required this.strokeWidth,
    required this.clockwise,
    required this.displayMode,
    this.gradient,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scale = 0.4;  // 添加缩放比例
    final scaledSize = size.width * scale;
    final offset = (size.width - scaledSize) / 2;
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = displayMode == CircularDisplayMode.pie
        ? scaledSize / 2
        : (scaledSize - strokeWidth) / 2;
    
    final isPieMode = displayMode == CircularDisplayMode.pie;
    
    // 绘制背景
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = isPieMode ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = isPieMode ? 0 : strokeWidth
      ..strokeCap = isPieMode ? StrokeCap.butt : StrokeCap.round;
    
    canvas.drawCircle(center, radius, bgPaint);

    // 创建前景画笔
    final fgPaint = Paint()
      ..style = isPieMode ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = isPieMode ? 0 : strokeWidth
      ..strokeCap = isPieMode ? StrokeCap.butt : StrokeCap.round;

    if (gradient != null) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      fgPaint.shader = gradient!.createShader(rect);
    } else {
      fgPaint.color = foregroundColor;
    }

    // 计算起始角度和扫描角度
    const startAngle = -90.0 * (pi / 180.0);
    final sweepAngle = 2 * pi * progress * (clockwise ? 1 : -1);

    // 绘制进度
    // 绘制进度时使用缩放后的半径
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      isPieMode,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CircularGraphPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.clockwise != clockwise ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.foregroundColor != foregroundColor ||
        oldDelegate.displayMode != displayMode;
  }
}