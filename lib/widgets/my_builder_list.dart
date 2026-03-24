import 'package:flutter/material.dart';

/// 一个演示 Builder 模式（对应 Vue 作用域插槽）的通用选择组件
class MyChoiceBox<T> extends StatelessWidget {
  final List<T> items;

  /// 核心 Builder 函数
  /// 参数：context, 原始数据 item, 以及组件内部计算出的状态 isSelected
  final Widget Function(BuildContext context, T item, bool isSelected)
      itemBuilder;

  final T? selectedItem;
  final ValueChanged<T> onSelected;

  const MyChoiceBox({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onSelected,
    this.selectedItem,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final isSelected = item == selectedItem;
        return GestureDetector(
          onTap: () => onSelected(item),
          // 执行 Builder 函数，并将内部数据“暴露”给外部
          child: itemBuilder(context, item, isSelected),
        );
      }).toList(),
    );
  }
}
