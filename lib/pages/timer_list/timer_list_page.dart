import 'package:easy_timer/pages/timer_detail/timer_detail_page.dart';
import 'package:easy_timer/pages/timer_edit/timer_edit_page.dart';
import 'package:easy_timer/widgets/custom_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_timer/providers/timer_provider.dart';
import 'package:easy_timer/widgets/timer_list_item.dart';
import 'package:easy_timer/providers/notification_provider.dart';
import 'package:easy_timer/models/timer_item.dart';

class TimerListPage extends StatefulWidget {
  const TimerListPage({super.key});

  @override
  State<TimerListPage> createState() => _TimerListPageState();
}

class _TimerListPageState extends State<TimerListPage> {
  final searchController = TextEditingController();
  bool isAscending = true;
  String currentSortBy = 'created';
  // Add a reference to store the TimerProvider
  late TimerProvider _timerProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Safely get the provider reference when dependencies change
    _timerProvider = Provider.of<TimerProvider>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();

    // 设置自动启动提醒回调
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _timerProvider.setAutoStartReminderCallback(_showAutoStartReminderDialog);

      // 监听计时器完成事件
      _timerProvider.addListener(_handleTimerStateChange);
    });
  }

  @override
  void dispose() {
    // 移除监听器 - use the stored reference instead of Provider.of
    _timerProvider.removeListener(_handleTimerStateChange);
    searchController.dispose();
    super.dispose();
  }

  // 处理计时器状态变化
  void _handleTimerStateChange() {
    final timerProvider = Provider.of<TimerProvider>(context, listen: false);

    // 如果计时器完成，显示完成对话框
    if (timerProvider.isCompleted && timerProvider.activeTimer != null) {
      _showCompletionDialog(context, timerProvider.activeTimer!);
    }
  }

  // 显示自动启动提醒对话框
  void _showAutoStartReminderDialog(TimerItem timer) {
    final theme = Theme.of(context);

    // 使用自定义对话框显示提醒
    CustomAlertDialog.show(
      context: context,
      barrierDismissible: false, // 防止点击外部关闭对话框
      title: '计时器即将开始',
      titleIcon: Icons.timer,
      titleIconColor: theme.colorScheme.primary,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '计时器 "${timer.name}" 将在10秒后自动开始',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '时长: ${_formatDuration(timer.duration)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // 关闭对话框
            // 推迟10分钟
            Provider.of<TimerProvider>(
              context,
              listen: false,
            ).snoozeTimer(timer.id);

            // 显示推迟提示
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('已推迟10分钟'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.snooze, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              const Text('推迟10分钟'),
            ],
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop(); // 关闭对话框
            // 立即开始
            Provider.of<TimerProvider>(
              context,
              listen: false,
            ).startTimer(timer.id);
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.play_arrow,
                size: 20,
                color: theme.colorScheme.onPrimary,
              ),
              const SizedBox(width: 8),
              const Text('立即开始'),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          // 顶部搜索和排序区域
          Padding(
            padding: const EdgeInsets.fromLTRB(
              56,
              16,
              16,
              16,
            ), // 修改左边距，为侧边栏按钮留出空间
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: TextField(
                      controller: searchController, // 添加控制器
                      decoration: InputDecoration(
                        hintText: '搜索倒计时...',
                        hintStyle: TextStyle(
                          fontSize: 14, // 减小提示文字大小
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        prefixIcon: IconButton(
                          onPressed: () {
                            // 获取搜索框中的文本，并执行搜索
                            final searchText = searchController.text.trim();
                            if (searchText.isNotEmpty) {
                              Provider.of<TimerProvider>(
                                context,
                                listen: false,
                              ).searchTimers(searchText);
                            } else {
                              // 如果搜索框为空，则重置搜索结果
                              Provider.of<TimerProvider>(
                                context,
                                listen: false,
                              ).resetSearch();
                            }
                          },
                          icon: Icon(
                            Icons.search,
                            size: 20, // 减小图标大小
                          ),
                        ),
                        // 添加清除按钮
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            searchController.clear();
                            Provider.of<TimerProvider>(
                              context,
                              listen: false,
                            ).resetSearch();
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8), // 减小圆角
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline,
                            width: 1,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, // 减小水平内边距
                          vertical: 8, // 减小垂直内边距
                        ),
                      ),
                      style: const TextStyle(fontSize: 14), // 减小输入文字大小
                      // 添加输入监听，实现实时搜索
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          Provider.of<TimerProvider>(
                            context,
                            listen: false,
                          ).searchTimers(value);
                        } else {
                          Provider.of<TimerProvider>(
                            context,
                            listen: false,
                          ).resetSearch();
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                StatefulBuilder(
                  builder: (context, setState) {
                    return Row(
                      children: [
                        // 排序方式选择
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.sort),
                          tooltip: '排序方式',
                          itemBuilder:
                              (context) => [
                                const PopupMenuItem(
                                  value: 'name',
                                  child: Text('按名称排序'),
                                ),
                                const PopupMenuItem(
                                  value: 'duration',
                                  child: Text('按时长排序'),
                                ),
                                const PopupMenuItem(
                                  value: 'created',
                                  child: Text('按创建时间排序'),
                                ),
                              ],
                          onSelected: (value) {
                            setState(() {
                              currentSortBy = value;
                            });
                            // 执行排序
                            Provider.of<TimerProvider>(
                              context,
                              listen: false,
                            ).sortTimers(value, isAscending);
                          },
                        ),

                        // 排序方向切换按钮
                        IconButton(
                          icon: Icon(
                            isAscending
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                          ),
                          tooltip: isAscending ? '升序' : '降序',
                          onPressed: () {
                            setState(() {
                              isAscending = !isAscending;
                            });
                            // 执行排序
                            Provider.of<TimerProvider>(
                              context,
                              listen: false,
                            ).sortTimers(currentSortBy, isAscending);
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // 计时器列表
          Expanded(
            child: Consumer<TimerProvider>(
              builder: (context, provider, child) {
                if (provider.timers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 64,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '还没有创建任何倒计时',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: provider.timers.length,
                  itemBuilder: (context, index) {
                    final timer = provider.timers[index];

                    // 在 timer_list_page.dart 中修改 onTap 回调
                    // 找到 TimerListItem 的创建部分
                    return TimerListItem(
                      timer: timer,
                      onTap: () {
                        // 修改为导航到 TimerDetailPage
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => TimerDetailPage(timer: timer),
                          ),
                        );
                      },
                      onEdit: () {
                        // 导航到编辑页面
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => TimerEditPage(timer: timer),
                          ),
                        );
                      },
                      onDelete: () {
                        // 使用自定义对话框
                        _showDeleteConfirmDialog(context, provider, timer);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // 添加新计时器的浮动按钮
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 跳转到新建计时器页面
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => const TimerEditPage(), // TimerEditPage 已经包含保存按钮
            ),
          );
        },
        tooltip: '新建计时器', // 添加提示文本
        child: const Icon(Icons.add),
      ),
    );
  }

  // 显示删除确认对话框
  void _showDeleteConfirmDialog(
    BuildContext context,
    TimerProvider provider,
    timer,
  ) {
    final theme = Theme.of(context);

    CustomAlertDialog.show(
      context: context,
      title: '删除计时器',
      titleIcon: Icons.delete_outline,
      titleIconColor: theme.colorScheme.error,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('确定要删除"${timer.name}"吗？', style: theme.textTheme.bodyLarge),
          const SizedBox(height: 8),
          Text(
            '此操作无法撤销',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error.withOpacity(0.8),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // 关闭对话框
          },
          child: const Text('取消'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            provider.deleteTimer(timer.id);
            Navigator.of(context).pop(); // 关闭对话框
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.delete_outline, size: 20),
              const SizedBox(width: 8),
              const Text('删除'),
            ],
          ),
        ),
      ],
    );
  }

  // 添加计时器完成对话框
  void _showCompletionDialog(BuildContext context, TimerItem timer) {
    final theme = Theme.of(context);

    CustomAlertDialog.show(
      context: context,
      barrierDismissible: false,
      title: '计时完成',
      titleIcon: Icons.notifications_active,
      titleIconColor: theme.colorScheme.primary,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('您设置的倒计时已完成', style: theme.textTheme.bodyLarge),
          const SizedBox(height: 8),
          Text(
            '总时长: ${_formatDuration(timer.duration)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            // 推迟10分钟
            Provider.of<TimerProvider>(
              context,
              listen: false,
            ).snoozeTimer(timer.id);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('已推迟10分钟'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.snooze, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              const Text('推迟10分钟'),
            ],
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            // 停止声音播放
            Provider.of<NotificationProvider>(
              context,
              listen: false,
            ).stopSound();
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 20,
                color: theme.colorScheme.onPrimary,
              ),
              const SizedBox(width: 8),
              const Text('确认'),
            ],
          ),
        ),
      ],
    );
  }

  // 格式化时间显示
  String _formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    final parts = <String>[];
    if (days > 0) parts.add('$days天');
    if (hours > 0) parts.add('$hours小时');
    if (minutes > 0) parts.add('$minutes分钟');
    if (seconds > 0) parts.add('$seconds秒');

    return parts.isEmpty ? '0秒' : parts.join(' ');
  }
}
