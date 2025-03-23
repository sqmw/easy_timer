import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final IconData titleIcon;
  final Color? titleIconColor;
  final Widget content;
  final List<Widget> actions;
  final EdgeInsetsGeometry contentPadding;
  final EdgeInsetsGeometry actionsPadding;

  const CustomAlertDialog({
    super.key,
    required this.title,
    required this.titleIcon,
    this.titleIconColor,
    required this.content,
    required this.actions,
    this.contentPadding = const EdgeInsets.fromLTRB(24, 20, 24, 24),
    this.actionsPadding = const EdgeInsets.fromLTRB(16, 0, 16, 16),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 标题部分
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Icon(
                    titleIcon,
                    color: titleIconColor ?? theme.colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // 内容部分
            Padding(
              padding: contentPadding,
              child: content,
            ),
            
            // 操作按钮部分
            Padding(
              padding: actionsPadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions.map((action) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: action,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 静态方法：显示对话框
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required IconData titleIcon,
    Color? titleIconColor,
    required Widget content,
    required List<Widget> actions,
    bool barrierDismissible = true,
    EdgeInsetsGeometry? contentPadding,
    EdgeInsetsGeometry? actionsPadding,
  }) {
    // 获取导航栏宽度和屏幕宽度
    final screenWidth = MediaQuery.of(context).size.width;
    final navRailWidth = MediaQuery.of(context).size.width > 600 ? 200.0 : 80.0;
    
    // 计算内容区域宽度
    final contentAreaWidth = screenWidth - navRailWidth;
    
    // 计算对话框宽度 (内容区域的80%)
    final dialogWidth = contentAreaWidth * 0.8;
    
    // 计算左侧偏移量，使对话框在内容区域居中
    final leftOffset = navRailWidth + (contentAreaWidth - dialogWidth) / 2;
    
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Stack(
          children: [
            Positioned(
              left: leftOffset,
              width: dialogWidth,
              top: 0,
              bottom: 0,
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: CustomAlertDialog(
                    title: title,
                    titleIcon: titleIcon,
                    titleIconColor: titleIconColor,
                    content: content,
                    actions: actions,
                    contentPadding: contentPadding ?? const EdgeInsets.fromLTRB(24, 20, 24, 24),
                    actionsPadding: actionsPadding ?? const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: child,
          ),
        );
      },
    );
  }
}