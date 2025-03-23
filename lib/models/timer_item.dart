class TimerItem {
  final String id;
  final String name;
  final Duration duration;
  final bool isEnabled;
  final String soundId;
  final DateTime createdAt;
  final DateTime? startTime;

  const TimerItem({
    required this.id,
    required this.name,
    required this.duration,
    required this.isEnabled,
    required this.soundId,
    required this.createdAt,
    this.startTime,
  });

  // 创建一个新的 TimerItem，但可以更改某些属性
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
      startTime: startTime,
    );
  }

  // 从 JSON 创建 TimerItem
  factory TimerItem.fromJson(Map<String, dynamic> json) {
    return TimerItem(
      id: json['id'] as String,
      name: json['name'] as String,
      duration: Duration(seconds: json['durationInSeconds'] as int),
      isEnabled: json['isEnabled'] as bool,
      soundId: json['soundId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      startTime: json['startTime'] != null 
          ? DateTime.parse(json['startTime'] as String) 
          : null,
    );
  }

  // 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'durationInSeconds': duration.inSeconds,
      'isEnabled': isEnabled,
      'soundId': soundId,
      'createdAt': createdAt.toIso8601String(),
      'startTime': startTime?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'TimerItem{id: $id, name: $name, duration: $duration, isEnabled: $isEnabled, soundId: $soundId, createdAt: $createdAt, startTime: $startTime}';
  }
}