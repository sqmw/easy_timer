import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_timer/providers/timer_provider.dart';
import 'package:easy_timer/widgets/timer_list_item.dart';

class TimerListPage extends StatelessWidget {
  const TimerListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Column(
        children: [
          // 顶部搜索和排序区域
          Padding(
            padding: const EdgeInsets.fromLTRB(56, 16, 16, 16),  // 修改左边距，为侧边栏按钮留出空间
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: '搜索倒计时...',
                        hintStyle: TextStyle(
                          fontSize: 14,  // 减小提示文字大小
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          size: 20,  // 减小图标大小
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),  // 减小圆角
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline,
                            width: 1,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,  // 减小水平内边距
                          vertical: 8,    // 减小垂直内边距
                        ),
                      ),
                      style: const TextStyle(fontSize: 14),  // 减小输入文字大小
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.sort),
                  tooltip: '排序',
                  itemBuilder: (context) => [
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
                    // TODO: 实现排序功能
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
                    return TimerListItem(
                      timer: timer,
                      onTap: () {
                        // TODO: 跳转到编辑页面
                      },
                      onDelete: () {
                        // TODO: 删除确认对话框
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
          // TODO: 跳转到新建计时器页面
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}