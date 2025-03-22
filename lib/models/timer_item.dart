class TimerItem {
  final String id;
  final String name;
  final Duration duration;
  final bool isAutoStart;
  final String soundId;
  final DateTime createdAt;

  const TimerItem({
    required this.id,
    required this.name,
    required this.duration,
    this.isAutoStart = false,
    required this.soundId,
    required this.createdAt,
  });

  // 添加 copyWith 方法
  TimerItem copyWith({
    String? id,
    String? name,
    Duration? duration,
    bool? isAutoStart,
    String? soundId,
    DateTime? createdAt,
  }) {
    return TimerItem(
      id: id ?? this.id,
      name: name ?? this.name,
      duration: duration ?? this.duration,
      isAutoStart: isAutoStart ?? this.isAutoStart,
      soundId: soundId ?? this.soundId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}