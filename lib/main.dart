import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_flutter_app/utils/secure_storage.dart';
import 'package:my_flutter_app/services/notification_service.dart';

import 'l10n/generated/app_localizations.dart';
import 'routers/app_router.dart';
import 'res/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_flutter_app/core/storage/shared_prefs_provider.dart';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  // 1. 确保 FlutterBinding 已初始化
  developer.Timeline.startSync('App Startup');
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // 2. 原生启动屏逻辑 (必须在第一步执行，避免白屏)
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 3. 初始化 Sentry (快速初始化，不阻塞关键业务)
  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://30ace7c2588f3fe42b1bf26625f5c15f@o4511244500467712.ingest.us.sentry.io/4511244502106112';
      options.tracesSampleRate = 1.0;
      options.environment = 'development';
    },
    appRunner: () async {
      SharedPreferences? prefs;
      try {
        // 4. 执行关键初始化任务 (Critical Path)
        developer.Timeline.startSync('Critical Path Init');

        // A. 先加载环境变量 (Supabase 依赖它)
        await _initEnv();

        // B. 并行初始化 Supabase 和 SharedPreferences
        final results = await Future.wait([
          _initSupabase(),
          _initPrefs(),
        ]);

        prefs = results[1] as SharedPreferences;
        developer.Timeline.finishSync(); // End Critical Path Init

        // 5. 非关键初始化任务 (Don't wait, let them run in background)
        _initNonCriticalServices();
      } catch (e, stack) {
        debugPrint('Initialization error: $e');
        await Sentry.captureException(e, stackTrace: stack);
      } finally {
        // 6. 无论成功失败，移除启动屏 (避免永久卡住)
        FlutterNativeSplash.remove();
        developer.Timeline.finishSync(); // End App Startup
      }

      runApp(
        ProviderScope(
          overrides: [
            if (prefs != null) sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const MyApp(),
        ),
      );
    },
  );
}

// --- 分离初始化函数，便于在 Timeline 中追踪 ---

Future<void> _initEnv() async {
  developer.Timeline.startSync('Load .env');
  await dotenv.load(fileName: ".env");
  developer.Timeline.finishSync();
}

Future<void> _initSupabase() async {
  developer.Timeline.startSync('Init Supabase');
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    authOptions: FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
      localStorage: SecureLocalStorage(),
    ),
  );
  developer.Timeline.finishSync();
}

Future<SharedPreferences> _initPrefs() async {
  developer.Timeline.startSync('Get SharedPreferences');
  final prefs = await SharedPreferences.getInstance();
  developer.Timeline.finishSync();
  return prefs;
}

/// 初始化非关键性服务，不阻塞首屏渲染
void _initNonCriticalServices() {
  debugPrint('Initializing non-critical services in background...');
  
  // 1. FlutterDownloader
  FlutterDownloader.initialize(debug: true, ignoreSsl: true);
  
  // 2. 本地通知服务
  NotificationService().init();
  
  // 3. 其他非核心服务以后可以在这里添加
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: '极简日记',
          debugShowCheckedModeBanner: false,
          builder: FlutterSmartDialog.init(),
          routerConfig: router,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode.flutterThemeMode,
          localizationsDelegates: const [
            ...AppLocalizations.localizationsDelegates,
            FlutterQuillLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: ref.watch(localeProvider),
        );
      },
    );
  }
}
