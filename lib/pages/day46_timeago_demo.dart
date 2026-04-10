import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';

/// ============================================================
/// Day 46: 相对时间显示——timeago
///
/// 技术要点：
///   1. timeago 包核心用法 — 相对时间显示（"刚刚" / "3分钟前"）
///   2. 多语言支持 — 中文/英文/日文等语言包
///   3. 自定义时间阈值 — 何时显示"刚刚"、何时显示具体时间
///   4. 与 DateTime 结合 — 计算时间差
///   5. 实战场景 — 聊天消息时间、动态发布时间、评论时间
/// ============================================================

class Day46TimeagoDemo extends StatefulWidget {
  const Day46TimeagoDemo({super.key});

  @override
  State<Day46TimeagoDemo> createState() => _Day46TimeagoDemoState();
}

class _Day46TimeagoDemoState extends State<Day46TimeagoDemo> {
  @override
  void initState() {
    super.initState();
    // 初始化多语言支持
    timeago.setLocaleMessages('zh', timeago.ZhMessages());
    timeago.setLocaleMessages('zh_short', ZhShortMessages()); // 自定义简短中文
    timeago.setLocaleMessages('en', timeago.EnMessages()); // 默认其实已经有en，这里加固一下
    timeago.setLocaleMessages('ja', timeago.JaMessages());
    
    // 注入自定义时间阈值语言包
    timeago.setLocaleMessages('custom_zh', CustomZhMessages());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text('Day 46: 相对时间 (timeago)'),
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
              title: '1. 核心用法 (基础时间差)',
              icon: Icons.access_time_filled,
              color: Color(0xFF7C4DFF),
              child: _BasicUsageSection(),
            ),
            SizedBox(height: 16),
            _SectionCard(
              title: '2. 多语言支持 & 简写',
              icon: Icons.language,
              color: Color(0xFF4CAF50),
              child: _LocaleSection(),
            ),
            SizedBox(height: 16),
            _SectionCard(
              title: '3. 自定义语言包 (阈值自定义)',
              icon: Icons.edit_note,
              color: Color(0xFFFF9800),
              child: _CustomMsgSection(),
            ),
            SizedBox(height: 16),
            _SectionCard(
              title: '4. 实战场景: 评论与动态',
              icon: Icons.dynamic_feed,
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
            _TechItem(icon: '⏱', title: 'timeago.format()', desc: '核心方法，传入 DateTime，计算与当前时间的差异并返回可读字符串'),
            SizedBox(height: 10),
            _TechItem(icon: '🌍', title: 'setLocaleMessages()', desc: '注册多语言包，支持通过 locale 参数切换 (如 zh, en, ja)'),
            SizedBox(height: 10),
            _TechItem(icon: '🔮', title: 'allowFromNow', desc: '默认为 false。设置为 true 时，支持预测未来时间，如 "5分钟后"'),
            SizedBox(height: 10),
            _TechItem(icon: '🛠', title: 'LookupMessages', desc: '继承此接口可完全重写时间的判断阈值。例如改变 "刚刚" 所代表的秒数范围'),
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

// ==================== Section 1: 核心用法 ====================

class _BasicUsageSection extends StatelessWidget {
  const _BasicUsageSection();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    
    return Column(
      children: [
        _TimeFormatterTile('15秒前', now.subtract(const Duration(seconds: 15)), locale: 'zh'),
        _TimeFormatterTile('5分钟前', now.subtract(const Duration(minutes: 5)), locale: 'zh'),
        _TimeFormatterTile('1小时前', now.subtract(const Duration(hours: 1)), locale: 'zh'),
        _TimeFormatterTile('3天前', now.subtract(const Duration(days: 3)), locale: 'zh'),
        _TimeFormatterTile('未来5分钟(allowFromNow)', now.add(const Duration(minutes: 5)), locale: 'zh', allowFromNow: true, accentColor: const Color(0xFF2196F3)),
      ],
    );
  }
}

// ==================== Section 2: 多语言支持 & 简写 ====================

class _LocaleSection extends StatelessWidget {
  const _LocaleSection();

  @override
  Widget build(BuildContext context) {
    final t = DateTime.now().subtract(const Duration(hours: 2, minutes: 30));
    
    return Column(
      children: [
        _TimeFormatterTile('中文 (zh)', t, locale: 'zh', accentColor: const Color(0xFF4CAF50)),
        _TimeFormatterTile('中文简写 (zh_short)', t, locale: 'zh_short', accentColor: const Color(0xFF4CAF50)),
        _TimeFormatterTile('英文 (en)', t, locale: 'en', accentColor: const Color(0xFF4CAF50)),
        _TimeFormatterTile('英文简写 (en_short)', t, locale: 'en_short', accentColor: const Color(0xFF4CAF50)),
        _TimeFormatterTile('日文 (ja)', t, locale: 'ja', accentColor: const Color(0xFF4CAF50)),
      ],
    );
  }
}

// ==================== Section 3: 自定义语言包 ====================

class ZhShortMessages implements timeago.LookupMessages {
  @override String prefixAgo() => '';
  @override String prefixFromNow() => '';
  @override String suffixAgo() => '';
  @override String suffixFromNow() => '';
  @override String lessThanOneMinute(int seconds) => '刚刚';
  @override String aboutAMinute(int minutes) => '1分';
  @override String minutes(int minutes) => '$minutes分';
  @override String aboutAnHour(int minutes) => '1时';
  @override String hours(int hours) => '$hours时';
  @override String aDay(int hours) => '1天';
  @override String days(int days) => '$days天';
  @override String aboutAMonth(int days) => '1月';
  @override String months(int months) => '$months月';
  @override String aboutAYear(int year) => '1年';
  @override String years(int years) => '$years年';
  @override String wordSeparator() => '';
}

class CustomZhMessages implements timeago.LookupMessages {
  @override String prefixAgo() => '';
  @override String prefixFromNow() => '';
  @override String suffixAgo() => '以前';
  @override String suffixFromNow() => '之后';
  
  // 自定义：不超过1分钟都叫 "刚才啦"
  @override String lessThanOneMinute(int seconds) => '刚才啦~';
  @override String aboutAMinute(int minutes) => '$minutes分钟';
  @override String minutes(int minutes) => '$minutes分钟';
  @override String aboutAnHour(int minutes) => '大约1小时';
  @override String hours(int hours) => '${hours}个小时';
  @override String aDay(int hours) => '昨天';
  @override String days(int days) => '${days}天';
  @override String aboutAMonth(int days) => '一个月';
  @override String months(int months) => '${months}个月';
  @override String aboutAYear(int year) => '满一年了';
  @override String years(int years) => '${years}年';
  @override String wordSeparator() => '';
}

class _CustomMsgSection extends StatelessWidget {
  const _CustomMsgSection();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Column(
      children: [
        _SimpleTile(
          label: '标准版 (45秒前)', 
          value: timeago.format(now.subtract(const Duration(seconds: 45)), locale: 'zh'), 
          accentColor: const Color(0xFFFF9800)
        ),
        _SimpleTile(
          label: '自定义版 (45秒前)', 
          value: timeago.format(now.subtract(const Duration(seconds: 45)), locale: 'custom_zh'), 
          accentColor: const Color(0xFFFF9800)
        ),
        _SimpleTile(
          label: '标准版 (5小时前)', 
          value: timeago.format(now.subtract(const Duration(hours: 5)), locale: 'zh'), 
          accentColor: const Color(0xFFFF9800)
        ),
        _SimpleTile(
          label: '自定义版 (5小时前)', 
          value: timeago.format(now.subtract(const Duration(hours: 5)), locale: 'custom_zh'), 
          accentColor: const Color(0xFFFF9800)
        ),
      ],
    );
  }
}

// ==================== Section 4: 实战业务场景 ====================

class _PracticalSection extends StatelessWidget {
  const _PracticalSection();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    
    return Column(
      children: [
        // 动态发布场景
        _PostCard(
          avatar: Icons.face,
          name: 'Flutter 高手',
          content: '刚刚发布了关于 NumberFormat 的最佳实践，赶紧来看哦！🚀',
          time: now.subtract(const Duration(minutes: 5)),
        ),
        const SizedBox(height: 12),
        // 聊天列表场景
        _ChatTile(
          name: '产品经理',
          msg: '需求有变，把刚刚这个功能再改一下。',
          time: now.subtract(const Duration(days: 1)),
        ),
        _ChatTile(
          name: '设计同学',
          msg: '最新切图已经发过去咯~',
          time: now.subtract(const Duration(days: 5)),
        ),
      ],
    );
  }
}

class _PostCard extends StatelessWidget {
  final IconData avatar;
  final String name;
  final String content;
  final DateTime time;

  const _PostCard({required this.avatar, required this.name, required this.content, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: const Color(0xFFE91E63), child: Icon(avatar, color: Colors.white, size: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 2),
                    // 当时间超过7天，可能强制显示年月日，否则显示 timeago (这在动态列表很常见)
                    Text(
                       _formatSmartTime(time),
                      style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 11)
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(content, style: const TextStyle(color: Color(0xFFE0E0E0), fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }
  
  String _formatSmartTime(DateTime dt) {
     final diff = DateTime.now().difference(dt);
     if(diff.inDays > 7) {
       return DateFormat('yyyy-MM-dd HH:mm').format(dt);
     }
     return timeago.format(dt, locale: 'zh');
  }
}

class _ChatTile extends StatelessWidget {
  final String name;
  final String msg;
  final DateTime time;

  const _ChatTile({required this.name, required this.msg, required this.time});

  @override
  Widget build(BuildContext context) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: const Color(0xFF00BCD4), child: Text(name[0], style: const TextStyle(color: Colors.white))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Text(name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                       // 聊天列表通常用到 zh_short 格式
                       Text(timeago.format(time, locale: 'zh_short'), style: const TextStyle(color: Color(0xFF757575), fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(msg, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 12)),
                ],
              ),
            )
          ],
        ),
      );
  }
}

// ==================== Shared Widgets ====================

class _TimeFormatterTile extends StatelessWidget {
  final String label;
  final DateTime targetTime;
  final String locale;
  final bool allowFromNow;
  final Color accentColor;

  const _TimeFormatterTile(this.label, this.targetTime, {
    required this.locale, 
    this.allowFromNow = false,
    this.accentColor = const Color(0xFF7C4DFF),
  });

  @override
  Widget build(BuildContext context) {
    return _SimpleTile(
      label: label, 
      value: timeago.format(targetTime, locale: locale, allowFromNow: allowFromNow), 
      accentColor: accentColor
    );
  }
}

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
            child: Text(value, style: TextStyle(color: accentColor, fontSize: 13, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
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
