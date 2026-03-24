import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../providers/locale_provider.dart';

/// Day 20 学习示例：国际化 (i18n) 与多语言 Demo
///
/// 核心知识点：
/// 1. Flutter 内置 i18n 方案 — flutter_localizations + intl
/// 2. ARB 文件结构 — 类似前端 i18n/zh.json 的资源文件
/// 3. 代码生成 — flutter gen-l10n 自动生成 AppLocalizations
/// 4. 动态切换语言 — Riverpod 管理 Locale 状态
/// 5. 复数/性别/日期格式化 — ICU 消息语法
/// 6. 第三方方案对比 — easy_localization vs slang vs 官方方案
class I18nDemoPage extends HookConsumerWidget {
  const I18nDemoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = useTabController(initialLength: 3);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Day 20: i18n 国际化'),
        bottom: TabBar(
          controller: tabController,
          labelStyle: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(fontSize: 13.sp),
          tabs: [
            Tab(text: AppLocalizations.of(context).basicTranslation),
            Tab(text: AppLocalizations.of(context).pluralGenderDate),
            Tab(text: AppLocalizations.of(context).solutionComparison),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: const [
          _BasicTranslationTab(),
          _PluralGenderDateTab(),
          _SolutionComparisonTab(),
        ],
      ),
    );
  }
}

// ============================================================
// Tab 1: 基础翻译
// ============================================================

class _BasicTranslationTab extends ConsumerWidget {
  const _BasicTranslationTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = ref.watch(localeProvider);

    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        // 知识点说明
        _KnowledgeCard(
          icon: Icons.lightbulb_outline,
          title: l10n.knowledgePointTitle,
          isDark: isDark,
          content: 'Flutter 使用 ARB (Application Resource Bundle) 文件定义翻译文本。\n'
              '每个 ARB 文件是一个 JSON，key 对应翻译 ID，value 是翻译文本。\n\n'
              '运行 flutter gen-l10n 后会自动生成类型安全的 AppLocalizations 类，\n'
              '通过 AppLocalizations.of(context).xxx 访问翻译。',
        ),
        SizedBox(height: 16.h),

        // 当前语言环境
        _InfoCard(
          icon: Icons.language,
          title: l10n.currentLocale,
          isDark: isDark,
          children: [
            _InfoRow(
              label: 'Locale',
              value: locale?.toString() ??
                  'System (${Localizations.localeOf(context)})',
            ),
            _InfoRow(
              label: 'Language Code',
              value: Localizations.localeOf(context).languageCode,
            ),
            _InfoRow(
              label: 'Country Code',
              value: Localizations.localeOf(context).countryCode ?? 'N/A',
            ),
          ],
        ),
        SizedBox(height: 16.h),

        // 实时效果
        _SectionHeader(title: '📝 ${l10n.tryItOut}'),
        SizedBox(height: 8.h),

        _DemoResultCard(
          isDark: isDark,
          items: [
            _DemoItem(
              code: 'l10n.appTitle',
              result: l10n.appTitle,
            ),
            _DemoItem(
              code: 'l10n.greeting',
              result: l10n.greeting,
            ),
            _DemoItem(
              code: "l10n.welcomeUser('Flutter')",
              result: l10n.welcomeUser('Flutter'),
            ),
            _DemoItem(
              code: 'l10n.itemCount(42)',
              result: l10n.itemCount(42),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        // 代码参考
        _SectionHeader(title: '💻 ${l10n.codeReference}'),
        SizedBox(height: 8.h),
        _CodeBlock(
          isDark: isDark,
          code: '// 1. ARB 文件定义 (app_en.arb)\n'
              '{\n'
              '  "appTitle": "Minimal Diary",\n'
              '  "welcomeUser": "Welcome, {name}!",\n'
              '  "@welcomeUser": {\n'
              '    "placeholders": {\n'
              '      "name": { "type": "String" }\n'
              '    }\n'
              '  }\n'
              '}\n\n'
              '// 2. Dart 代码中使用\n'
              'final l10n = AppLocalizations.of(context);\n'
              'Text(l10n.appTitle);           // 简单字符串\n'
              "Text(l10n.welcomeUser('Bob')); // 带参数",
        ),
        SizedBox(height: 16.h),

        // 快速切换语言
        _LanguageSwitcher(isDark: isDark),
        SizedBox(height: 32.h),
      ],
    );
  }
}

// ============================================================
// Tab 2: 复数/性别/日期
// ============================================================

class _PluralGenderDateTab extends HookConsumerWidget {
  const _PluralGenderDateTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 复数计数器
    final messageCount = useState(0);
    // 性别选择
    final selectedGender = useState('male');

    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        // ---- 复数消息 ----
        _SectionHeader(title: '🔢 ${l10n.pluralDemo}'),
        SizedBox(height: 8.h),

        _KnowledgeCard(
          icon: Icons.format_list_numbered,
          title: 'ICU Plural 语法',
          isDark: isDark,
          content: '{count, plural, =0{零条} =1{一条} other{{count}条}}\n\n'
              '支持的关键字：zero / one / two / few / many / other\n'
              '不同语言的复数规则不同（如阿拉伯语有6种形式）',
        ),
        SizedBox(height: 12.h),

        // 交互区域
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.blue.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              Text(
                l10n.unreadMessages(messageCount.value),
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CounterButton(
                    icon: Icons.remove,
                    onPressed: messageCount.value > 0
                        ? () => messageCount.value--
                        : null,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Text(
                      '${messageCount.value}',
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _CounterButton(
                    icon: Icons.add,
                    onPressed: () => messageCount.value++,
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        _CodeBlock(
          isDark: isDark,
          code: '// ARB 定义\n'
              '"unreadMessages": "{count, plural,\\n'
              '  =0{No unread messages}\\n'
              '  =1{1 unread message}\\n'
              '  other{{count} unread messages}}"\n\n'
              '// 使用\n'
              'l10n.unreadMessages(3) // → "3 unread messages"',
        ),
        SizedBox(height: 24.h),

        // ---- 性别消息 ----
        _SectionHeader(title: '👤 ${l10n.genderDemo}'),
        SizedBox(height: 8.h),

        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.purple.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.purple.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              Text(
                l10n.userGreeting(selectedGender.value, 'Alex'),
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12.h),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'male', label: Text(l10n.male)),
                  ButtonSegment(value: 'female', label: Text(l10n.female)),
                  ButtonSegment(value: 'other', label: Text(l10n.other)),
                ],
                selected: {selectedGender.value},
                onSelectionChanged: (s) => selectedGender.value = s.first,
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        _CodeBlock(
          isDark: isDark,
          code: '// ARB 定义 (ICU select 语法)\n'
              '"userGreeting": "{gender, select,\\n'
              '  male{Mr. {name}}\\n'
              '  female{Ms. {name}}\\n'
              '  other{Dear {name}}}"\n\n'
              '// 使用\n'
              "l10n.userGreeting('female', 'Alex') // → \"Ms. Alex\"",
        ),
        SizedBox(height: 24.h),

        // ---- 日期格式化 ----
        _SectionHeader(title: '📅 ${l10n.dateFormatDemo}'),
        SizedBox(height: 8.h),

        _DemoResultCard(
          isDark: isDark,
          items: [
            _DemoItem(
              code: 'l10n.currentDate(DateTime.now())',
              result: l10n.currentDate(DateTime.now()),
            ),
            _DemoItem(
              code: "DateFormat.yMMMMd('zh').format(now)",
              result: DateFormat.yMMMMd(
                Localizations.localeOf(context).languageCode,
              ).format(DateTime.now()),
            ),
            _DemoItem(
              code: "DateFormat.EEEE('locale').format(now)",
              result: DateFormat.EEEE(
                Localizations.localeOf(context).languageCode,
              ).format(DateTime.now()),
            ),
            _DemoItem(
              code: "DateFormat.jms('locale').format(now)",
              result: DateFormat.jms(
                Localizations.localeOf(context).languageCode,
              ).format(DateTime.now()),
            ),
          ],
        ),
        SizedBox(height: 24.h),

        // ---- 数字格式化 ----
        _SectionHeader(title: '💰 ${l10n.numberFormatDemo}'),
        SizedBox(height: 8.h),

        _DemoResultCard(
          isDark: isDark,
          items: [
            _DemoItem(
              code: 'l10n.price(1234.56)',
              result: l10n.price(1234.56),
            ),
            _DemoItem(
              code: "NumberFormat.compact('locale').format(1234567)",
              result: NumberFormat.compact(
                locale: Localizations.localeOf(context).languageCode,
              ).format(1234567),
            ),
            _DemoItem(
              code: "NumberFormat.percentPattern().format(0.85)",
              result: NumberFormat.percentPattern(
                Localizations.localeOf(context).languageCode,
              ).format(0.85),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        // 快速切换语言
        _LanguageSwitcher(isDark: isDark),
        SizedBox(height: 32.h),
      ],
    );
  }
}

// ============================================================
// Tab 3: 方案对比 + 语言切换
// ============================================================

class _SolutionComparisonTab extends ConsumerWidget {
  const _SolutionComparisonTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        // 语言切换
        _SectionHeader(title: '🌍 ${l10n.switchLanguage}'),
        SizedBox(height: 8.h),
        _LanguageSwitcher(isDark: isDark, expanded: true),
        SizedBox(height: 24.h),

        // 方案对比
        _SectionHeader(title: '⚖️ ${l10n.solutionComparison}'),
        SizedBox(height: 8.h),

        // 对比卡片
        _SolutionCard(
          isDark: isDark,
          name: l10n.officialSolution,
          badge: l10n.recommended,
          badgeColor: Colors.green,
          description: l10n.officialSolutionDesc,
          pros: const [
            'Flutter 团队维护，长期稳定',
            '类型安全，编译期检查',
            'IDE 自动补全',
            'ICU 消息语法支持完整',
          ],
          cons: const [
            '需要 flutter gen-l10n 代码生成',
            'ARB 文件格式较冗长',
            '热重载时翻译不会实时更新',
          ],
        ),
        SizedBox(height: 12.h),

        _SolutionCard(
          isDark: isDark,
          name: l10n.easyLocalization,
          description: l10n.easyLocalizationDesc,
          pros: const [
            '配置简单、上手快',
            '支持 JSON/YAML/CSV 多种格式',
            '支持热重载实时预览',
            '不需要代码生成步骤',
          ],
          cons: const [
            '字符串 key 访问，不够类型安全',
            '拼写错误只能在运行时发现',
            '社区维护，更新频率不确定',
          ],
        ),
        SizedBox(height: 12.h),

        _SolutionCard(
          isDark: isDark,
          name: l10n.slang,
          description: l10n.slangDesc,
          pros: const [
            '完全类型安全',
            '支持链接翻译 & 修饰符',
            '生成的 API 非常简洁 (t.xxx)',
            '支持复杂的嵌套结构',
          ],
          cons: const [
            '需要代码生成',
            '相对较新，生态尚在成长',
            '学习成本略高于 easy_localization',
          ],
        ),
        SizedBox(height: 24.h),

        // 对比表格
        _SectionHeader(title: '📊 功能对比矩阵'),
        SizedBox(height: 8.h),
        _ComparisonTable(isDark: isDark),
        SizedBox(height: 24.h),

        // 代码参考：如何在 main.dart 中配置
        _SectionHeader(title: '💻 ${l10n.codeReference}'),
        SizedBox(height: 8.h),
        _CodeBlock(
          isDark: isDark,
          code: '// main.dart 配置国际化\n'
              'MaterialApp.router(\n'
              '  // 1. 注册 delegate\n'
              '  localizationsDelegates:\n'
              '    AppLocalizations.localizationsDelegates,\n'
              '  // 2. 声明支持的 locale\n'
              '  supportedLocales:\n'
              '    AppLocalizations.supportedLocales,\n'
              '  // 3. 绑定 Riverpod locale (动态切换)\n'
              '  locale: ref.watch(localeProvider),\n'
              ')\n\n'
              '// locale_provider.dart\n'
              'final localeProvider =\n'
              '  StateNotifierProvider<LocaleNotifier, Locale?>(\n'
              '    (ref) => LocaleNotifier(prefs),\n'
              '  );\n\n'
              '// 切换语言\n'
              "ref.read(localeProvider.notifier).setLocale(Locale('en'));\n"
              '// 跟随系统\n'
              'ref.read(localeProvider.notifier).resetToSystem();',
        ),
        SizedBox(height: 32.h),
      ],
    );
  }
}

// ============================================================
// 通用 UI 组件
// ============================================================

/// 知识点卡片
class _KnowledgeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final bool isDark;

  const _KnowledgeCard({
    required this.icon,
    required this.title,
    required this.content,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A237E), const Color(0xFF0D47A1)]
              : [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon,
                  size: 20.sp,
                  color: isDark ? Colors.amber : Colors.blue.shade700),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.blue.shade900,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            content,
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.6,
              color: isDark ? Colors.white70 : Colors.blue.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

/// 信息卡片
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDark;
  final List<Widget> children;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.isDark,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18.sp),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...children,
        ],
      ),
    );
  }
}

/// 信息行
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Section 小标题
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

/// Demo 效果卡片
class _DemoResultCard extends StatelessWidget {
  final bool isDark;
  final List<_DemoItem> items;

  const _DemoResultCard({required this.isDark, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                color: isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.grey.shade100,
              ),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 代码
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      items[i].code,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontFamily: 'monospace',
                        color:
                            isDark ? Colors.greenAccent : Colors.green.shade800,
                      ),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  // 结果
                  Row(
                    children: [
                      Text(
                        '→ ',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isDark ? Colors.amber : Colors.orange.shade700,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          items[i].result,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DemoItem {
  final String code;
  final String result;
  const _DemoItem({required this.code, required this.result});
}

/// 代码块
class _CodeBlock extends StatelessWidget {
  final bool isDark;
  final String code;

  const _CodeBlock({required this.isDark, required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFF282C34),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(
          code,
          style: TextStyle(
            fontSize: 12.sp,
            fontFamily: 'monospace',
            color: const Color(0xFFABB2BF),
            height: 1.6,
          ),
        ),
      ),
    );
  }
}

/// 语言切换器
class _LanguageSwitcher extends ConsumerWidget {
  final bool isDark;
  final bool expanded;

  const _LanguageSwitcher({required this.isDark, this.expanded = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(localeProvider);

    final options = [
      _LangOption(null, '🌐', l10n.followSystem),
      _LangOption(const Locale('zh'), '🇨🇳', l10n.chinese),
      _LangOption(const Locale('en'), '🇺🇸', l10n.english),
    ];

    if (expanded) {
      return Column(
        children: [
          for (final opt in options) ...[
            _LanguageTile(
              option: opt,
              isSelected:
                  currentLocale?.languageCode == opt.locale?.languageCode,
              onTap: () {
                if (opt.locale == null) {
                  ref.read(localeProvider.notifier).resetToSystem();
                } else {
                  ref.read(localeProvider.notifier).setLocale(opt.locale!);
                }
              },
              isDark: isDark,
            ),
            SizedBox(height: 8.h),
          ],
        ],
      );
    }

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200,
        ),
      ),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        alignment: WrapAlignment.center,
        children: [
          for (final opt in options)
            _LanguageChip(
              option: opt,
              isSelected: opt.locale == null
                  ? currentLocale == null
                  : currentLocale?.languageCode == opt.locale?.languageCode,
              onTap: () {
                if (opt.locale == null) {
                  ref.read(localeProvider.notifier).resetToSystem();
                } else {
                  ref.read(localeProvider.notifier).setLocale(opt.locale!);
                }
              },
            ),
        ],
      ),
    );
  }
}

class _LangOption {
  final Locale? locale;
  final String emoji;
  final String label;
  const _LangOption(this.locale, this.emoji, this.label);
}

/// 语言选择芯片
class _LanguageChip extends StatelessWidget {
  final _LangOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageChip({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(option.emoji, style: TextStyle(fontSize: 16.sp)),
            SizedBox(width: 6.w),
            Text(
              option.label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color:
                    isSelected ? Theme.of(context).colorScheme.onPrimary : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 语言选择磁贴 (展开模式)
class _LanguageTile extends StatelessWidget {
  final _LangOption option;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _LanguageTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.12)
              : isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(option.emoji, style: TextStyle(fontSize: 24.sp)),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                option.label,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
                size: 22.sp,
              ),
          ],
        ),
      ),
    );
  }
}

/// 计数器按钮
class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _CounterButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Icon(icon, size: 20.sp),
        ),
      ),
    );
  }
}

/// 方案对比卡片
class _SolutionCard extends StatelessWidget {
  final bool isDark;
  final String name;
  final String? badge;
  final Color? badgeColor;
  final String description;
  final List<String> pros;
  final List<String> cons;

  const _SolutionCard({
    required this.isDark,
    required this.name,
    this.badge,
    this.badgeColor,
    required this.description,
    required this.pros,
    required this.cons,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: badge != null
              ? (badgeColor ?? Colors.blue).withOpacity(0.4)
              : isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey.shade200,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (badge != null) ...[
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: (badgeColor ?? Colors.blue).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: badgeColor ?? Colors.blue,
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            description,
            style: TextStyle(
              fontSize: 13.sp,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              height: 1.5,
            ),
          ),
          SizedBox(height: 12.h),

          // 优点
          ...pros.map(
            (p) => Padding(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('✅ ', style: TextStyle(fontSize: 12.sp)),
                  Expanded(
                    child:
                        Text(p, style: TextStyle(fontSize: 13.sp, height: 1.4)),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 6.h),

          // 缺点
          ...cons.map(
            (c) => Padding(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('⚠️ ', style: TextStyle(fontSize: 12.sp)),
                  Expanded(
                    child:
                        Text(c, style: TextStyle(fontSize: 13.sp, height: 1.4)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 功能对比表格
class _ComparisonTable extends StatelessWidget {
  final bool isDark;
  const _ComparisonTable({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final headerStyle = TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.bold,
    );
    final cellStyle = TextStyle(fontSize: 12.sp);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
              isDark ? Colors.white.withOpacity(0.08) : Colors.blue.shade50,
            ),
            columnSpacing: 16.w,
            horizontalMargin: 12.w,
            columns: [
              DataColumn(label: Text('特性', style: headerStyle)),
              DataColumn(label: Text('官方方案', style: headerStyle)),
              DataColumn(label: Text('easy_loc', style: headerStyle)),
              DataColumn(label: Text('slang', style: headerStyle)),
            ],
            rows: [
              _row('类型安全', '✅', '❌', '✅', cellStyle),
              _row('代码生成', '需要', '不需要', '需要', cellStyle),
              _row('资源格式', 'ARB', 'JSON/YAML', 'JSON/YAML', cellStyle),
              _row('复数支持', '✅ ICU', '✅', '✅', cellStyle),
              _row('热重载', '❌', '✅', '❌', cellStyle),
              _row('官方维护', '✅', '❌', '❌', cellStyle),
              _row('学习成本', '中', '低', '中高', cellStyle),
            ],
          ),
        ),
      ),
    );
  }

  DataRow _row(String feature, String a, String b, String c, TextStyle style) {
    return DataRow(cells: [
      DataCell(
          Text(feature, style: style.copyWith(fontWeight: FontWeight.w500))),
      DataCell(Text(a, style: style)),
      DataCell(Text(b, style: style)),
      DataCell(Text(c, style: style)),
    ]);
  }
}
