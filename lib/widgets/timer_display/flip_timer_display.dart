import 'package:easy_timer/const/assets.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

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

class _FlipTimerDisplayState extends State<FlipTimerDisplay> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadFlutterAsset(Assets.assets_web_timer_digit_timer_flip_timer_html)
      ..addJavaScriptChannel(
        'TimerChannel',
        onMessageReceived: (JavaScriptMessage message) {
          // 处理计时器结束事件
          print('Timer ended: ${message.message}');
        },
      );
  }

  void _updateTimer() {
    final totalSeconds = widget.remainingTime.inSeconds;
    _controller.runJavaScript('''
      var flipdown = new FlipDown($totalSeconds)
        .start()
        .ifEnded(() => {
          TimerChannel.postMessage('Timer ended');
        });
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ColoredBox(  // 使用 ColoredBox 来设置背景色
        color: Colors.transparent,
        child: SizedBox(
          height: widget.isFullScreen ? 200 : 150,
          child: WebViewWidget(
            controller: _controller,
          ),
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(FlipTimerDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.remainingTime != widget.remainingTime) {
      _updateTimer();
    }
  }
}