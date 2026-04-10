import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// ============================================================
/// Day 45: 货币与数字格式化
///
/// 技术要点：
///   1. NumberFormat 数字格式化 — 千分位、小数位控制
///   2. 货币格式化 — NumberFormat.currency() 显示 ¥1,234.56
///   3. 百分比格式化 — NumberFormat.percentPattern() 显示 85.5%
///   4. 紧凑数字 — NumberFormat.compact() 显示 1.2K / 3.5M
///   5. 实战场景 — 商品价格、统计数据、金融应用
/// ============================================================

class Day45NumberFormatDemo extends StatelessWidget {
  const Day45NumberFormatDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text('Day 45: 货币与数字格式化'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showTechDialog(context),
          ),
        ],
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionCard(
              title: '1. 数字格式化',
              icon: Icons.tag,
              color: Color(0xFF7C4DFF),
              child: _NumberFormatSection(),
            ),
            SizedBox(height: 16),
            _SectionCard(
              title: '2. 货币格式化',
              icon: Icons.attach_money,
              color: Color(0xFF4CAF50),
              child: _CurrencySection(),
            ),
            SizedBox(height: 16),
            _SectionCard(
              title: '3. 百分比格式化',
              icon: Icons.percent,
              color: Color(0xFFFF9800),
              child: _PercentSection(),
            ),
            SizedBox(height: 16),
            _SectionCard(
              title: '4. 紧凑数字',
              icon: Icons.compress,
              color: Color(0xFF2196F3),
              child: _CompactSection(),
            ),
            SizedBox(height: 16),
            _SectionCard(
              title: '5. 实战场景',
              icon: Icons.storefront,
              color: Color(0xFFE91E63),
              child: _PracticalSection(),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showTechDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('🔧 技术解析', style: TextStyle(color: Colors.white)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TechItem(icon: '🔢', title: 'NumberFormat', desc: 'intl 包核心类，支持自定义 pattern、locale、小数位'),
            SizedBox(height: 10),
            _TechItem(icon: '💴', title: 'currency()', desc: '内置货币格式，自动处理符号、千分位、小数位'),
            SizedBox(height: 10),
            _TechItem(icon: '📊', title: 'percentPattern()', desc: '百分比格式，0.855 → 85.5%'),
            SizedBox(height: 10),
            _TechItem(icon: '📦', title: 'compact()', desc: '紧凑格式，1200 → 1.2K，3500000 → 3.5M'),
            SizedBox(height: 10),
            _TechItem(icon: '🌍', title: 'Locale 支持', desc: '通过 locale 参数切换地区格式，如 zh_CN / en_US'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('知道了', style: TextStyle(color: Color(0xFF7C4DFF))),
          ),
        ],
      ),
    );
  }
}

// ==================== Section 1: 数字格式化 ====================

class _NumberFormatSection extends StatelessWidget {
  const _NumberFormatSection();

  @override
  Widget build(BuildContext context) {
    final rows = [
      _FormatRow('原始数字', 1234567.891, (v) => v.toString()),
      _FormatRow('千分位', 1234567.891, (v) => NumberFormat('#,###').format(v)),
      _FormatRow('2位小数', 1234567.891, (v) => NumberFormat('#,##0.00').format(v)),
      _FormatRow('0位小数', 1234567.891, (v) => NumberFormat('#,##0').format(v)),
      _FormatRow('科学计数', 1234567.891, (v) => NumberFormat('0.##E+0').format(v)),
      _FormatRow('自定义 pattern', 9876.5, (v) => NumberFormat('000,000.000').format(v)),
    ];

    return Column(
      children: rows.map((r) => _FormatTile(row: r, accentColor: const Color(0xFF7C4DFF))).toList(),
    );
  }
}

// ==================== Section 2: 货币格式化 ====================

class _CurrencySection extends StatelessWidget {
  const _CurrencySection();

  @override
  Widget build(BuildContext context) {
    final rows = [
      _FormatRow('人民币 ¥', 1234.56, (v) => NumberFormat.currency(locale: 'zh_CN', symbol: '¥').format(v)),
      _FormatRow('美元 \$', 1234.56, (v) => NumberFormat.currency(locale: 'en_US', symbol: '\$').format(v)),
      _FormatRow('欧元 €', 1234.56, (v) => NumberFormat.currency(locale: 'de_DE', symbol: '€').format(v)),
      _FormatRow('日元 ¥ (0位)', 1234.56, (v) => NumberFormat.currency(locale: 'ja_JP', symbol: '¥', decimalDigits: 0).format(v)),
      _FormatRow('简单货币', 9999.9, (v) => NumberFormat.simpleCurrency(locale: 'zh_CN').format(v)),
    ];

    return Column(
      children: rows.map((r) => _FormatTile(row: r, accentColor: const Color(0xFF4CAF50))).toList(),
    );
  }
}

// ==================== Section 3: 百分比格式化 ====================

class _PercentSection extends StatelessWidget {
  const _PercentSection();

  @override
  Widget build(BuildContext context) {
    final displayRows = [
      ('默认百分比', NumberFormat.percentPattern().format(0.855)),
      ('1位小数', '${(0.855 * 100).toStringAsFixed(1)}%'),
      ('手动 pattern', NumberFormat("##0.0#%").format(0.1234)),
      ('整数百分比', '${(0.75 * 100).round()}%'),
      ('超过100%', NumberFormat.percentPattern().format(1.256)),
    ];

    return Column(
      children: displayRows.map((r) => _SimpleTile(
        label: r.$1,
        value: r.$2,
        accentColor: const Color(0xFFFF9800),
      )).toList(),
    );
  }
}

// ==================== Section 4: 紧凑数字 ====================

class _CompactSection extends StatelessWidget {
  const _CompactSection();

  @override
  Widget build(BuildContext context) {
    final compact = NumberFormat.compact(locale: 'en_US');
    final compactLong = NumberFormat.compactLong(locale: 'en_US');
    final compactCN = NumberFormat.compact(locale: 'zh_CN');

    final displayRows = [
      ('999', compact.format(999)),
      ('1,200 → K', compact.format(1200)),
      ('35,000 → K', compact.format(35000)),
      ('3,500,000 → M', compact.format(3500000)),
      ('2,100,000,000 → B', compact.format(2100000000)),
      ('紧凑长格式', compactLong.format(1200000)),
      ('中文紧凑', compactCN.format(12000)),
      ('中文亿', compactCN.format(100000000)),
    ];

    return Column(
      children: displayRows.map((r) => _SimpleTile(
        label: r.$1,
        value: r.$2,
        accentColor: const Color(0xFF2196F3),
      )).toList(),
    );
  }
}

// ==================== Section 5: 实战场景 ====================

class _PracticalSection extends StatelessWidget {
  const _PracticalSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 商品价格卡片
        _PracticeCard(
          title: '🛒 商品价格',
          items: [
            _PracticeItem('原价', NumberFormat.currency(locale: 'zh_CN', symbol: '¥').format(2999.00)),
            _PracticeItem('折扣价', NumberFormat.currency(locale: 'zh_CN', symbol: '¥').format(1899.00)),
            _PracticeItem('折扣率', '${(1899 / 2999 * 100).toStringAsFixed(0)}折'),
            _PracticeItem('节省', NumberFormat.currency(locale: 'zh_CN', symbol: '¥').format(2999 - 1899)),
          ],
        ),
        const SizedBox(height: 12),
        // 统计数据卡片
        _PracticeCard(
          title: '📊 统计数据',
          items: [
            _PracticeItem('总用户', NumberFormat.compact(locale: 'zh_CN').format(1280000)),
            _PracticeItem('月活', NumberFormat.compact(locale: 'zh_CN').format(356000)),
            _PracticeItem('转化率', NumberFormat.percentPattern().format(0.0278)),
            _PracticeItem('日均收入', NumberFormat.currency(locale: 'zh_CN', symbol: '¥').format(128456.78)),
          ],
        ),
        const SizedBox(height: 12),
        // 金融数据卡片
        _PracticeCard(
          title: '💹 金融数据',
          items: [
            _PracticeItem('股价', NumberFormat('#,##0.00').format(168.35)),
            _PracticeItem('涨跌幅', '+${NumberFormat("##0.00%").format(0.0235)}'),
            _PracticeItem('市值', NumberFormat.compact(locale: 'en_US').format(2750000000000)),
            _PracticeItem('成交量', NumberFormat('#,###').format(45678900)),
          ],
        ),
      ],
    );
  }
}

class _PracticeCard extends StatelessWidget {
  final String title;
  final List<_PracticeItem> items;

  const _PracticeCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE91E63).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 10),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item.label, style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 13)),
                Text(item.value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'monospace')),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _PracticeItem {
  final String label;
  final String value;
  const _PracticeItem(this.label, this.value);
}

// ==================== Shared Widgets ====================

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _SimpleTile extends StatelessWidget {
  final String label;
  final String value;
  final Color accentColor;

  const _SimpleTile({required this.label, required this.value, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 13)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(value, style: TextStyle(color: accentColor, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
          ),
        ],
      ),
    );
  }
}

class _FormatRow {
  final String label;
  final double value;
  final dynamic Function(double) formatter;
  const _FormatRow(this.label, this.value, this.formatter);
}

class _FormatTile extends StatelessWidget {
  final _FormatRow row;
  final Color accentColor;

  const _FormatTile({required this.row, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final formatted = row.formatter(row.value);
    final display = formatted is String ? formatted : formatted.toString();
    return _SimpleTile(label: row.label, value: display, accentColor: accentColor);
  }
}

class _TechItem extends StatelessWidget {
  final String icon;
  final String title;
  final String desc;

  const _TechItem({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 2),
              Text(desc, style: const TextStyle(color: Color(0xFF6C7B95), fontSize: 12, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}
