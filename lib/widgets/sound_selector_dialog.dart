import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:easy_timer/providers/notification_provider.dart';

class SoundSelectorDialog extends StatefulWidget {
  final String initialSoundId;
  final Function(String) onSoundSelected;

  const SoundSelectorDialog({
    Key? key,
    required this.initialSoundId,
    required this.onSoundSelected,
  }) : super(key: key);

  @override
  State<SoundSelectorDialog> createState() => _SoundSelectorDialogState();
}

class _SoundSelectorDialogState extends State<SoundSelectorDialog> {
  late String _selectedSoundId;
  AudioPlayer? _previewPlayer;
  String? _playingSoundId;

  @override
  void initState() {
    super.initState();
    _selectedSoundId = widget.initialSoundId;
  }

  @override
  void dispose() {
    // 关闭对话框时停止声音预览
    _stopPreview();
    super.dispose();
  }

  // 播放声音预览
  void _playPreview(String soundId) {
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    
    // 如果当前有声音在播放，先停止
    _stopPreview();
    
    // 播放新的声音
    _previewPlayer = notificationProvider.previewSound(soundId);
    
    // 使用 Future.microtask 确保在下一个微任务中更新状态
    Future.microtask(() {
      if (mounted) {
        setState(() {
          _playingSoundId = soundId;
        });
      }
    });
  }

  // 停止声音预览
  void _stopPreview() {
    if (_previewPlayer != null) {
      _previewPlayer!.stop();
      _previewPlayer!.dispose();
      _previewPlayer = null;
      
      // 使用 Future.microtask 确保在下一个微任务中更新状态
      Future.microtask(() {
        if (mounted) {
          setState(() {
            _playingSoundId = null;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final sounds = notificationProvider.availableSounds;
    
    return AlertDialog(
      title: const Text('选择提醒声音'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: sounds.length,
          itemBuilder: (context, index) {
            final sound = sounds[index];
            final isSelected = sound.id == _selectedSoundId;
            final isPlaying = sound.id == _playingSoundId;
            
            return ListTile(
              leading: Icon(sound.icon),
              title: Text(sound.name),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 试听按钮
                  IconButton(
                    icon: Icon(
                      isPlaying ? Icons.stop : Icons.play_arrow,
                      color: isPlaying ? Colors.red : null,
                    ),
                    onPressed: () {
                      if (isPlaying) {
                        _stopPreview();
                      } else {
                        _playPreview(sound.id);
                      }
                    },
                  ),
                  // 选择指示器
                  if (isSelected)
                    const Icon(Icons.check, color: Colors.green),
                ],
              ),
              selected: isSelected,
              onTap: () {
                setState(() {
                  _selectedSoundId = sound.id;
                });
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSoundSelected(_selectedSoundId);
            Navigator.of(context).pop();
          },
          child: const Text('确定'),
        ),
      ],
    );
  }
}