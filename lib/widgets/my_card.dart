import 'package:flutter/material.dart';

/// 一个通用的卡片组件，演示 Props, Slots 和 Emits 的实现
class MyCard extends StatelessWidget {
  // 1. Props (属性)
  final String title;

  // 2. Default Slot (默认插槽)
  final Widget child;

  // 3. Named Slot (具名插槽)
  final Widget? extra;
  final Widget? footer;

  // 4. Emits (事件回调)
  final VoidCallback? onAction;
  final String actionText;
  final bool showAction; // 类似 v-if

  // 5. Style Props (样式控制)
  final Color? backgroundColor;
  final EdgeInsetsGeometry? margin;

  const MyCard({
    super.key,
    required this.title,
    required this.child,
    this.extra,
    this.footer,
    this.onAction,
    this.actionText = '确认',
    this.showAction = true,
    this.backgroundColor,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: margin ?? const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      color: backgroundColor ?? Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (extra != null) extra!,
              ],
            ),
            const Divider(height: 24),

            // Body (Slot)
            child,

            // Footer (Optional Slot)
            if (footer != null) ...[
              const SizedBox(height: 16),
              footer!,
            ],

            // Action Area
            if (showAction && onAction != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonal(
                  onPressed: onAction,
                  child: Text(actionText),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
