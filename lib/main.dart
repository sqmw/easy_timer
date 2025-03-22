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

void main() {
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
        ChangeNotifierProxyProvider<NotificationProvider, TimerProvider>(
          create: (_) => TimerProvider(),
          update: (_, notificationProvider, timerProvider) {
            timerProvider ??= TimerProvider();
            timerProvider.setNotificationProvider(notificationProvider);
            return timerProvider;
          },
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Easy Timer',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: _getSeedColor(themeProvider.themeStyle),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: _getSeedColor(themeProvider.themeStyle),
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
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
  
  Color _getSeedColor(ThemeStyle style) {
    switch (style) {
      case ThemeStyle.purple:
        return const Color(0xFF9683EC);
      case ThemeStyle.blue:
        return Colors.blue;
      case ThemeStyle.orange:
        return Colors.orange;
      case ThemeStyle.green:
        return Colors.green;
    }
  }
}
