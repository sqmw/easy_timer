import 'package:flutter/material.dart';
import 'package:easy_timer/pages/timer/timer_page.dart';
import 'package:easy_timer/pages/timer_list/timer_list_page.dart';
import 'package:easy_timer/pages/number_style/number_style_page.dart';
import 'package:easy_timer/pages/chart_style/chart_style_page.dart';
import 'package:easy_timer/pages/about/about_page.dart';
import 'package:easy_timer/pages/settings/settings_page.dart';
import 'package:provider/provider.dart';
import 'package:easy_timer/providers/theme_provider.dart';

class AppLayout extends StatefulWidget {
  const AppLayout({super.key});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  bool _isExtended = true;
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    TimerPage(),
    TimerListPage(),
    NumberStylePage(),
    ChartStylePage(),
    AboutPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    // 获取当前主题
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              // 左侧导航栏 - 使用主题颜色
              NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (int index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                extended: _isExtended,
                minWidth: 80,
                minExtendedWidth: 200,
                // 使用主题颜色
                backgroundColor: theme.colorScheme.primary,
                useIndicator: true,
                // 使用主题中定义的指示器颜色
                indicatorColor: theme.navigationRailTheme.indicatorColor,
                indicatorShape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                ),
                // 使用主题中定义的图标主题
                selectedIconTheme: theme.navigationRailTheme.selectedIconTheme,
                unselectedIconTheme:
                    theme.navigationRailTheme.unselectedIconTheme,
                // 使用主题中定义的文本样式
                selectedLabelTextStyle:
                    theme.navigationRailTheme.selectedLabelTextStyle,
                unselectedLabelTextStyle:
                    theme.navigationRailTheme.unselectedLabelTextStyle,
                destinations: const [
                  NavigationRailDestination(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    icon: Icon(Icons.timer),
                    label: Text('倒计时'),
                  ),
                  NavigationRailDestination(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    icon: Icon(Icons.list),
                    label: Text('倒计时列表'),
                  ),
                  NavigationRailDestination(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    icon: Icon(Icons.format_list_numbered),
                    label: Text('数字倒计时风格'),
                  ),
                  NavigationRailDestination(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    icon: Icon(Icons.pie_chart),
                    label: Text('图表倒计时风格'),
                  ),
                  NavigationRailDestination(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    icon: Icon(Icons.info),
                    label: Text('关于'),
                  ),
                  NavigationRailDestination(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    icon: Icon(Icons.settings),
                    label: Text('设置'),
                  ),
                ],
              ),
              if (_isExtended)
                Container(
                  width: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.2),
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withOpacity(0.2),
                      ],
                    ),
                  ),
                ),
              // 修改内容区域，使用与设置页面一致的风格
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    // 使用主题提供者中定义的背景色
                    color: themeProvider.currentBackgroundColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: _pages[_selectedIndex],
                  ),
                ),
              ),
            ],
          ),
          // 收缩按钮 - 使用主题颜色
          Positioned(
            left: _isExtended ? 205 : 85,
            top: 12,
            child: Card(
              color: theme.colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 4.0,
              child: InkWell(
                borderRadius: BorderRadius.circular(12.0),
                onTap: () {
                  setState(() {
                    _isExtended = !_isExtended;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    _isExtended ? Icons.chevron_left : Icons.chevron_right,
                    color: theme.navigationRailTheme.selectedIconTheme?.color,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
