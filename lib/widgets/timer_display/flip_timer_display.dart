import 'dart:async';
import 'package:flutter/material.dart';

class FlipTimerDisplay extends StatefulWidget {
  final Duration remainingTime;
  final bool isFullScreen;

  const FlipTimerDisplay({
    Key? key,
    required this.remainingTime,
    this.isFullScreen = false,
  }) : super(key: key);

  @override
  State<FlipTimerDisplay> createState() => _FlipTimerDisplayState();
}

class _FlipTimerDisplayState extends State<FlipTimerDisplay> with TickerProviderStateMixin {
  Timer? _timer;
  late Duration _currentTime;
  Map<String, AnimationController> _controllers = {};
  Map<String, Animation<double>> _animations = {};
  Map<String, String> _lastValues = {
    'days': '00',
    'hours': '00',
    'minutes': '00',
    'seconds': '00',
  };

  @override
  void initState() {
    super.initState();
    _currentTime = widget.remainingTime;
    _initAnimations();
    // _startTimer();
  }

  void _initAnimations() {
    // 为每个时间单位创建动画控制器
    for (var unit in ['days', 'hours', 'minutes', 'seconds']) {
      _controllers[unit] = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      );
      _animations[unit] = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _controllers[unit]!,
          curve: Curves.easeInOut,
        ),
      );
    }
  }

  void _startTimer() {
    _updateDisplay(); // 立即更新一次显示
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_currentTime.inSeconds > 0) {
          _currentTime = _currentTime - const Duration(seconds: 1);
          _updateDisplay();
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  void _updateDisplay() {
    final days = _currentTime.inDays.toString().padLeft(2, '0');
    final hours = _currentTime.inHours.remainder(24).toString().padLeft(2, '0');
    final minutes = _currentTime.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = _currentTime.inSeconds.remainder(60).toString().padLeft(2, '0');

    // 检查哪些值发生了变化，并触发相应的动画
    if (days != _lastValues['days']) {
      _controllers['days']!.reset();
      _controllers['days']!.forward();
      _lastValues['days'] = days;
    }
    if (hours != _lastValues['hours']) {
      _controllers['hours']!.reset();
      _controllers['hours']!.forward();
      _lastValues['hours'] = hours;
    }
    if (minutes != _lastValues['minutes']) {
      _controllers['minutes']!.reset();
      _controllers['minutes']!.forward();
      _lastValues['minutes'] = minutes;
    }
    if (seconds != _lastValues['seconds']) {
      _controllers['seconds']!.reset();
      _controllers['seconds']!.forward();
      _lastValues['seconds'] = seconds;
    }
  }

  @override
  void didUpdateWidget(FlipTimerDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.remainingTime != widget.remainingTime) {
      _currentTime = widget.remainingTime;
      _updateDisplay();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = _currentTime.inDays.toString().padLeft(2, '0');
    final hours = _currentTime.inHours.remainder(24).toString().padLeft(2, '0');
    final minutes = _currentTime.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = _currentTime.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildDigitCard(days, '天', _animations['days']!),
          const SizedBox(width: 16),
          _buildDigitCard(hours, '时', _animations['hours']!),
          const SizedBox(width: 16),
          _buildDigitCard(minutes, '分', _animations['minutes']!),
          const SizedBox(width: 16),
          _buildDigitCard(seconds, '秒', _animations['seconds']!),
        ],
      ),
    );
  }

  Widget _buildDigitCard(String value, String label, Animation<double> animation) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFlipCard(value, animation),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: widget.isFullScreen ? 18 : 14,
          ),
        ),
      ],
    );
  }

  Widget _buildFlipCard(String value, Animation<double> animation) {
    final cardWidth = widget.isFullScreen ? 100.0 : 70.0;
    final cardHeight = widget.isFullScreen ? 120.0 : 90.0;
    final fontSize = widget.isFullScreen ? 60.0 : 45.0;

    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade800.withOpacity(0.3), width: 0.5),
      ),
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              // 上半部分（静态）
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: cardHeight / 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Center(
                    child: Transform.translate(
                      offset: Offset(0, cardHeight * 0.2599), // 调整上半部分位置
                      child: Text(
                        value,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSize,
                          fontWeight: FontWeight.w500,
                          height: 0.1, // 进一步减小行高
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // 下半部分（静态）
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: cardHeight / 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Center(
                    child: Transform.translate(
                      offset: Offset(0, -cardHeight * 0.22), // 调整下半部分位置
                      child: Text(
                        value,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: fontSize,
                          fontWeight: FontWeight.w500,
                          height: 0.1, // 进一步减小行高
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // 中间分割线
              Positioned(
                top: cardHeight / 2,
                left: 4,
                right: 4,
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800.withValues(alpha: 77), // 0.3 * 255 ≈ 77
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 51), // 0.2 * 255 ≈ 51
                        offset: const Offset(0, 1),
                        blurRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
              
              // 翻转动画部分
              if (animation.value > 0 && animation.value < 1)
                Positioned(
                  top: animation.value < 0.5 ? 0 : cardHeight / 2,
                  left: 0,
                  right: 0,
                  height: cardHeight / 2,
                  child: Transform(
                    alignment: animation.value < 0.5 
                        ? Alignment.bottomCenter 
                        : Alignment.topCenter,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateX(animation.value < 0.5 
                          ? animation.value * Math.pi 
                          : (1 - animation.value) * Math.pi),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: animation.value < 0.5
                            ? const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              )
                            : const BorderRadius.only(
                                bottomLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                      ),
                      child: Center(
                        child: Transform.translate(
                          offset: Offset(0, animation.value < 0.5 
                              ? cardHeight * 0.22  // 调整动画部分位置
                              : -cardHeight * 0.22),
                          child: Text(
                            value,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: fontSize,
                              fontWeight: FontWeight.w500,
                              height: 0.1, // 调整行高
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// 添加Math类以支持pi常量
class Math {
  static const double pi = 3.1415926535897932;
}