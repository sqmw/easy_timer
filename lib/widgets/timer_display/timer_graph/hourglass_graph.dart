import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'base_timer_graph.dart';

class HourglassGraph extends BaseTimerGraph {
  final Color? color;

  const HourglassGraph({
    super.key,
    required super.remainingTime,
    required super.totalTime,
    required super.size,
    this.color,
  });

  @override
  State<HourglassGraph> createState() => _HourglassGraphState();
}

class _HourglassGraphState extends BaseTimerGraphState<HourglassGraph> {
  // 添加动画计时器和随机数生成器
  late Timer _animationTimer;
  final _random = math.Random();
  int _animationSeed = 0;
  
  @override
  void initState() {
    super.initState();
    // 启动动画计时器，每秒刷新一次
    _startAnimationTimer();
  }
  
  void _startAnimationTimer() {
    _animationTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        // 更新动画种子值，触发重绘
        _animationSeed = _random.nextInt(1000);
      });
    });
  }
  
  @override
  void dispose() {
    _animationTimer.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final progress = 1 - (currentTime.inSeconds / widget.totalTime.inSeconds);
    
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CustomPaint(
        painter: HourglassGraphPainter(
          progress: progress.clamp(0.0, 1.0),
          color: widget.color ?? Theme.of(context).colorScheme.primary,
          animationSeed: _animationSeed, // 传递动画种子
        ),
      ),
    );
  }
}

class HourglassGraphPainter extends CustomPainter {
  final double progress;
  final Color color;
  final int animationSeed; // 添加动画种子参数

  HourglassGraphPainter({
    required this.progress,
    required this.color,
    required this.animationSeed, // 接收动画种子
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 创建随机数生成器，使用动画种子
    final random = math.Random(animationSeed);
    
    final scale = 0.7; // 缩放比例
    final center = Offset(size.width / 2, size.height / 2);
    final scaledWidth = size.width * scale;
    final scaledHeight = size.height * scale;
    
    // 沙漏的宽度和高度
    final hourglassWidth = scaledWidth * 0.7;
    final hourglassHeight = scaledHeight;
    
    // 沙漏的上下部分高度
    final chamberHeight = hourglassHeight * 0.45;
    
    // 沙漏的中间颈部
    final neckWidth = hourglassWidth * 0.2;
    final neckHeight = hourglassHeight * 0.1;
    
    // 沙漏的左上角坐标
    final left = center.dx - hourglassWidth / 2;
    final top = center.dy - hourglassHeight / 2;
    
    // 绘制沙漏外框
    final outlinePaint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    // 上半部分路径
    final upperPath = Path()
      ..moveTo(left, top)
      ..lineTo(left + hourglassWidth, top)
      ..lineTo(left + hourglassWidth / 2 + neckWidth / 2, top + chamberHeight)
      ..lineTo(left + hourglassWidth / 2 - neckWidth / 2, top + chamberHeight)
      ..close();
    
    // 下半部分路径
    final lowerPath = Path()
      ..moveTo(left + hourglassWidth / 2 - neckWidth / 2, top + chamberHeight + neckHeight)
      ..lineTo(left + hourglassWidth / 2 + neckWidth / 2, top + chamberHeight + neckHeight)
      ..lineTo(left + hourglassWidth, top + hourglassHeight)
      ..lineTo(left, top + hourglassHeight)
      ..close();
    
    // 颈部路径
    final neckPath = Path()
      ..moveTo(left + hourglassWidth / 2 - neckWidth / 2, top + chamberHeight)
      ..lineTo(left + hourglassWidth / 2 + neckWidth / 2, top + chamberHeight)
      ..lineTo(left + hourglassWidth / 2 + neckWidth / 2, top + chamberHeight + neckHeight)
      ..lineTo(left + hourglassWidth / 2 - neckWidth / 2, top + chamberHeight + neckHeight)
      ..close();
    
    // 绘制沙漏外框
    canvas.drawPath(upperPath, outlinePaint);
    canvas.drawPath(lowerPath, outlinePaint);
    canvas.drawPath(neckPath, outlinePaint);
    
    // 绘制沙子
    final sandPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    // 计算上下沙子的比例
    final upperSandRatio = 1.0 - progress;
    final lowerSandRatio = progress;
    
    // 上半部分沙子
    if (upperSandRatio > 0) {
      final upperSandHeight = chamberHeight * upperSandRatio;
      final upperSandPath = Path();
      
      // 计算上半部分宽度比例
      final widthRatio = upperSandRatio;
      final upperSandWidth = hourglassWidth * widthRatio;
      final upperSandLeft = left + (hourglassWidth - upperSandWidth) / 2;
      
      // 添加随机波动效果
      final waveHeight = neckWidth * 0.1 * random.nextDouble();
      
      upperSandPath.moveTo(upperSandLeft, top + chamberHeight - upperSandHeight);
      
      // 使用贝塞尔曲线创建波浪效果
      if (upperSandRatio > 0.05) {
        final controlPoint1 = Offset(
          upperSandLeft + upperSandWidth * 0.25, 
          top + chamberHeight - upperSandHeight - waveHeight
        );
        final controlPoint2 = Offset(
          upperSandLeft + upperSandWidth * 0.75, 
          top + chamberHeight - upperSandHeight + waveHeight
        );
        
        upperSandPath.quadraticBezierTo(
          controlPoint1.dx, controlPoint1.dy,
          upperSandLeft + upperSandWidth * 0.5, top + chamberHeight - upperSandHeight
        );
        
        upperSandPath.quadraticBezierTo(
          controlPoint2.dx, controlPoint2.dy,
          upperSandLeft + upperSandWidth, top + chamberHeight - upperSandHeight
        );
      } else {
        upperSandPath.lineTo(upperSandLeft + upperSandWidth, top + chamberHeight - upperSandHeight);
      }
      
      upperSandPath.lineTo(left + hourglassWidth / 2 + neckWidth / 2, top + chamberHeight);
      upperSandPath.lineTo(left + hourglassWidth / 2 - neckWidth / 2, top + chamberHeight);
      upperSandPath.close();
      
      canvas.drawPath(upperSandPath, sandPaint);
    }
    
    // 下半部分沙子
    if (lowerSandRatio > 0) {
      final lowerSandHeight = chamberHeight * lowerSandRatio;
      final lowerSandPath = Path();
      
      // 计算下半部分宽度比例
      final widthRatio = lowerSandRatio;
      final lowerSandWidth = hourglassWidth * widthRatio;
      final lowerSandLeft = left + (hourglassWidth - lowerSandWidth) / 2;
      
      // 添加随机波动效果
      final waveHeight = neckWidth * 0.1 * random.nextDouble();
      
      lowerSandPath.moveTo(left + hourglassWidth / 2 - neckWidth / 2, top + chamberHeight + neckHeight);
      lowerSandPath.lineTo(left + hourglassWidth / 2 + neckWidth / 2, top + chamberHeight + neckHeight);
      
      final bottomY = top + hourglassHeight - (chamberHeight - lowerSandHeight);
      
      // 使用贝塞尔曲线创建波浪效果
      if (lowerSandRatio > 0.05) {
        final controlPoint1 = Offset(
          lowerSandLeft + lowerSandWidth * 0.75, 
          bottomY - waveHeight
        );
        final controlPoint2 = Offset(
          lowerSandLeft + lowerSandWidth * 0.25, 
          bottomY + waveHeight
        );
        
        lowerSandPath.lineTo(lowerSandLeft + lowerSandWidth, bottomY);
        
        lowerSandPath.quadraticBezierTo(
          controlPoint1.dx, controlPoint1.dy,
          lowerSandLeft + lowerSandWidth * 0.5, bottomY
        );
        
        lowerSandPath.quadraticBezierTo(
          controlPoint2.dx, controlPoint2.dy,
          lowerSandLeft, bottomY
        );
      } else {
        lowerSandPath.lineTo(lowerSandLeft + lowerSandWidth, bottomY);
        lowerSandPath.lineTo(lowerSandLeft, bottomY);
      }
      
      lowerSandPath.close();
      
      canvas.drawPath(lowerSandPath, sandPaint);
    }
    
    // 绘制颈部流沙效果
    if (progress > 0 && progress < 1) {
      final flowPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      
      // 绘制流沙
      final flowPath = Path()
        ..moveTo(left + hourglassWidth / 2 - neckWidth / 4, top + chamberHeight)
        ..lineTo(left + hourglassWidth / 2 + neckWidth / 4, top + chamberHeight)
        ..lineTo(left + hourglassWidth / 2 + neckWidth / 4, top + chamberHeight + neckHeight)
        ..lineTo(left + hourglassWidth / 2 - neckWidth / 4, top + chamberHeight + neckHeight)
        ..close();
      
      canvas.drawPath(flowPath, flowPaint);
      
      // 绘制动态沙粒效果
      final particleCount = 8;
      final particleSize = neckWidth / 10;
      
      for (int i = 0; i < particleCount; i++) {
        final offset = random.nextDouble();
        final particleY = top + chamberHeight + neckHeight * offset;
        final particleX = left + hourglassWidth / 2 + (random.nextDouble() - 0.5) * neckWidth / 2;
        
        canvas.drawCircle(
          Offset(particleX, particleY),
          particleSize * (0.5 + random.nextDouble() * 0.5), // 随机大小
          flowPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant HourglassGraphPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.animationSeed != animationSeed; // 添加动画种子比较
  }
}