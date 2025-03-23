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
  late bool _isEnabled;

  // 声音ID
  late String _soundId;

  // 添加开始时间相关变量
  // 在 _TimerEditPageState 类中添加以下变量
  late DateTime? _startTime;

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
      _isEnabled = timer.isEnabled;
      _soundId = timer.soundId;
      _startTime = timer.startTime;
    } else {
      // 新建模式
      _nameController = TextEditingController(text: '');
      _hours = 0;
      _minutes = 5; // 默认5分钟
      _seconds = 0;
      _isEnabled = false;
      _startTime = null;

      // 获取默认声音ID
      final notificationProvider = Provider.of<NotificationProvider>(
        context,
        listen: false,
      );
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

      // 只有在自动启动开启时才使用开始时间
      final startTime = _isEnabled ? _startTime : null;

      if (widget.timer == null) {
        // 创建新计时器
        timerProvider.createTimer(
          name: _nameController.text,
          duration: duration,
          isEnabled: _isEnabled,
          soundId: _soundId,
          startTime: startTime,
        );
      } else {
        // 更新现有计时器
        final updatedTimer = widget.timer!.copyWith(
          name: _nameController.text,
          duration: duration,
          isEnabled: _isEnabled,
          soundId: _soundId,
          startTime: startTime,
        );
        timerProvider.updateTimer(updatedTimer);
      }

      // 返回上一页
      Navigator.of(context).pop();
    }
  }

  // 选择开始时间的方法
  Future<void> _selectStartTime() async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = _startTime ?? now;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final TimeOfDay initialTime =
          _startTime != null
              ? TimeOfDay.fromDateTime(_startTime!)
              : TimeOfDay.now();

      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: initialTime,
      );

      if (pickedTime != null) {
        setState(() {
          _startTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
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
          IconButton(icon: const Icon(Icons.check), onPressed: _saveTimer),
        ],
      ),
      body: SafeArea(  // 添加 SafeArea 包裹内容
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),  // 调整内边距
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

                    const SizedBox(height: 20),  // 减小间距

                    // 时间设置
                    Text('时长设置', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),

                    // 修改时间选择器布局，使其更紧凑
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // 小时
                        _buildTimeSelector('小时', _hours, (value) => setState(() => _hours = value), 24),
                        // 分钟
                        _buildTimeSelector('分钟', _minutes, (value) => setState(() => _minutes = value), 60),
                        // 秒钟
                        _buildTimeSelector('秒钟', _seconds, (value) => setState(() => _seconds = value), 60),
                      ],
                    ),

                    const SizedBox(height: 20),  // 减小间距

                    // 自动开始开关
                    SwitchListTile(
                      title: const Text('是否启用'),
                      subtitle: const Text('启用后系统将实时统计计时器状态'),
                      value: _isEnabled,
                      onChanged: (value) {
                        setState(() {
                          _isEnabled = value;
                        });
                      },
                    ),

                    // 开始时间选择
                    if (_isEnabled)  // 只在启用时显示开始时间选择
                      ListTile(
                        title: const Text('开始时间'),
                        subtitle: Text(
                          _startTime != null
                              ? '${_startTime!.year}-${_startTime!.month.toString().padLeft(2, '0')}-${_startTime!.day.toString().padLeft(2, '0')} ${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}'
                              : '保存后立即开始',
                        ),
                        trailing: const Icon(Icons.access_time),
                        onTap: _selectStartTime,
                      ),

                    const SizedBox(height: 16),

                    // 声音选择
                    Text('提醒声音', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),

                    // 声音选择器
                    Builder(
                      builder: (context) {
                        // 获取当前选择的声音
                        final currentSound = notificationProvider.availableSounds
                            .firstWhere(
                              (sound) => sound.id == _soundId,
                              orElse: () => notificationProvider.defaultSound,
                            );

                        return ListTile(
                          leading: Icon(currentSound.icon),
                          title: Text(currentSound.name),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: Theme.of(context).dividerColor,
                            ),
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
      ),
    );
  }
  
  // 添加一个辅助方法来创建时间选择器，减少重复代码
  Widget _buildTimeSelector(String label, int value, Function(int) onChanged, int maxValue) {
    return Column(
      children: [
        Text(label),
        const SizedBox(height: 4),  // 减小间距
        SizedBox(
          width: 70,  // 减小宽度
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),  // 减小内边距
              child: Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_upward, size: 20),  // 减小图标
                    padding: const EdgeInsets.all(4),  // 减小内边距
                    constraints: const BoxConstraints(),  // 移除默认约束
                    onPressed: () {
                      onChanged((value + 1) % maxValue);
                    },
                  ),
                  Text(
                    '$value',
                    style: Theme.of(context).textTheme.titleLarge,  // 使用较小的文本样式
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_downward, size: 20),  // 减小图标
                    padding: const EdgeInsets.all(4),  // 减小内边距
                    constraints: const BoxConstraints(),  // 移除默认约束
                    onPressed: () {
                      onChanged((value - 1 + maxValue) % maxValue);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
