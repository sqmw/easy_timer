class TimerItem {
  final String id;
  final String name;
  final Duration duration;
  final bool isAutoStart;
  final String soundId;
  final DateTime createdAt;
  
  TimerItem({
    required this.id,
    required this.name,
    required this.duration,
    this.isAutoStart = false,
    required this.soundId,
    required this.createdAt,
  });
}