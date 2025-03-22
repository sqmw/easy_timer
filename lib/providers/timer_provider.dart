import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:easy_timer/models/timer_item.dart';
import 'package:uuid/uuid.dart';
import 'package:easy_timer/providers/notification_provider.dart';

enum TimerStatus {
  idle,     // 空闲状态
  running,  // 运行中
  paused,   // 暂停
  completed // 完成
}

class TimerProvider extends ChangeNotifier {
  NotificationProvider? _notificationProvider;
  List<TimerItem> _timers = [];
  TimerItem? _activeTimer;
  TimerStatus _status = TimerStatus.idle;
  Timer? _ticker;
  Duration _remainingTime = Duration.zero;
  double _progress = 0.0;
  
  // 构造函数，允许可选的通知提供者
  TimerProvider({NotificationProvider? notificationProvider}) 
      : _notificationProvider = notificationProvider;
  
  // 设置通知提供者的方法
  void setNotificationProvider(NotificationProvider provider) {
    _notificationProvider = provider;
  }
  
  // Getters
  List<TimerItem> get timers => _timers;
  TimerItem? get activeTimer => _activeTimer;
  TimerStatus get status => _status;
  Duration get remainingTime => _remainingTime;
  double get progress => _progress;
  bool get isRunning => _status == TimerStatus.running;
  bool get isPaused => _status == TimerStatus.paused;
  bool get isCompleted => _status == TimerStatus.completed;
  
  // 添加计时器
  void addTimer(TimerItem timer) {
    _timers.add(timer);
    notifyListeners();
  }
  
  // 创建新计时器
  TimerItem createTimer({
    required String name,
    required Duration duration,
    bool isAutoStart = false,
    String? soundId,
  }) {
    final id = const Uuid().v4();
    final timer = TimerItem(
      id: id,
      name: name,
      duration: duration,
      isAutoStart: isAutoStart,
      soundId: soundId ?? _notificationProvider?.defaultSound.id ?? 'default',
      createdAt: DateTime.now(),
    );
    
    addTimer(timer);
    return timer;
  }
  
  // 移除计时器
  void removeTimer(String id) {
    // 如果要删除的是当前活动计时器，先停止它
    if (_activeTimer?.id == id) {
      stopTimer();
    }
    
    _timers.removeWhere((timer) => timer.id == id);
    notifyListeners();
  }
  
  // 更新计时器
  void updateTimer(TimerItem timer) {
    final index = _timers.indexWhere((t) => t.id == timer.id);
    if (index != -1) {
      _timers[index] = timer;
      
      // 如果更新的是当前活动计时器，也更新活动计时器
      if (_activeTimer?.id == timer.id) {
        _activeTimer = timer;
        
        // 如果计时器正在运行，需要重新计算进度
        if (_status == TimerStatus.running || _status == TimerStatus.paused) {
          _updateProgress();
        }
      }
      
      notifyListeners();
    }
  }
  
  // 开始计时器
  void startTimer(String timerId) {
    // 查找计时器
    final timer = _timers.firstWhere(
      (t) => t.id == timerId,
      orElse: () => throw Exception('Timer not found'),
    );
    
    // 设置为活动计时器
    _activeTimer = timer;
    _remainingTime = timer.duration;
    _status = TimerStatus.running;
    _progress = 1.0;
    
    // 启动计时器
    _startTicker();
    notifyListeners();
  }
  
  // 暂停计时器
  void pauseTimer() {
    if (_status == TimerStatus.running) {
      _status = TimerStatus.paused;
      _ticker?.cancel();
      notifyListeners();
    }
  }
  
  // 继续计时器
  void resumeTimer() {
    if (_status == TimerStatus.paused) {
      _status = TimerStatus.running;
      _startTicker();
      notifyListeners();
    }
  }
  
  // 停止计时器
  void stopTimer() {
    _ticker?.cancel();
    _ticker = null;
    _status = TimerStatus.idle;
    _activeTimer = null;
    _remainingTime = Duration.zero;
    _progress = 0.0;
    notifyListeners();
  }
  
  // 重置计时器
  void resetTimer() {
    if (_activeTimer != null) {
      _ticker?.cancel();
      _remainingTime = _activeTimer!.duration;
      _status = TimerStatus.paused;
      _progress = 1.0;
      notifyListeners();
    }
  }
  
  // 启动计时器的内部方法
  void _startTicker() {
    _ticker?.cancel();
    
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        _remainingTime = _remainingTime - const Duration(seconds: 1);
        _updateProgress();
        notifyListeners();
      } else {
        _ticker?.cancel();
        _status = TimerStatus.completed;
        _progress = 0.0;
        
        // 触发通知，添加空检查
        if (_activeTimer != null && _notificationProvider != null) {
          _notificationProvider!.triggerNotification();
        }
        
        notifyListeners();
      }
    });
  }
  
  // 更新进度
  void _updateProgress() {
    if (_activeTimer != null) {
      final totalSeconds = _activeTimer!.duration.inSeconds;
      final remainingSeconds = _remainingTime.inSeconds;
      
      if (totalSeconds > 0) {
        _progress = remainingSeconds / totalSeconds;
      } else {
        _progress = 0.0;
      }
    }
  }
  
  // 按名称搜索计时器
  List<TimerItem> searchTimers(String query) {
    if (query.isEmpty) {
      return _timers;
    }
    
    return _timers.where((timer) => 
      timer.name.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
  
  // 排序计时器
  void sortTimers(String sortBy) {
    switch (sortBy) {
      case 'name':
        _timers.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'duration':
        _timers.sort((a, b) => a.duration.compareTo(b.duration));
        break;
      case 'created':
        _timers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    notifyListeners();
  }
  
  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}