import 'dart:async';
import 'dart:convert' show jsonDecode, jsonEncode;
import 'package:flutter/foundation.dart';
import 'package:easy_timer/models/timer_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  // 存储计时器列表的键
  static const String _timersStorageKey = 'saved_timers';

  // 自动启动提醒回调
  AutoStartReminderCallback? _autoStartReminderCallback;

  // 添加一个标志表示是否已完成初始化
  bool _isInitialized = false;
  
  // 构造函数修改
  TimerProvider({NotificationProvider? notificationProvider})
    : _notificationProvider = notificationProvider {
    // 初始化时立即加载计时器
    _initializeProvider();
  }
  
  // 新增初始化方法
  Future<void> _initializeProvider() async {
    // 先加载保存的计时器
    await _loadTimers();
    
    // 如果没有计时器，添加默认计时器
    if (_timers.isEmpty) {
      _initializeDefaultTimers();
    }
    
    // 启动自动刷新
    _startRefreshTimer();
    
    // 标记初始化完成
    _isInitialized = true;
    
    // 通知监听器更新UI
    notifyListeners();
  }
  
  // 加载保存的计时器方法改进
  Future<void> _loadTimers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? timersJson = prefs.getString(_timersStorageKey);
      
      if (timersJson != null && timersJson.isNotEmpty) {
        final List<dynamic> decodedList = jsonDecode(timersJson);
        _timers = decodedList.map((item) {
          return TimerItem.fromJson(item);
        }).toList();
        
        debugPrint('已加载 ${_timers.length} 个计时器');
      } else {
        _timers = [];
        debugPrint('没有找到保存的计时器');
      }
    } catch (e) {
      debugPrint('加载计时器错误: $e');
      _timers = [];
    }
  }
  
  // 保存计时器方法改进
  Future<void> _saveTimers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> encodedList = _timers.map((timer) => timer.toJson()).toList();
      final String timersJson = jsonEncode(encodedList);
      
      await prefs.setString(_timersStorageKey, timersJson);
      debugPrint('已保存 ${_timers.length} 个计时器');
    } catch (e) {
      debugPrint('保存计时器错误: $e');
    }
  }
  
  // 修改 getter 以确保初始化完成
  List<TimerItem> get timers {
    // 如果尚未初始化完成，返回空列表避免显示不完整数据
    if (!_isInitialized) {
      return [];
    }
    return _timers;
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

    // 每秒刷新一次UI，更新倒计时显示
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // 检查是否有即将开始的计时器
      final now = DateTime.now();
      bool needRefresh = false;

      for (final timer in _timers) {
        if (timer.isEnabled &&
            timer.startTime != null &&
            timer.startTime!.isAfter(now)) {
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
    // 保存计时器到本地
    _saveTimers();
  }



  // 设置通知提供者的方法
  void setNotificationProvider(NotificationProvider provider) {
    _notificationProvider = provider;
  }
  // 设置自动启动提醒回调
  void setAutoStartReminderCallback(AutoStartReminderCallback callback) {
    _autoStartReminderCallback = callback;
  }

  // 显示自动启动提醒
  void _showAutoStartReminder(TimerItem timer) {
    if (_autoStartReminderCallback != null) {
      _autoStartReminderCallback!(timer);
    }
  }
  // Getters
  TimerItem? get activeTimer => _activeTimer;
  TimerStatus get status => _status;
  Duration get remainingTime => _remainingTime;
  double get progress => _progress;
  bool get isRunning => _status == TimerStatus.running;
  bool get isPaused => _status == TimerStatus.paused;
  bool get isCompleted => _status == TimerStatus.completed;

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
  // 添加计时器
  void addTimer(TimerItem timer) {
    _timers.add(timer);
    
    // 设置提醒
    if (timer.isEnabled && timer.startTime != null) {
      _scheduleAutoStartReminder(timer);
    }
    
    // 保存计时器到本地
    _saveTimers();
    
    notifyListeners();
  }

void updateTimer(TimerItem updatedTimer) {
    final index = _timers.indexWhere((timer) => timer.id == updatedTimer.id);
    if (index != -1) {
      _timers[index] = updatedTimer;

      // 如果正在更新的是当前活动的计时器，则更新活动计时器
      if (_activeTimer != null && _activeTimer!.id == updatedTimer.id) {
        _activeTimer = updatedTimer;
        _remainingTime = updatedTimer.duration;
        _progress = 1.0;
      }
      
      // 重新设置提醒
      if (updatedTimer.isEnabled && updatedTimer.startTime != null) {
        _scheduleAutoStartReminder(updatedTimer);
      }

      // 保存计时器到本地
      _saveTimers();
      
      notifyListeners();
    }
  }

  // 删除计时器
  void deleteTimer(String id) {
    // 查找并删除指定ID的计时器
    _timers.removeWhere((timer) => timer.id == id);

    // 保存计时器到本地
    _saveTimers();
    
    // 通知监听器更新UI
    notifyListeners();
  }

  // 其他方法保持不变...
  // 例如 startTimer, pauseTimer, resumeTimer, stopTimer 等
  
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

  // 清除搜索
  void clearSearch() {
    if (_originalTimers.isNotEmpty) {
      _timers = List.from(_originalTimers);
      _originalTimers = [];
      notifyListeners();
    }
  }

  // 添加一个用于存储原始计时器列表的变量
  List<TimerItem> _originalTimers = [];

  // 移除计时器
  void removeTimer(String id) {
    // 如果要删除的是当前活动计时器，先停止它
    if (_activeTimer?.id == id) {
      stopTimer();
    }

    _timers.removeWhere((timer) => timer.id == id);
    notifyListeners();
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

        // 触发通知，播放铃声
        if (_activeTimer != null && _notificationProvider != null) {
          // 查找对应的声音
          final soundId = _activeTimer!.soundId;
          // 查找声音对象
          final sound = _notificationProvider!.availableSounds.firstWhere(
            (sound) => sound.id == soundId,
            orElse: () => _notificationProvider!.defaultSound,
          );

          // 播放声音
          _notificationProvider!.playSound(sound);

          // 触发通知 - 使用正确的方法
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
        _timers.sort(
          (a, b) =>
              ascending ? a.name.compareTo(b.name) : b.name.compareTo(a.name),
        );
        break;
      case 'duration':
        _timers.sort(
          (a, b) =>
              ascending
                  ? a.duration.compareTo(b.duration)
                  : b.duration.compareTo(a.duration),
        );
        break;
      case 'created':
        _timers.sort(
          (a, b) =>
              ascending
                  ? a.createdAt.compareTo(b.createdAt)
                  : b.createdAt.compareTo(a.createdAt),
        );
        break;
    }
    notifyListeners();
  }

  // 添加推迟计时器的方法
  void snoozeTimer(
    String timerId, {
    Duration snoozeDuration = const Duration(minutes: 10),
  }) {
    final index = _timers.indexWhere((timer) => timer.id == timerId);
    if (index != -1) {
      final timer = _timers[index];

      // 创建新的开始时间（当前时间 + 推迟时间）
      final newStartTime = DateTime.now().add(snoozeDuration);

      // 更新计时器
      final updatedTimer = timer.copyWith(startTime: newStartTime);
      _timers[index] = updatedTimer;

      // 如果是当前活动计时器，停止它
      if (_activeTimer?.id == timerId) {
        stopTimer();
      }

      // 重新设置提醒
      _scheduleAutoStartReminder(updatedTimer);

      notifyListeners();
    }
  }

  // 改进自动启动提醒方法，确保每次更新计时器时都会重新设置提醒
  void _scheduleAutoStartReminder(TimerItem timer) {
    if (timer.startTime == null || !timer.isEnabled) return;

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

      // 如果10秒后没有操作，自动开始计时器
      Timer(const Duration(seconds: 10), () {
        // 检查计时器是否仍然存在且未被手动启动
        final currentTimer = _timers.firstWhere(
          (t) => t.id == timer.id,
          orElse: () => timer,
        );

        if (currentTimer.isEnabled &&
            _activeTimer?.id != currentTimer.id &&
            currentTimer.startTime != null &&
            currentTimer.startTime!.difference(DateTime.now()).inSeconds <= 0) {
          startTimer(currentTimer.id);
        }
      });
    });
  }
}
