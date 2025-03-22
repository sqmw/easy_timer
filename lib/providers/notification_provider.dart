import 'package:easy_timer/const/assets.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

class Sound {
  final String id;
  final String name;
  final String assetPath;
  final IconData icon;

  const Sound({
    required this.id,
    required this.name,
    required this.assetPath,
    this.icon = Icons.music_note, // 提供默认图标
  });
}

class NotificationProvider extends ChangeNotifier {
  static const String _soundKey = 'default_sound';

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _desktopNotificationEnabled = true;
  bool _popupEnabled = true;
  double _volume = 0.7;
  Sound _defaultSound = const Sound(
    id: 'bell',
    name: '清脆铃声',
    assetPath: Assets.assets_sounds_bell_mp3,
    icon: Icons.notifications_active,
  );

  // 添加这些 getter
  bool get desktopNotificationEnabled => _desktopNotificationEnabled;
  bool get popupEnabled => _popupEnabled;
  double get volume => _volume;
  Sound get defaultSound => _defaultSound;

  final List<Sound> _availableSounds = const [
    Sound(
      id: 'bell',
      name: '清脆铃声',
      assetPath: Assets.assets_sounds_bell_mp3,
      icon: Icons.notifications_active,
    ),
    Sound(
      id: 'digital',
      name: '数字提示音',
      assetPath: Assets.assets_sounds_digital_mp3,
      icon: Icons.watch,
    ),
    Sound(
      id: 'gentle',
      name: '温和提醒',
      assetPath: Assets.assets_sounds_gentle_mp3,
      icon: Icons.waves,
    ),
    Sound(
      id: 'nature',
      name: '自然之声',
      assetPath: Assets.assets_sounds_nature_mp3,
      icon: Icons.nature,
    ),
    Sound(
      id: 'alert',
      name: '警报声',
      assetPath: Assets.assets_sounds_alert_mp3,
      icon: Icons.warning_amber,
    ),
  ];

  List<Sound> get availableSounds => _availableSounds;

  NotificationProvider() {
    _loadSettings();
  }

  // 设置桌面通知
  Future<void> setDesktopNotificationEnabled(bool enabled) async {
    if (_desktopNotificationEnabled == enabled) return;

    _desktopNotificationEnabled = enabled;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('desktop_notification_enabled', enabled);

    notifyListeners();
  }

  // 设置弹窗提醒
  Future<void> setPopupEnabled(bool enabled) async {
    if (_popupEnabled == enabled) return;

    _popupEnabled = enabled;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('popup_enabled', enabled);

    notifyListeners();
  }

  // 设置音量
  Future<void> setVolume(double value) async {
    if (_volume == value) return;

    _volume = value;
    _audioPlayer.setVolume(value);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('sound_volume', value);

    notifyListeners();
  }

  // 加载设置
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // 加载通知设置
    _desktopNotificationEnabled =
        prefs.getBool('desktop_notification_enabled') ?? true;
    _popupEnabled = prefs.getBool('popup_enabled') ?? true;
    _volume = prefs.getDouble('sound_volume') ?? 0.7;

    // 设置音频播放器音量
    _audioPlayer.setVolume(_volume);

    // 加载默认铃声
    final soundId = prefs.getString(_soundKey) ?? 'bell';
    _defaultSound = _availableSounds.firstWhere(
      (sound) => sound.id == soundId,
      orElse: () => _availableSounds.first,
    );

    notifyListeners();
  }

  // 触发通知
  Future<void> triggerNotification() async {
    // 播放声音
    await playSound(_defaultSound);

    // 如果启用了桌面通知，则显示通知
    if (_desktopNotificationEnabled) {
      // 桌面通知逻辑
    }

    // 如果启用了弹窗，则显示弹窗
    if (_popupEnabled) {
      // 弹窗逻辑
    }
  }

  // 设置默认铃声
  Future<void> setDefaultSound(Sound sound) async {
    if (_defaultSound.id == sound.id) return;

    _defaultSound = sound;
    notifyListeners(); // 立即通知界面更新

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_soundKey, sound.id);
  }

  // 播放声音
  Sound? _playingSound;

  // 添加这个方法来检查指定的声音是否正在播放
  bool isPlayingSound(Sound sound) {
    return _playingSound?.id == sound.id;
  }

  // 修改播放声音的方法
  Future<void> playSound(Sound sound) async {
    if (_playingSound?.id == sound.id) {
      await stopSound();
      return;
    }

    await stopSound();
    _playingSound = sound;

    // 检查路径是否已经包含 'assets/' 前缀，如果包含则直接使用，否则添加前缀
    final String path =
        sound.assetPath.startsWith('assets/')
            ? sound.assetPath.substring(7) // 移除开头的 'assets/'
            : sound.assetPath;
    await _audioPlayer.play(AssetSource(path));
    print(path);
    notifyListeners();
  }

  // 添加停止播放的方法
  Future<void> stopSound() async {
    if (_playingSound != null) {
      await _audioPlayer.stop();
      _playingSound = null;
      notifyListeners();
    }
  }

  // 添加预览声音的方法
  // 在 NotificationProvider 类中修改 previewSound 方法
  AudioPlayer previewSound(String soundId) {
    // 查找对应的声音
    final sound = _availableSounds.firstWhere(
      (sound) => sound.id == soundId,
      orElse: () => _defaultSound,
    );
    // 创建一个新的播放器实例
    final player = AudioPlayer();
    try {
      // 修改这里：使用正确的资源路径格式
      // 从 Assets 类获取的路径已经包含 'assets/' 前缀
      // 但 AudioPlayer.play(AssetSource()) 会再添加一次
      // 所以需要移除路径中的 'assets/' 前缀
      String assetPath = sound.assetPath;
      if (assetPath.startsWith('assets/')) {
        assetPath = assetPath.substring(7); // 移除 'assets/' 前缀
      }
      player.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('播放声音预览失败: $e');
    }
    return player;
  }

  @override
  void dispose() {
    stopSound();
    _audioPlayer.dispose();
    super.dispose();
  }
}
