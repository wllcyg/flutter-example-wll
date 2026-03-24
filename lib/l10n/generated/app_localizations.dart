import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Minimal Diary'**
  String get appTitle;

  /// A simple greeting message
  ///
  /// In en, this message translates to:
  /// **'Hello!'**
  String get greeting;

  /// A welcome message with user name parameter
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}!'**
  String welcomeUser(String name);

  /// Display item count
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String itemCount(int count);

  /// Unread message count with plural support (ICU plural syntax)
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No unread messages} =1{1 unread message} other{{count} unread messages}}'**
  String unreadMessages(num count);

  /// Gender-aware greeting (ICU select syntax)
  ///
  /// In en, this message translates to:
  /// **'{gender, select, male{Mr. {name}} female{Ms. {name}} other{Dear {name}}}'**
  String userGreeting(String gender, String name);

  /// Display current date with formatted date parameter
  ///
  /// In en, this message translates to:
  /// **'Today is {date}'**
  String currentDate(DateTime date);

  /// Display a formatted price
  ///
  /// In en, this message translates to:
  /// **'Price: {amount}'**
  String price(double amount);

  /// Settings label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Follow system locale option
  ///
  /// In en, this message translates to:
  /// **'Follow System'**
  String get followSystem;

  /// Chinese language option
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get chinese;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Switch language section title
  ///
  /// In en, this message translates to:
  /// **'Switch Language'**
  String get switchLanguage;

  /// Tab title for basic translation demos
  ///
  /// In en, this message translates to:
  /// **'Basic Translation'**
  String get basicTranslation;

  /// Tab title for plural, gender, date formatting demos
  ///
  /// In en, this message translates to:
  /// **'Plural / Gender / Date'**
  String get pluralGenderDate;

  /// Tab title for i18n solution comparison
  ///
  /// In en, this message translates to:
  /// **'Solutions'**
  String get solutionComparison;

  /// Label for showing current locale information
  ///
  /// In en, this message translates to:
  /// **'Current Locale'**
  String get currentLocale;

  /// Knowledge point section title
  ///
  /// In en, this message translates to:
  /// **'Knowledge Point'**
  String get knowledgePointTitle;

  /// Interactive section title
  ///
  /// In en, this message translates to:
  /// **'Try it out'**
  String get tryItOut;

  /// Code reference section label
  ///
  /// In en, this message translates to:
  /// **'Code Reference'**
  String get codeReference;

  /// Plural demo section title
  ///
  /// In en, this message translates to:
  /// **'Plural Messages'**
  String get pluralDemo;

  /// Gender demo section title
  ///
  /// In en, this message translates to:
  /// **'Gender-Aware Messages'**
  String get genderDemo;

  /// Date formatting demo section title
  ///
  /// In en, this message translates to:
  /// **'Date Formatting'**
  String get dateFormatDemo;

  /// Number format demo section title
  ///
  /// In en, this message translates to:
  /// **'Number Formatting'**
  String get numberFormatDemo;

  /// Male gender option
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// Female gender option
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// Other gender option
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// Official i18n solution label
  ///
  /// In en, this message translates to:
  /// **'Official Solution'**
  String get officialSolution;

  /// Description of official solution
  ///
  /// In en, this message translates to:
  /// **'flutter_localizations + intl + ARB files, recommended by Flutter team. Type-safe, good tooling support, but requires code generation step.'**
  String get officialSolutionDesc;

  /// easy_localization package name
  ///
  /// In en, this message translates to:
  /// **'easy_localization'**
  String get easyLocalization;

  /// Description of easy_localization
  ///
  /// In en, this message translates to:
  /// **'Supports JSON/YAML/CSV formats, hot reload friendly, simpler setup. No code generation required, but less type-safe.'**
  String get easyLocalizationDesc;

  /// slang package name
  ///
  /// In en, this message translates to:
  /// **'slang'**
  String get slang;

  /// Description of slang
  ///
  /// In en, this message translates to:
  /// **'Type-safe with code generation from JSON/YAML. Supports linked translations, interfaces, and modifiers. Rising star in the community.'**
  String get slangDesc;

  /// Feature column header
  ///
  /// In en, this message translates to:
  /// **'Feature'**
  String get feature;

  /// Recommended label
  ///
  /// In en, this message translates to:
  /// **'Recommended ✅'**
  String get recommended;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
