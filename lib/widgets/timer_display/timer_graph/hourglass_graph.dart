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
  late Timer _animationTimer;
  final _random = math.Random();
  int _animationSeed = 0;

  @override
  void initState() {
    super.initState();
    _startAnimationTimer();
  }

  void _startAnimationTimer() {
    _animationTimer = Timer.periodic(const Duration(milliseconds: 500), (
      timer,
    ) {
      setState(() {
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
    // 精确到毫秒的进度计算
    final total = widget.totalTime.inMilliseconds.toDouble();
    final remaining = currentTime.inMilliseconds.toDouble();
    final progress = 1 - (remaining / total).clamp(0.0, 1.0);

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CustomPaint(
        painter: HourglassGraphPainter(
          progress: progress,
          color: widget.color ?? Theme.of(context).colorScheme.primary,
          animationSeed: _animationSeed,
        ),
      ),
    );
  }
}

class HourglassGraphPainter extends CustomPainter {
  final double progress;
  final Color color;
  final int animationSeed;

  HourglassGraphPainter({
    required this.progress,
    required this.color,
    required this.animationSeed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(animationSeed);

    // 调整尺寸比例，使沙漏更符合图片形状
    final scale = 0.85;
    final center = Offset(size.width / 2, size.height / 2);
    final scaledWidth = size.width * scale;
    final scaledHeight = size.height * scale;

    // 调整沙漏形状为更圆润的形状
    final hourglassWidth = scaledWidth * 0.65;
    final hourglassHeight = scaledHeight;
    final chamberHeight = hourglassHeight * 0.45;
    final neckWidth = hourglassWidth * 0.15;
    final neckHeight = hourglassHeight * 0.05;

    final left = center.dx - hourglassWidth / 2;
    final top = center.dy - hourglassHeight / 2;

    // 使用更自然的进度曲线
    final adjustedProgress = _adjustProgressCurve(progress);

    // 绘制玻璃效果 - 半透明外壳
    final glassOutlinePaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final glassFillPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    // 上部玻璃腔体 - 使用贝塞尔曲线创建圆润形状
    final upperGlassPath = Path();
    
    // 上部左侧曲线
    upperGlassPath.moveTo(left, top);
    upperGlassPath.quadraticBezierTo(
      left, 
      top + chamberHeight * 0.5,
      left + hourglassWidth * 0.5 - neckWidth * 0.5, 
      top + chamberHeight
    );
    
    // 上部颈部连接
    upperGlassPath.lineTo(left + hourglassWidth * 0.5 - neckWidth * 0.5, top + chamberHeight);
    upperGlassPath.lineTo(left + hourglassWidth * 0.5 + neckWidth * 0.5, top + chamberHeight);
    
    // 上部右侧曲线
    upperGlassPath.quadraticBezierTo(
      left + hourglassWidth, 
      top + chamberHeight * 0.5,
      left + hourglassWidth, 
      top
    );
    
    // 上部顶边
    upperGlassPath.lineTo(left, top);
    upperGlassPath.close();

    // 下部玻璃腔体
    final lowerGlassPath = Path();
    
    // 下部颈部连接
    lowerGlassPath.moveTo(left + hourglassWidth * 0.5 - neckWidth * 0.5, top + chamberHeight + neckHeight);
    lowerGlassPath.lineTo(left + hourglassWidth * 0.5 + neckWidth * 0.5, top + chamberHeight + neckHeight);
    
    // 下部右侧曲线
    lowerGlassPath.quadraticBezierTo(
      left + hourglassWidth, 
      top + chamberHeight + neckHeight + chamberHeight * 0.5,
      left + hourglassWidth, 
      top + hourglassHeight
    );
    
    // 下部底边
    lowerGlassPath.lineTo(left, top + hourglassHeight);
    
    // 下部左侧曲线
    lowerGlassPath.quadraticBezierTo(
      left, 
      top + chamberHeight + neckHeight + chamberHeight * 0.5,
      left + hourglassWidth * 0.5 - neckWidth * 0.5, 
      top + chamberHeight + neckHeight
    );
    
    lowerGlassPath.close();

    // 颈部玻璃
    final neckGlassPath = Path()
      ..moveTo(left + hourglassWidth * 0.5 - neckWidth * 0.5, top + chamberHeight)
      ..lineTo(left + hourglassWidth * 0.5 + neckWidth * 0.5, top + chamberHeight)
      ..lineTo(left + hourglassWidth * 0.5 + neckWidth * 0.5, top + chamberHeight + neckHeight)
      ..lineTo(left + hourglassWidth * 0.5 - neckWidth * 0.5, top + chamberHeight + neckHeight)
      ..close();

    // 绘制玻璃效果
    canvas.drawPath(upperGlassPath, glassFillPaint);
    canvas.drawPath(lowerGlassPath, glassFillPaint);
    canvas.drawPath(neckGlassPath, glassFillPaint);
    
    // 添加高光效果
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    // 右侧高光
    final rightHighlightPath = Path()
      ..moveTo(left + hourglassWidth * 0.85, top + hourglassHeight * 0.1)
      ..quadraticBezierTo(
        left + hourglassWidth * 0.95, 
        top + hourglassHeight * 0.3,
        left + hourglassWidth * 0.85, 
        top + hourglassHeight * 0.5
      )
      ..quadraticBezierTo(
        left + hourglassWidth * 0.95, 
        top + hourglassHeight * 0.7,
        left + hourglassWidth * 0.85, 
        top + hourglassHeight * 0.9
      );
    
    canvas.drawPath(rightHighlightPath, highlightPaint);

    // 沙子颜色 - 金黄色
    final sandColor = Color(0xFFFFD700);
    final sandPaint = Paint()
      ..color = sandColor
      ..style = PaintingStyle.fill;
    
    // 沙子表面纹理
    final sandTexturePaint = Paint()
      ..color = sandColor.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // 绘制上部沙子
    if (adjustedProgress < 1.0) {
      final upperFillRatio = 1.0 - adjustedProgress;
      final upperHeight = chamberHeight * upperFillRatio;
      
      // 创建上部沙子路径
      final upperSandPath = Path();
      
      // 计算沙子表面宽度和位置
      final surfaceWidth = hourglassWidth * (1 - (chamberHeight - upperHeight) / chamberHeight * 0.5);
      final surfaceLeft = left + (hourglassWidth - surfaceWidth) / 2;
      final surfaceY = top + chamberHeight - upperHeight;
      
      // 添加波浪效果
      final waveSegments = 10;
      final waveAmplitude = math.min(2.0, upperHeight * 0.03);
      
      // 绘制波浪表面
      for (int i = 0; i <= waveSegments; i++) {
        final x = surfaceLeft + (surfaceWidth / waveSegments) * i;
        final phase = i / waveSegments * math.pi * 2 + animationSeed / 500.0;
        final waveOffset = math.sin(phase) * waveAmplitude;
        
        if (i == 0) {
          upperSandPath.moveTo(x, surfaceY + waveOffset);
        } else {
          upperSandPath.lineTo(x, surfaceY + waveOffset);
        }
      }
      
      // 连接到颈部
      upperSandPath.quadraticBezierTo(
        left + hourglassWidth * 0.75,
        top + chamberHeight * 0.7,
        left + hourglassWidth * 0.5 + neckWidth * 0.5,
        top + chamberHeight
      );
      
      upperSandPath.lineTo(left + hourglassWidth * 0.5 - neckWidth * 0.5, top + chamberHeight);
      
      upperSandPath.quadraticBezierTo(
        left + hourglassWidth * 0.25,
        top + chamberHeight * 0.7,
        surfaceLeft,
        surfaceY
      );
      
      upperSandPath.close();
      
      canvas.drawPath(upperSandPath, sandPaint);
      
      // 添加沙子纹理
      for (int i = 0; i < 15 * upperFillRatio; i++) {
        final startX = surfaceLeft + random.nextDouble() * surfaceWidth;
        final startY = surfaceY + random.nextDouble() * upperHeight * 0.8;
        final length = 1.0 + random.nextDouble() * 3.0;
        final angle = random.nextDouble() * math.pi;
        
        final endX = startX + math.cos(angle) * length;
        final endY = startY + math.sin(angle) * length;
        
        canvas.drawLine(
          Offset(startX, startY),
          Offset(endX, endY),
          sandTexturePaint
        );
      }
    }

    // 绘制下部沙子 - 使用曲线线条
    if (adjustedProgress > 0.0) {
      final lowerFillRatio = adjustedProgress;
      final lowerHeight = chamberHeight * math.sqrt(lowerFillRatio).clamp(0.0, 1.0);
      
      // 计算线条数量和间距
      final lineCount = math.max(5, (15 * lowerFillRatio).ceil());
      
      // 绘制曲线线条
      for (int i = 0; i < lineCount; i++) {
        // 计算曲线的起点和终点
        final progress = (i + 1) / (lineCount + 1);
        final y = top + hourglassHeight - lowerHeight * progress;
        
        // 计算当前高度对应的宽度 - 调整为更符合图片中的形状
        final heightRatio = (y - (top + chamberHeight + neckHeight)) / chamberHeight;
        // 使用更平缓的曲线计算宽度
        final currentWidth = hourglassWidth * math.min(0.9, math.pow(heightRatio, 0.7).toDouble());
        final currentLeft = left + (hourglassWidth - currentWidth) / 2;
        
        // 减小随机偏移，使线条更整齐
        final offsetX = random.nextDouble() * 1.5 - 0.75;
        // 减小曲率，使线条更平缓
        final curvature = 3 + random.nextDouble() * 5;
        
        final linePath = Path()
          ..moveTo(currentLeft + offsetX, y)
          ..quadraticBezierTo(
            left + hourglassWidth / 2, 
            y - curvature,
            currentLeft + currentWidth + offsetX, 
            y
          );
        
        canvas.drawPath(linePath, sandPaint);
      }
    }

    // 绘制流沙连接 - 使用双线条，更接近图片中的样式
    if (progress > 0.01 && progress < 0.99) {
      final neckCenterX = left + hourglassWidth / 2;
      final upperBottom = top + chamberHeight;
      final lowerTop = top + chamberHeight + neckHeight;
      
      // 调整流沙线条间距，使其更接近图片
      final flowLineSpacing = neckWidth * 0.4;
      
      // 左侧线条
      final leftFlowPath = Path()
        ..moveTo(neckCenterX - flowLineSpacing, upperBottom)
        ..lineTo(neckCenterX - flowLineSpacing, lowerTop);
      
      // 右侧线条
      final rightFlowPath = Path()
        ..moveTo(neckCenterX + flowLineSpacing, upperBottom)
        ..lineTo(neckCenterX + flowLineSpacing, lowerTop);
      
      canvas.drawPath(leftFlowPath, sandPaint);
      canvas.drawPath(rightFlowPath, sandPaint);
      
      // 减少粒子效果，图片中没有明显的粒子
      // 添加漏斗效果 - 调整为更符合图片中的形状
      if (adjustedProgress < 0.9) {
        final funnelPath = Path()
          ..moveTo(neckCenterX - neckWidth * 0.6, upperBottom - neckHeight * 0.5)
          ..lineTo(neckCenterX - flowLineSpacing, upperBottom)
          ..moveTo(neckCenterX + neckWidth * 0.6, upperBottom - neckHeight * 0.5)
          ..lineTo(neckCenterX + flowLineSpacing, upperBottom);
        
        canvas.drawPath(funnelPath, sandPaint);
      }
      
      // 添加扩散效果 - 调整为更符合图片中的形状
      if (adjustedProgress > 0.1) {
        final spreadPath = Path()
          ..moveTo(neckCenterX - flowLineSpacing, lowerTop)
          ..lineTo(neckCenterX - neckWidth * 0.6, lowerTop + neckHeight * 0.5)
          ..moveTo(neckCenterX + flowLineSpacing, lowerTop)
          ..lineTo(neckCenterX + neckWidth * 0.6, lowerTop + neckHeight * 0.5);
        
        canvas.drawPath(spreadPath, sandPaint);
      }
    }

    // 最后绘制玻璃轮廓，使其位于最上层
    canvas.drawPath(upperGlassPath, glassOutlinePaint);
    canvas.drawPath(lowerGlassPath, glassOutlinePaint);
    canvas.drawPath(neckGlassPath, glassOutlinePaint);
  }

  // 改进进度曲线函数 - 修改为更平衡的流动速率
  double _adjustProgressCurve(double progress) {
    // 使用更平衡的缓动函数
    if (progress < 0.1) {
      // 开始时缓慢但不要太慢
      return progress * 0.7; // 提高初始流速
    } else if (progress > 0.9) {
      // 结束时稍微加速但不要太快
      return 0.63 + (progress - 0.9) * 3.7; // 降低结束流速
    } else {
      // 中间阶段匀速，更加平衡
      return 0.07 + (progress - 0.1) * 0.7; // 调整中间流速
    }
  }

  double _calculateTotalVolume(double width, double height) {
    // 使用锥台体积公式更准确计算
    final topRadius = width / 2;
    final bottomRadius = width / 2;
    return (1 / 3) *
        math.pi *
        height *
        (math.pow(topRadius, 2) +
            topRadius * bottomRadius +
            math.pow(bottomRadius, 2));
  }

  double _calculateFlowRate(
    double progress,
    double volume,
    double neckWidth,
    double chamberHeight,
  ) {
    // 伯努利方程计算流速
    final gravity = 9.8;
    final orificeArea = math.pi * math.pow(neckWidth / 3, 2); // 有效流口面积

    // 考虑剩余沙量对流速的影响
    final remainingRatio = 1 - progress;
    final pressureFactor =
        math.sqrt(remainingRatio) * math.sqrt(2 * gravity * chamberHeight);

    // 流速随剩余量减少而减小
    return (orificeArea * pressureFactor * remainingRatio) / (volume + 0.001);
  }

  @override
  bool shouldRepaint(covariant HourglassGraphPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.animationSeed != animationSeed;
  }
}

extension RandomExtension on math.Random {
  double nextGaussian() {
    double u1 = nextDouble();
    double u2 = nextDouble();
    return math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2);
  }
}
