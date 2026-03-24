// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '极简日记';

  @override
  String get greeting => '你好！';

  @override
  String welcomeUser(String name) {
    return '欢迎，$name！';
  }

  @override
  String itemCount(int count) {
    return '$count 个项目';
  }

  @override
  String unreadMessages(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 条未读消息',
      one: '1 条未读消息',
      zero: '没有未读消息',
    );
    return '$_temp0';
  }

  @override
  String userGreeting(String gender, String name) {
    String _temp0 = intl.Intl.selectLogic(
      gender,
      {
        'male': '$name 先生',
        'female': '$name 女士',
        'other': '亲爱的 $name',
      },
    );
    return '$_temp0';
  }

  @override
  String currentDate(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '今天是 $dateString';
  }

  @override
  String price(double amount) {
    final intl.NumberFormat amountNumberFormat = intl.NumberFormat.currency(
        locale: localeName, symbol: '\$', decimalDigits: 2);
    final String amountString = amountNumberFormat.format(amount);

    return '价格：$amountString';
  }

  @override
  String get settings => '设置';

  @override
  String get language => '语言';

  @override
  String get followSystem => '跟随系统';

  @override
  String get chinese => '中文';

  @override
  String get english => '英文';

  @override
  String get switchLanguage => '切换语言';

  @override
  String get basicTranslation => '基础翻译';

  @override
  String get pluralGenderDate => '复数 / 性别 / 日期';

  @override
  String get solutionComparison => '方案对比';

  @override
  String get currentLocale => '当前语言环境';

  @override
  String get knowledgePointTitle => '知识点';

  @override
  String get tryItOut => '动手试试';

  @override
  String get codeReference => '代码参考';

  @override
  String get pluralDemo => '复数消息';

  @override
  String get genderDemo => '性别感知消息';

  @override
  String get dateFormatDemo => '日期格式化';

  @override
  String get numberFormatDemo => '数字格式化';

  @override
  String get male => '男';

  @override
  String get female => '女';

  @override
  String get other => '其他';

  @override
  String get officialSolution => '官方方案';

  @override
  String get officialSolutionDesc =>
      'flutter_localizations + intl + ARB 文件，Flutter 团队推荐。类型安全，工具支持好，但需要代码生成步骤。';

  @override
  String get easyLocalization => 'easy_localization';

  @override
  String get easyLocalizationDesc =>
      '支持 JSON/YAML/CSV 格式，热重载友好，配置更简单。无需代码生成，但类型安全性较弱。';

  @override
  String get slang => 'slang';

  @override
  String get slangDesc => '通过 JSON/YAML 代码生成，类型安全。支持链接翻译、接口和修饰符。社区新星。';

  @override
  String get feature => '特性';

  @override
  String get recommended => '推荐 ✅';
}
