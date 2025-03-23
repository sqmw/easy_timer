import 'dart:async';
import 'package:easy_timer/widgets/custom_alert_dialog.dart';
import 'package:easy_timer/widgets/timer_display/timer_graph/circular_graph.dart';
import 'package:easy_timer/widgets/timer_display/flip_timer_display.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_timer/providers/notification_provider.dart';
import 'package:easy_timer/widgets/sound_selector_dialog.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  bool _isFullScreen = false;
  
  // 计时器相关状态
  int _days = 0;
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;
  
  Duration _totalTime = const Duration();
  Duration _remainingTime = const Duration();
  
  bool _isRunning = false;
  bool _isPaused = false;
  bool _isCompleted = false;
  
  Timer? _timer;
  
  // 声音相关状态
  String _soundId = '';

  @override
  void initState() {
    super.initState();
    // 初始化默认声音
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      setState(() {
        _soundId = notificationProvider.defaultSound.id;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    final parts = <String>[];
    if (days > 0) parts.add('$days天');
    if (hours > 0) parts.add('$hours小时');
    if (minutes > 0) parts.add('$minutes分钟');
    if (seconds > 0) parts.add('$seconds秒');
    
    return parts.isEmpty ? '0秒' : parts.join(' ');
  }
  
  // 开始计时器
  void _startTimer() {
    if (_isRunning || _remainingTime.inSeconds <= 0) return;
    
    setState(() {
      _isRunning = true;
      _isPaused = false;
      _isCompleted = false;
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime.inSeconds <= 1) {
          _remainingTime = Duration.zero;
          _isRunning = false;
          _isCompleted = true;
          _timer?.cancel();
          
          // 播放提示音
          _playCompletionSound();
        } else {
          _remainingTime = _remainingTime - const Duration(seconds: 1);
        }
      });
    });
  }
  
  // 播放完成提示音
  void _playCompletionSound() {
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    // 查找对应的声音对象
    final sound = notificationProvider.availableSounds.firstWhere(
      (sound) => sound.id == _soundId,
      orElse: () => notificationProvider.defaultSound,
    );
    notificationProvider.playSound(sound);
    
    // 显示完成提醒对话框
    _showCompletionDialog();
  }
  
  // 显示完成提醒对话框
  void _showCompletionDialog() {
    final theme = Theme.of(context);
    
    CustomAlertDialog.show(
      context: context,
      barrierDismissible: false, // 防止点击外部关闭对话框
      title: '计时完成',
      titleIcon: Icons.notifications_active,
      titleIconColor: theme.colorScheme.primary,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '您设置的倒计时已完成',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '总时长: ${_formatDuration(_totalTime)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // 关闭对话框
            _snoozeTimer(); // 推迟10分钟
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.snooze,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              const Text('推迟10分钟'),
            ],
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop(); // 关闭对话框
            // 停止声音
            final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
            notificationProvider.stopSound();
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 20,
                color: theme.colorScheme.onPrimary,
              ),
              const SizedBox(width: 8),
              const Text('确认'),
            ],
          ),
        ),
      ],
    );
  }
  
  // 推迟计时器10分钟
  void _snoozeTimer() {
    // 停止当前声音
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    notificationProvider.stopSound();
    
    // 设置10分钟倒计时
    setState(() {
      _totalTime = const Duration(minutes: 10);
      _remainingTime = _totalTime;
      _isCompleted = false;
      _isRunning = true;
      _isPaused = false;
    });
    
    // 开始新的计时器
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime.inSeconds <= 1) {
          _remainingTime = Duration.zero;
          _isRunning = false;
          _isCompleted = true;
          _timer?.cancel();
          
          // 播放提示音
          _playCompletionSound();
        } else {
          _remainingTime = _remainingTime - const Duration(seconds: 1);
        }
      });
    });
    
    // 显示推迟提示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('已推迟10分钟'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: '取消',
          onPressed: () {
            _stopTimer();
          },
        ),
      ),
    );
  }
  
  // 暂停计时器
  void _pauseTimer() {
    if (!_isRunning) return;
    
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = true;
    });
  }
  
  // 继续计时器
  void _resumeTimer() {
    if (!_isPaused) return;
    _startTimer();
  }
  
  // 停止计时器
  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _isCompleted = false;
      _remainingTime = _totalTime;
    });
  }
  
  // 重置计时器
  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _isCompleted = false;
      _remainingTime = _totalTime;
    });
  }
  
  // 更新总时间
  void _updateTotalTime() {
    final newDuration = Duration(
      days: _days,
      hours: _hours,
      minutes: _minutes,
      seconds: _seconds,
    );
    
    if (newDuration.inSeconds == 0) return; // 防止设置为0
    
    setState(() {
      _totalTime = newDuration;
      _remainingTime = newDuration;
      _isCompleted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;
            final minDimension = screenWidth < screenHeight ? screenWidth : screenHeight;

            final graphSize = minDimension * 0.4;
            final spacing = minDimension * 0.02;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 时间设置部分
                      if (!_isRunning && !_isPaused)
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(spacing),
                            child: Column(
                              children: [
                                Text(
                                  '设置倒计时',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: spacing * 1.5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildTimeSelector('天', _days, (value) {
                                      setState(() {
                                        _days = value;
                                        _updateTotalTime();
                                      });
                                    }, 100),
                                    SizedBox(width: spacing),
                                    _buildTimeSelector('时', _hours, (value) {
                                      setState(() {
                                        _hours = value;
                                        _updateTotalTime();
                                      });
                                    }, 24),
                                    SizedBox(width: spacing),
                                    _buildTimeSelector('分', _minutes, (value) {
                                      setState(() {
                                        _minutes = value;
                                        _updateTotalTime();
                                      });
                                    }, 60),
                                    SizedBox(width: spacing),
                                    _buildTimeSelector('秒', _seconds, (value) {
                                      setState(() {
                                        _seconds = value;
                                        _updateTotalTime();
                                      });
                                    }, 60),
                                  ],
                                ),
                                SizedBox(height: spacing * 2),
                                
                                // 添加声音选择器
                                Column(
                                  children: [
                                    Text(
                                      '完成提示音',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: spacing),
                                    Builder(
                                      builder: (context) {
                                        // 获取当前选择的声音
                                        final currentSound = notificationProvider.availableSounds
                                            .firstWhere(
                                              (sound) => sound.id == _soundId,
                                              orElse: () => notificationProvider.defaultSound,
                                            );

                                        return InkWell(
                                          onTap: () {
                                            // 显示声音选择对话框
                                            showDialog(
                                              context: context,
                                              builder: (context) => SoundSelectorDialog(
                                                initialSoundId: _soundId,
                                                onSoundSelected: (soundId) {
                                                  setState(() {
                                                    _soundId = soundId;
                                                  });
                                                  // 播放所选声音预览
                                                  final sound = notificationProvider.availableSounds
                                                      .firstWhere(
                                                        (sound) => sound.id == soundId,
                                                        orElse: () => notificationProvider.defaultSound,
                                                      );
                                                  notificationProvider.playSound(sound);
                                                },
                                              ),
                                            );
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              color: theme.colorScheme.surfaceVariant,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  currentSound.icon,
                                                  color: theme.colorScheme.primary,
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  currentSound.name,
                                                  style: theme.textTheme.bodyLarge,
                                                ),
                                                const SizedBox(width: 12),
                                                Icon(
                                                  Icons.arrow_forward_ios,
                                                  size: 16,
                                                  color: theme.colorScheme.onSurfaceVariant,
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      
                      SizedBox(height: spacing * 2),
                      
                      // 计时器显示
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(spacing),
                          child: Column(
                            children: [
                              FlipTimerDisplay(
                                remainingTime: _remainingTime,
                                isFullScreen: _isFullScreen,
                              ),
                              SizedBox(height: spacing * 2),
                              SizedBox(
                                width: graphSize,
                                height: graphSize,
                                child: CircularGraph(
                                  remainingTime: _remainingTime,
                                  totalTime: _totalTime,
                                  size: graphSize,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(height: spacing * 2),
                      
                      // 控制按钮
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(spacing),
                          child: Wrap(
                            spacing: spacing,
                            runSpacing: spacing,
                            alignment: WrapAlignment.center,
                            children: [
                              if (!_isRunning && !_isCompleted)
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.play_arrow),
                                  label: const Text('开始'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor: theme.colorScheme.onPrimary,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: _startTimer,
                                ),
                              
                              // ... 其他按钮保持相同样式 ...
                              if (_isRunning)
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.pause),
                                  label: const Text('暂停'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor: theme.colorScheme.onPrimary,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: _pauseTimer,
                                ),
                              if (_isPaused)
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.play_arrow),
                                  label: const Text('继续'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor: theme.colorScheme.onPrimary,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: _resumeTimer,
                                ),
                              if (_isRunning || _isPaused)
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.stop),
                                  label: const Text('停止'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.error,
                                    foregroundColor: theme.colorScheme.onError,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: _stopTimer,
                                ),
                              if (_isPaused || _isCompleted)
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('重置'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.secondary,
                                    foregroundColor: theme.colorScheme.onSecondary,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: _resetTimer,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '倒计时',
          style: TextStyle(
            color: theme.colorScheme.onBackground,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
              size: 28,
              color: theme.colorScheme.onBackground,
            ),
            onPressed: () {
              setState(() {
                _isFullScreen = !_isFullScreen;
              });
            },
          ),
        ],
      ),
    );
  }
  
  // 构建时间选择器组件
  Widget _buildTimeSelector(String label, int value, Function(int) onChanged, int maxValue) {
    return Column(
      children: [
        Text(label),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    onChanged((value + 1) % maxValue);
                  },
                  child: const Icon(Icons.keyboard_arrow_up),
                ),
                GestureDetector(
                  onVerticalDragUpdate: (details) {
                    // 向上滑动增加值，向下滑动减少值
                    if (details.delta.dy < -1) {
                      // 向上滑动
                      onChanged((value + 1) % maxValue);
                    } else if (details.delta.dy > 1) {
                      // 向下滑动
                      onChanged((value - 1 + maxValue) % maxValue);
                    }
                  },
                  child: Listener(
                    onPointerSignal: (pointerSignal) {
                      if (pointerSignal is PointerScrollEvent) {
                        if (pointerSignal.scrollDelta.dy < 0) {
                          // 向上滚动
                          onChanged((value + 1) % maxValue);
                        } else if (pointerSignal.scrollDelta.dy > 0) {
                          // 向下滚动
                          onChanged((value - 1 + maxValue) % maxValue);
                        }
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        value.toString().padLeft(2, '0'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    onChanged((value - 1 + maxValue) % maxValue);
                  },
                  child: const Icon(Icons.keyboard_arrow_down),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
