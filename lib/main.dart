import 'package:easy_timer/models/timer_item.dart';
import 'package:easy_timer/providers/config_provider.dart';
import 'package:easy_timer/providers/timer_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'bloc/timer_bloc.dart';
import 'widgets/app_layout.dart';
import 'package:easy_timer/providers/theme_provider.dart';
import 'package:easy_timer/providers/locale_provider.dart';
import 'package:easy_timer/providers/notification_provider.dart';
import 'package:easy_timer/providers/update_provider.dart';
import 'package:easy_timer/theme/app_theme.dart'; // 添加新的主题导入

final ConfigProvider configProvider = ConfigProvider();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化配置
  await configProvider.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => UpdateProvider()),
        // 在 MultiProvider 中确保 TimerProvider 在 NotificationProvider 之后初始化
        ChangeNotifierProxyProvider<NotificationProvider, TimerProvider>(
          create: (_) => TimerProvider(),
          update: (_, notificationProvider, timerProvider) {
            timerProvider ??= TimerProvider();
            timerProvider.setNotificationProvider(notificationProvider);
            return timerProvider;
          },
        ),
        ChangeNotifierProvider(create: (_) => configProvider),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Easy Timer',
            // 使用 AppTheme 提供的主题
            theme: _getTheme(themeProvider.themeStyle, Brightness.light),
            darkTheme: _getTheme(themeProvider.themeStyle, Brightness.dark),
            themeMode: themeProvider.themeMode,
            home: BlocProvider(
              create: (context) => TimerBloc(),
              child: const AppLayout(),
            ),
          );
        },
      ),
    );
  }
  
  // 根据主题样式和亮度获取对应的主题
  ThemeData _getTheme(ThemeStyle style, Brightness brightness) {
    if (brightness == Brightness.light) {
      // 亮色主题
      switch (style) {
        case ThemeStyle.purple:
          return AppTheme.lightTheme(); // 使用新的 AppTheme
        case ThemeStyle.blue:
          return AppTheme.lightTheme(primaryColor: Colors.blue);
        case ThemeStyle.orange:
          return AppTheme.lightTheme(primaryColor: Colors.orange);
        case ThemeStyle.green:
          return AppTheme.lightTheme(primaryColor: Colors.green);
        case ThemeStyle.pink:
          // 使用樱花粉色 (#FFB7C5) 替代普通粉色
          return AppTheme.lightTheme(primaryColor: const Color(0xFFFFB7C5));
      }
    } else {
      // 暗色主题
      switch (style) {
        case ThemeStyle.purple:
          return AppTheme.darkTheme(); // 使用新的 AppTheme
        case ThemeStyle.blue:
          return AppTheme.darkTheme(primaryColor: Colors.blue);
        case ThemeStyle.orange:
          return AppTheme.darkTheme(primaryColor: Colors.orange);
        case ThemeStyle.green:
          return AppTheme.darkTheme(primaryColor: Colors.green);
        case ThemeStyle.pink:
          // 使用樱花粉色 (#FFB7C5) 替代普通粉色
          return AppTheme.darkTheme(primaryColor: const Color(0xFFFFB7C5));
      }
    }
  }
}

// 自动启动提醒对话框
class AutoStartReminderDialog extends StatelessWidget {
  final TimerItem timer;
  
  const AutoStartReminderDialog({super.key, required this.timer});
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('计时器即将自动启动'),
      content: Text('计时器"${timer.name}"将在10秒后自动启动。'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('取消启动'),
        ),
        TextButton(
          onPressed: () {
            // 立即启动计时器
            final timerProvider = Provider.of<TimerProvider>(context, listen: false);
            timerProvider.startTimer(timer.id);
            Navigator.of(context).pop();
          },
          child: const Text('立即启动'),
        ),
      ],
    );
  }
}
