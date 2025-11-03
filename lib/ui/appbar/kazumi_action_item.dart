import 'package:flutter/material.dart';

/// 统一的顶栏动作定义，便于在普通页与播放页 overlay 之间复用
class KazumiActionItem {
  final IconData icon;
  final String? tooltip;
  final VoidCallback? onPressed;
  final bool enabled;
  final Color? color;

  const KazumiActionItem({
    required this.icon,
    this.tooltip,
    this.onPressed,
    this.enabled = true,
    this.color,
  });
}
