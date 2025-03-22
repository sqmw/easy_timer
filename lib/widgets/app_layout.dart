import 'package:flutter/material.dart';
import 'package:easy_timer/pages/timer/timer_page.dart';
import 'package:easy_timer/pages/timer_list/timer_list_page.dart';
import 'package:easy_timer/pages/number_style/number_style_page.dart';
import 'package:easy_timer/pages/chart_style/chart_style_page.dart';
import 'package:easy_timer/pages/about/about_page.dart';
import 'package:easy_timer/pages/settings/settings_page.dart';

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
    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              // 左侧导航栏
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
                backgroundColor: const Color(0xFF9683EC),
                useIndicator: true,
                indicatorColor: Colors.white.withAlpha(38),
                indicatorShape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                ),
                selectedIconTheme: const IconThemeData(
                  color: Colors.white,
                  size: 24,
                ),
                unselectedIconTheme: const IconThemeData(
                  color: Color(0xFFE6E1FB),
                  size: 22,
                ),
                selectedLabelTextStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500, // 稍微加粗
                  letterSpacing: 0.2, // 轻微增加字间距
                ),
                unselectedLabelTextStyle: const TextStyle(
                  color: Color(0xFFE6E1FB),
                  fontSize: 16,
                ),
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
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x209683EC),
                        Color(0xFF9683EC),
                        Color(0x209683EC),
                      ],
                    ),
                  ),
                ),
              // 修改 Expanded 中的内容
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF2D2B52), Color(0xFF1F1D36)],
                    ),
                  ),
                  child: _pages[_selectedIndex],
                ),
              ),
            ],
          ),
          // 收缩按钮
          Positioned(
            left: _isExtended ? 205 : 85,
            top: 12,
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(
                _isExtended ? Icons.chevron_left : Icons.chevron_right,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () {
                setState(() {
                  _isExtended = !_isExtended;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
