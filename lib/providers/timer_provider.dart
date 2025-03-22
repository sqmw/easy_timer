import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:easy_timer/models/timer_item.dart';
import 'package:uuid/uuid.dart';
import 'package:easy_timer/providers/notification_provider.dart';

enum TimerStatus {
  idle, // 空闲状态
  running, // 运行中
  paused, // 暂停
  completed, // 完成
}

typedef AutoStartReminderCallback = void Function(TimerItem timer);

class TimerProvider extends ChangeNotifier {
  NotificationProvider? _notificationProvider;
  List<TimerItem> _timers = [];
  TimerItem? _activeTimer;
  TimerStatus _status = TimerStatus.idle;
  Timer? _ticker;
  Duration _remainingTime = Duration.zero;
  double _progress = 0.0;
  Timer? _refreshTimer; // 添加刷新定时器

  // 构造函数，允许可选的通知提供者
  TimerProvider({NotificationProvider? notificationProvider})
    : _notificationProvider = notificationProvider {
    // 添加几个预设的计时器
    _initializeDefaultTimers();
    
    // 启动自动刷新
    _startRefreshTimer();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  // 添加自动刷新定时器
  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    
    // 每分钟刷新一次UI，更新倒计时显示
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      // 检查是否有即将开始的计时器
      final now = DateTime.now();
      bool needRefresh = false;
      
      for (final timer in _timers) {
        if (timer.isEnabled && timer.startTime != null && timer.startTime!.isAfter(now)) {
          needRefresh = true;
          break;
        }
      }
      
      if (needRefresh) {
        notifyListeners();
      }
    });
  }

  // 初始化默认计时器
  void _initializeDefaultTimers() {
    // 添加几个常用的计时器预设
    final defaultTimers = [
      TimerItem(
        id: const Uuid().v4(),
        name: '专注时间',
        duration: const Duration(minutes: 25),
        isEnabled: true, // 修改参数名
        soundId: _notificationProvider?.defaultSound.id ?? 'default',
        createdAt: DateTime.now(),
      ),
      TimerItem(
        id: const Uuid().v4(),
        name: '短休息',
        duration: const Duration(minutes: 5),
        isEnabled: false,
        soundId: _notificationProvider?.defaultSound.id ?? 'default',
        createdAt: DateTime.now().add(const Duration(seconds: 1)),
      ),
      TimerItem(
        id: const Uuid().v4(),
        name: '煮茶',
        duration: const Duration(minutes: 3),
        isEnabled: false,
        soundId: _notificationProvider?.defaultSound.id ?? 'default',
        createdAt: DateTime.now().add(const Duration(seconds: 2)),
      ),
      TimerItem(
        id: const Uuid().v4(),
        name: '冥想',
        duration: const Duration(minutes: 10),
        isEnabled: false,
        soundId: _notificationProvider?.defaultSound.id ?? 'default',
        createdAt: DateTime.now().add(const Duration(seconds: 3)),
      ),
    ];

    // 将默认计时器添加到列表中
    _timers.addAll(defaultTimers);
  }

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
    bool isEnabled = true, // 修改参数名和默认值
    String? soundId,
    DateTime? startTime,
  }) {
    final id = const Uuid().v4();
    final timer = TimerItem(
      id: id,
      name: name,
      duration: duration,
      isEnabled: isEnabled, // 修改参数名
      soundId: soundId ?? _notificationProvider?.defaultSound.id ?? 'default',
      createdAt: DateTime.now(),
      startTime: startTime,
    );
    
    addTimer(timer);
    
    // 如果是启用状态且有开始时间，设置自动启动提醒
    if (isEnabled && startTime != null) {
      _scheduleAutoStartReminder(timer);
    }
    
    return timer;
  }

  // 添加自动启动提醒的方法
  void _scheduleAutoStartReminder(TimerItem timer) {
    if (timer.startTime == null) return;

    // 计算提醒时间（开始时间前10秒）
    final reminderTime = timer.startTime!.subtract(const Duration(seconds: 10));
    final now = DateTime.now();

    // 如果提醒时间已经过去，不需要设置提醒
    if (reminderTime.isBefore(now)) return;

    // 计算延迟时间
    final delay = reminderTime.difference(now);

    // 设置定时器
    Timer(delay, () {
      // 显示自动启动提醒
      _showAutoStartReminder(timer);
    });
  }

  // 显示自动启动提醒的方法（需要在UI层实现）
  void _showAutoStartReminder(TimerItem timer) {
    // 这个方法需要通过回调或事件总线通知UI层显示提醒对话框
    // 这里先定义一个回调函数类型
    if (_autoStartReminderCallback != null) {
      _autoStartReminderCallback!(timer);
    }
  }

  // 定义回调函数类型和变量
  AutoStartReminderCallback? _autoStartReminderCallback;

  // 设置回调的方法
  void setAutoStartReminderCallback(AutoStartReminderCallback callback) {
    _autoStartReminderCallback = callback;
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
  void updateTimer(TimerItem updatedTimer) {
    final index = _timers.indexWhere((timer) => timer.id == updatedTimer.id);
    if (index != -1) {
      final oldTimer = _timers[index];
      _timers[index] = updatedTimer;
  
      // 如果启用状态发生变化，处理相关逻辑
      if (oldTimer.isEnabled != updatedTimer.isEnabled) {
        // 如果从未启用变为启用，且有开始时间，设置自动启动提醒
        if (updatedTimer.isEnabled && updatedTimer.startTime != null) {
          _scheduleAutoStartReminder(updatedTimer);
        }
      }
  
      // 如果正在更新的是当前活动的计时器，则更新活动计时器
      if (_activeTimer != null && _activeTimer!.id == updatedTimer.id) {
        _activeTimer = updatedTimer;
        _remainingTime = updatedTimer.duration;
        _progress = 1.0;
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

  // 添加一个用于存储原始计时器列表的变量
  List<TimerItem> _originalTimers = [];
  
  // 搜索计时器
  void searchTimers(String keyword) {
    if (_originalTimers.isEmpty) {
      // 第一次搜索时，保存原始列表
      _originalTimers = List.from(_timers);
    }
    
    // 根据关键词过滤计时器
    _timers = _originalTimers.where((timer) {
      return timer.name.toLowerCase().contains(keyword.toLowerCase());
    }).toList();
    
    notifyListeners();
  }
  
  // 重置搜索结果
  void resetSearch() {
    if (_originalTimers.isNotEmpty) {
      _timers = List.from(_originalTimers);
      _originalTimers = [];
      notifyListeners();
    }
  }

  // 排序计时器
  void sortTimers(String sortBy, [bool ascending = true]) {
    switch (sortBy) {
      case 'name':
        _timers.sort((a, b) => ascending 
            ? a.name.compareTo(b.name) 
            : b.name.compareTo(a.name));
        break;
      case 'duration':
        _timers.sort((a, b) => ascending 
            ? a.duration.compareTo(b.duration) 
            : b.duration.compareTo(a.duration));
        break;
      case 'created':
        _timers.sort((a, b) => ascending 
            ? a.createdAt.compareTo(b.createdAt) 
            : b.createdAt.compareTo(a.createdAt));
        break;
    }
    notifyListeners();
  }

  // 删除计时器
  void deleteTimer(String id) {
    // 查找并删除指定ID的计时器
    _timers.removeWhere((timer) => timer.id == id);

    // 通知监听器更新UI
    notifyListeners();
  }
}
