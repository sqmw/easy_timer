import 'package:flutter/material.dart';
import 'package:easy_timer/pages/timer/timer_page.dart';
import 'package:easy_timer/pages/timer_list/timer_list_page.dart';
import 'package:easy_timer/pages/number_style/number_style_page.dart';
import 'package:easy_timer/pages/chart_style/chart_style_page.dart';
import 'package:easy_timer/pages/about/about_page.dart';
import 'package:easy_timer/pages/settings/settings_page.dart';
import 'package:easy_timer/theme/app_colors.dart';

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
                backgroundColor: AppColors.primary,
                useIndicator: true,
                indicatorColor: AppColors.indicatorOnPrimary,
                indicatorShape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                ),
                selectedIconTheme: const IconThemeData(
                  color: AppColors.textOnPrimary,
                  size: 24,
                ),
                unselectedIconTheme: const IconThemeData(
                  color: AppColors.textSecondaryOnPrimary,
                  size: 22,
                ),
                selectedLabelTextStyle: const TextStyle(
                  color: AppColors.textOnPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500, // 稍微加粗
                  letterSpacing: 0.2, // 轻微增加字间距
                ),
                unselectedLabelTextStyle: const TextStyle(
                  color: AppColors.textSecondaryOnPrimary,
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
                        AppColors.primaryWithOpacity20,
                        AppColors.primary,
                        AppColors.primaryWithOpacity20,
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
                      colors: [AppColors.backgroundLight, AppColors.backgroundDark],
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
                color: AppColors.textOnPrimary,
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
