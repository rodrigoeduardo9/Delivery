import 'package:flutter/material.dart';
import '../config/theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final bool showBack;
  final Color? backgroundColor;
  final double elevation;

  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.showBack = true,
    this.backgroundColor,
    this.elevation = 0,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: titleWidget ?? (title != null ? Text(title!) : null),
      actions: actions,
      backgroundColor: backgroundColor ?? AppTheme.surface,
      elevation: elevation,
      automaticallyImplyLeading: showBack,
    );
  }
}
