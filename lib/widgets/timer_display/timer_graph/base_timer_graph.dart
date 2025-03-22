import 'dart:async' show Timer;

import 'package:flutter/material.dart';

abstract class BaseTimerGraph extends StatefulWidget {
  final Duration remainingTime;
  final Duration totalTime;
  final double size;

  const BaseTimerGraph({
    super.key,
    required this.remainingTime,
    required this.totalTime,
    required this.size,
  });
}

abstract class BaseTimerGraphState<T extends BaseTimerGraph> extends State<T> {
  late Timer _timer;
  late Duration _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = widget.remainingTime;
    _startTimer();
  }

  @override
  void didUpdateWidget(T oldWidget) {
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

  Duration get currentTime => _currentTime;
}