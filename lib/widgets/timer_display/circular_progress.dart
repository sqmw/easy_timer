import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class CircularProgress extends StatefulWidget {
  final Duration remainingTime;
  final Duration totalTime;
  final double size;
  final double strokeWidth;
  final bool clockwise;
  final Gradient? gradient;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CircularProgress({
    super.key,
    required this.remainingTime,
    required this.totalTime,
    this.size = 200,
    this.strokeWidth = 8,
    this.clockwise = true,
    this.gradient,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  State<CircularProgress> createState() => _CircularProgressState();
}

class _CircularProgressState extends State<CircularProgress> {
  late Timer _timer;
  late Duration _currentTime;
  bool _isPieMode = false;  // 添加显示模式状态

  @override
  void initState() {
    super.initState();
    _currentTime = widget.remainingTime;
    _startTimer();
  }

  @override
  void didUpdateWidget(CircularProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.remainingTime != widget.remainingTime) {
      _currentTime = widget.remainingTime;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentTime.inSeconds > 0) {
        setState(() {
          _currentTime = _currentTime - const Duration(seconds: 1);
        });
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = 1 - (_currentTime.inSeconds / widget.totalTime.inSeconds);
    
    return GestureDetector(
      onDoubleTap: () {
        setState(() {
          _isPieMode = !_isPieMode;
        });
      },
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: PieProgressPainter(
            progress: progress.clamp(0.0, 1.0),
            strokeWidth: widget.strokeWidth,
            clockwise: widget.clockwise,
            gradient: widget.gradient,
            backgroundColor: widget.backgroundColor ?? Theme.of(context).colorScheme.primary.withOpacity(0.2),
            foregroundColor: widget.foregroundColor ?? Theme.of(context).colorScheme.primary,
            isPieMode: _isPieMode,
          ),
        ),
      ),
    );
  }
}

class PieProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final bool clockwise;
  final Gradient? gradient;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool isPieMode;

  PieProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.clockwise,
    required this.isPieMode,
    this.gradient,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = isPieMode ? size.width / 2 : (size.width - strokeWidth) / 2;
    
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
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      isPieMode,  // 根据模式决定是否填充
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant PieProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.clockwise != clockwise ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.foregroundColor != foregroundColor ||
        oldDelegate.isPieMode != isPieMode;
  }
}