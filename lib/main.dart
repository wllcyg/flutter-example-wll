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

Future<void> main() async {
  // 确保 FlutterBinding 已初始化
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // 1. 保留原生启动屏，阻止白屏，覆盖整个底层初始化期间
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 初始化 FlutterDownloader
  await FlutterDownloader.initialize(debug: true, ignoreSsl: true);

  // 初始化环境变量
  await dotenv.load(fileName: ".env");

  // 初始化 Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    authOptions: FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
      localStorage: SecureLocalStorage(),
    ),
  );

  // 阻断式：先获取 SharedPreferences 实例
  final prefs = await SharedPreferences.getInstance();

  // 初始化本地通知服务
  await NotificationService().init();

  // 2. 所有的核心耗时任务（网络请求配置、本地数据库）已结束
  // 在渲染 Flutter 首帧前移除原生视图遮罩，平滑交接给 Flutter 内部 SplashPage
  FlutterNativeSplash.remove();

  runApp(
    // 1. Riverpod 的状态容器，包裹在最外层
    ProviderScope(
      overrides: [
        // 关键：将未实现的 provider 覆盖为真实已就绪的实例！
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2. 监听路由 Provider (GoRouter)
    final router = ref.watch(goRouterProvider);
    // 监听主题模式
    final themeMode = ref.watch(themeModeProvider);

    // 3. 屏幕适配初始化
    return ScreenUtilInit(
      designSize: const Size(375, 812), // 设计稿尺寸 (通常是 iPhone X)
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        // 4. 使用 MaterialApp.router
        return MaterialApp.router(
          title: '极简日记',
          debugShowCheckedModeBanner: false,

          // 路由配置
          routerConfig: router,

          // 主题配置 (支持深色模式切换)
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode.flutterThemeMode,

          // 国际化配置 — Day 20
          // 使用 gen-l10n 生成的 delegate + 手动追加 FlutterQuill
          localizationsDelegates: const [
            ...AppLocalizations.localizationsDelegates,
            FlutterQuillLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          // 动态切换语言：null = 跟随系统
          locale: ref.watch(localeProvider),

          // 初始化 SmartDialog，必须加这句，否则 Toast/Loading 不会显示
          builder: FlutterSmartDialog.init(),
        );
      },
    );
  }
}
