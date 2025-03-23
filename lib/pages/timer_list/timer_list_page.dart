import 'package:easy_timer/pages/timer_detail/timer_detail_page.dart';
import 'package:easy_timer/pages/timer_edit/timer_edit_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_timer/providers/timer_provider.dart';
import 'package:easy_timer/widgets/timer_list_item.dart';

class TimerListPage extends StatelessWidget {
  const TimerListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // 添加搜索控制器
    final searchController = TextEditingController();

    /// 如果放在 StateBuilder下面，会导致排序按钮该状态随着刷新变化
    bool isAscending = true;
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
                                listen: false
                              ).searchTimers(searchText);
                            } else {
                              // 如果搜索框为空，则重置搜索结果
                              Provider.of<TimerProvider>(
                                context, 
                                listen: false
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
                              listen: false
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
                            listen: false
                          ).searchTimers(value);
                        } else {
                          Provider.of<TimerProvider>(
                            context, 
                            listen: false
                          ).resetSearch();
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                StatefulBuilder(
                  builder: (context, setState) {
                    String currentSortBy = 'created'; // 默认按创建时间排序
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
                        // 删除逻辑保持不变
                        // ...
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
}
