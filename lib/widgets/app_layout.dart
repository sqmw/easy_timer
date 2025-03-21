import 'package:flutter/material.dart';

class AppLayout extends StatelessWidget {
  const AppLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 左侧导航栏
          NavigationRail(
            selectedIndex: 0,
            onDestinationSelected: (int index) {
              // TODO: 实现导航逻辑
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.timer),
                label: Text('倒计时'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.list),
                label: Text('倒计时列表'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.format_list_numbered),
                label: Text('数字倒计时风格'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.pie_chart),
                label: Text('图表倒计时风格'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.info),
                label: Text('关于'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('设置'),
              ),
            ],
          ),
          // 右侧内容区域
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              child: const Center(
                child: Text('Content Area'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}