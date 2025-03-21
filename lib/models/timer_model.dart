class TimerModel {
  final String id;
  final String name;
  final Duration duration;
  final String soundPath;
  final bool isAutoStart;
  bool isRunning;
  bool isPaused;

  TimerModel({
    required this.id,
    required this.name,
    required this.duration,
    this.soundPath = '',
    this.isAutoStart = false,
    this.isRunning = false,
    this.isPaused = false,
  });

  TimerModel copyWith({
    String? id,
    String? name,
    Duration? duration,
    String? soundPath,
    bool? isAutoStart,
    bool? isRunning,
    bool? isPaused,
  }) {
    return TimerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      duration: duration ?? this.duration,
      soundPath: soundPath ?? this.soundPath,
      isAutoStart: isAutoStart ?? this.isAutoStart,
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
    );
  }
}