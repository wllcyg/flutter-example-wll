// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Minimal Diary';

  @override
  String get greeting => 'Hello!';

  @override
  String welcomeUser(String name) {
    return 'Welcome, $name!';
  }

  @override
  String itemCount(int count) {
    return '$count items';
  }

  @override
  String unreadMessages(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unread messages',
      one: '1 unread message',
      zero: 'No unread messages',
    );
    return '$_temp0';
  }

  @override
  String userGreeting(String gender, String name) {
    String _temp0 = intl.Intl.selectLogic(
      gender,
      {
        'male': 'Mr. $name',
        'female': 'Ms. $name',
        'other': 'Dear $name',
      },
    );
    return '$_temp0';
  }

  @override
  String currentDate(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Today is $dateString';
  }

  @override
  String price(double amount) {
    final intl.NumberFormat amountNumberFormat = intl.NumberFormat.currency(
        locale: localeName, symbol: '\$', decimalDigits: 2);
    final String amountString = amountNumberFormat.format(amount);

    return 'Price: $amountString';
  }

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get followSystem => 'Follow System';

  @override
  String get chinese => 'Chinese';

  @override
  String get english => 'English';

  @override
  String get switchLanguage => 'Switch Language';

  @override
  String get basicTranslation => 'Basic Translation';

  @override
  String get pluralGenderDate => 'Plural / Gender / Date';

  @override
  String get solutionComparison => 'Solutions';

  @override
  String get currentLocale => 'Current Locale';

  @override
  String get knowledgePointTitle => 'Knowledge Point';

  @override
  String get tryItOut => 'Try it out';

  @override
  String get codeReference => 'Code Reference';

  @override
  String get pluralDemo => 'Plural Messages';

  @override
  String get genderDemo => 'Gender-Aware Messages';

  @override
  String get dateFormatDemo => 'Date Formatting';

  @override
  String get numberFormatDemo => 'Number Formatting';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get other => 'Other';

  @override
  String get officialSolution => 'Official Solution';

  @override
  String get officialSolutionDesc =>
      'flutter_localizations + intl + ARB files, recommended by Flutter team. Type-safe, good tooling support, but requires code generation step.';

  @override
  String get easyLocalization => 'easy_localization';

  @override
  String get easyLocalizationDesc =>
      'Supports JSON/YAML/CSV formats, hot reload friendly, simpler setup. No code generation required, but less type-safe.';

  @override
  String get slang => 'slang';

  @override
  String get slangDesc =>
      'Type-safe with code generation from JSON/YAML. Supports linked translations, interfaces, and modifiers. Rising star in the community.';

  @override
  String get feature => 'Feature';

  @override
  String get recommended => 'Recommended ✅';
}
