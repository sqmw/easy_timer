import 'package:easy_timer/widgets/sound_selector_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_timer/models/timer_item.dart';
import 'package:easy_timer/providers/timer_provider.dart';
import 'package:easy_timer/providers/notification_provider.dart';

class TimerEditPage extends StatefulWidget {
  final TimerItem? timer; // 如果为null则表示新建，否则为编辑

  const TimerEditPage({super.key, this.timer});

  @override
  State<TimerEditPage> createState() => _TimerEditPageState();
}

class _TimerEditPageState extends State<TimerEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  
  // 时间控制器
  late int _hours;
  late int _minutes;
  late int _seconds;
  
  // 自动开始
  late bool _isAutoStart;
  
  // 声音ID
  late String _soundId;

  @override
  void initState() {
    super.initState();
    
    // 初始化控制器和状态
    final timer = widget.timer;
    if (timer != null) {
      // 编辑模式
      _nameController = TextEditingController(text: timer.name);
      _hours = timer.duration.inHours;
      _minutes = (timer.duration.inMinutes % 60);
      _seconds = (timer.duration.inSeconds % 60);
      _isAutoStart = timer.isAutoStart;
      _soundId = timer.soundId;
    } else {
      // 新建模式
      _nameController = TextEditingController(text: '');
      _hours = 0;
      _minutes = 5; // 默认5分钟
      _seconds = 0;
      _isAutoStart = false;
      
      // 获取默认声音ID
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      _soundId = notificationProvider.defaultSound.id;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // 保存计时器
  void _saveTimer() {
    if (_formKey.currentState!.validate()) {
      final timerProvider = Provider.of<TimerProvider>(context, listen: false);
      
      // 计算总时长
      final duration = Duration(
        hours: _hours,
        minutes: _minutes,
        seconds: _seconds,
      );
      
      if (widget.timer == null) {
        // 创建新计时器
        timerProvider.createTimer(
          name: _nameController.text,
          duration: duration,
          isAutoStart: _isAutoStart,
          soundId: _soundId,
        );
      } else {
        // 更新现有计时器
        final updatedTimer = widget.timer!.copyWith(
          name: _nameController.text,
          duration: duration,
          isAutoStart: _isAutoStart,
          soundId: _soundId,
        );
        timerProvider.updateTimer(updatedTimer);
      }
      
      // 返回上一页
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.timer == null ? '新建计时器' : '编辑计时器'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveTimer,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 名称输入
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '计时器名称',
                      hintText: '输入计时器名称',
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入计时器名称';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 时间设置
                  Text('时长设置', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 小时
                      Column(
                        children: [
                          const Text('小时'),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 80,
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Column(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.arrow_upward),
                                      onPressed: () {
                                        setState(() {
                                          _hours = (_hours + 1) % 24;
                                        });
                                      },
                                    ),
                                    Text(
                                      '$_hours',
                                      style: theme.textTheme.headlineMedium,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.arrow_downward),
                                      onPressed: () {
                                        setState(() {
                                          _hours = (_hours - 1 + 24) % 24;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      // 分钟
                      Column(
                        children: [
                          const Text('分钟'),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 80,
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Column(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.arrow_upward),
                                      onPressed: () {
                                        setState(() {
                                          _minutes = (_minutes + 1) % 60;
                                        });
                                      },
                                    ),
                                    Text(
                                      '$_minutes',
                                      style: theme.textTheme.headlineMedium,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.arrow_downward),
                                      onPressed: () {
                                        setState(() {
                                          _minutes = (_minutes - 1 + 60) % 60;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      // 秒钟
                      Column(
                        children: [
                          const Text('秒钟'),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 80,
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Column(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.arrow_upward),
                                      onPressed: () {
                                        setState(() {
                                          _seconds = (_seconds + 1) % 60;
                                        });
                                      },
                                    ),
                                    Text(
                                      '$_seconds',
                                      style: theme.textTheme.headlineMedium,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.arrow_downward),
                                      onPressed: () {
                                        setState(() {
                                          _seconds = (_seconds - 1 + 60) % 60;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 自动开始开关
                  SwitchListTile(
                    title: const Text('自动开始'),
                    value: _isAutoStart,
                    onChanged: (value) {
                      setState(() {
                        _isAutoStart = value;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 声音选择
                  Text('提醒声音', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  
                  // 替换原来的下拉菜单为自定义选择器
                  Builder(
                    builder: (context) {
                      // 获取当前选择的声音
                      final currentSound = notificationProvider.availableSounds.firstWhere(
                        (sound) => sound.id == _soundId,
                        orElse: () => notificationProvider.defaultSound,
                      );
                      
                      return ListTile(
                        leading: Icon(currentSound.icon),
                        title: Text(currentSound.name),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Theme.of(context).dividerColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        onTap: () async {
                          // 显示声音选择对话框
                          showDialog(
                            context: context,
                            builder: (context) => SoundSelectorDialog(
                              initialSoundId: _soundId,
                              onSoundSelected: (soundId) {
                                setState(() {
                                  _soundId = soundId;
                                });
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            
            // 添加底部保存按钮
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _saveTimer,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('保存', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}