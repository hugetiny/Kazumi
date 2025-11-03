import 'dart:io' show Platform; 
import 'package:flutter/material.dart';

/// 统一外观的 AppBar 封装：普通页面使用它替代直接 new AppBar
class KazumiAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool transparent;
  final bool centerTitle;
  final double height;
  final bool enableDragOnDesktop;

  const KazumiAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.transparent = false,
    this.centerTitle = false,
    this.height = 40,
    this.enableDragOnDesktop = false,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = transparent
        ? Colors.transparent
        : theme.colorScheme.surface;
    final fgColor = theme.colorScheme.onSurface;

    // 可选：桌面端在标题区域支持拖动（保持插槽简洁，避免强依赖）
    Widget titleArea = title ?? const SizedBox.shrink();
    if (enableDragOnDesktop && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      // 使用一个不可交互的区域模拟可拖动区域（实际拖动逻辑由外层自定义 AppBar 承担）
      titleArea = Row(children: [Expanded(child: titleArea)]);
    }

    return AppBar(
      backgroundColor: bgColor,
      elevation: transparent ? 0 : 0.5,
      scrolledUnderElevation: 0,
      titleTextStyle: theme.textTheme.titleMedium?.copyWith(color: fgColor),
      iconTheme: IconThemeData(color: fgColor, size: 22),
      centerTitle: centerTitle,
      title: titleArea,
      leading: leading,
      actions: actions,
      toolbarHeight: height,
      surfaceTintColor: Colors.transparent,
    );
  }
}
