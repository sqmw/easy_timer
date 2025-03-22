class TimerItem {
  final String id;
  final String name;
  final Duration duration;
  final bool isAutoStart;
  final String soundId;
  final DateTime createdAt;
  final DateTime? startTime; // 添加开始时间字段

  const TimerItem({
    required this.id,
    required this.name,
    required this.duration,
    this.isAutoStart = false,
    required this.soundId,
    required this.createdAt,
    this.startTime, // 开始时间可以为空
  });

  // 修改 copyWith 方法，添加 startTime 参数
  TimerItem copyWith({
    String? id,
    String? name,
    Duration? duration,
    bool? isAutoStart,
    String? soundId,
    DateTime? createdAt,
    DateTime? startTime,
  }) {
    return TimerItem(
      id: id ?? this.id,
      name: name ?? this.name,
      duration: duration ?? this.duration,
      isAutoStart: isAutoStart ?? this.isAutoStart,
      soundId: soundId ?? this.soundId,
      createdAt: createdAt ?? this.createdAt,
      startTime: startTime ?? this.startTime,
    );
  }
}