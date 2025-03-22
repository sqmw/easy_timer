class TimerItem {
  final String id;
  final String name;
  final Duration duration;
  final bool isEnabled; // 修改属性名
  final String soundId;
  final DateTime createdAt;
  final DateTime? startTime; // 添加开始时间

  TimerItem({
    required this.id,
    required this.name,
    required this.duration,
    this.isEnabled = false, // 修改属性名
    required this.soundId,
    required this.createdAt,
    this.startTime,
  });
  
  // 添加 copyWith 方法
  TimerItem copyWith({
    String? id,
    String? name,
    Duration? duration,
    bool? isEnabled,
    String? soundId,
    DateTime? createdAt,
    DateTime? startTime,
  }) {
    return TimerItem(
      id: id ?? this.id,
      name: name ?? this.name,
      duration: duration ?? this.duration,
      isEnabled: isEnabled ?? this.isEnabled,
      soundId: soundId ?? this.soundId,
      createdAt: createdAt ?? this.createdAt,
      startTime: startTime ?? this.startTime,
    );
  }
}