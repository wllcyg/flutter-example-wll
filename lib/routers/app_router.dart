import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_app/view_models/auth_view_model.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../pages/login/login_page.dart';
import '../pages/register/register_page.dart';
import '../pages/calendar_add/calendar_add_page.dart';
import '../pages/splash/splash_page.dart';
import '../pages/home/home_page.dart';
import '../pages/timeline/timeline_page.dart';
import '../pages/statistics/statistics_page.dart';
import '../pages/mine/mine_page.dart';
import '../pages/main/main_page.dart';
import '../pages/mine/subpages/edit_profile_page.dart';
import '../pages/mine/subpages/reminder_settings_page.dart';
import '../pages/mine/subpages/security_page.dart';
import '../pages/mine/subpages/about_page.dart';
import '../pages/home/subpages/diary_detail_page.dart';
import '../pages/animation_demo/animation_demo_page.dart';
import '../pages/animation_demo/animation_detail_page.dart';
import '../pages/form_demo/form_demo_page.dart';
import '../pages/list_demo/list_demo_page.dart';
import '../pages/i18n_demo/i18n_demo_page.dart';
import '../pages/map_demo/map_demo_page.dart';
import '../pages/biometric_demo/biometric_demo_page.dart';
import '../pages/platform_channel_demo/platform_channel_demo_page.dart';
import '../pages/lifecycle_demo/lifecycle_demo_page.dart';
import '../pages/cicd_demo/cicd_demo_page.dart';
import '../pages/websocket_demo/websocket_demo_page.dart';
import '../pages/performance_demo/performance_demo_page.dart';
import '../models/diary_entry.dart';
import '../pages/webview_demo/webview_demo_page.dart';
import '../pages/freezed_demo/freezed_demo_page.dart';
import '../pages/retrofit_demo/retrofit_demo_page.dart';
import '../pages/push_demo/push_demo_page.dart';
import '../pages/chart_demo/chart_demo_page.dart';
import '../pages/deep_link_demo/deep_link_map_demo_page.dart';
import '../pages/lottie_shimmer_demo/lottie_shimmer_demo_page.dart';
import '../pages/day37_tools_demo.dart';
import '../pages/day38_tools_demo.dart';
import '../pages/day39_slidable_demo.dart';
import '../pages/day40_staggered_grid_demo.dart';
import '../pages/day41_toast_badge_demo.dart';
import '../pages/day42_rating_dotted_demo.dart';
import '../pages/day43_pull_to_refresh_demo.dart';

part 'app_router.g.dart';

// 使用 riverpod_generator 生成 Provider
@riverpod
GoRouter goRouter(Ref ref) {
  // 1. 监听 Auth 状态变化 (使用 select 只监听登录状态，避免用户信息更新导致重置)
  final isLoggedIn =
      ref.watch(authViewModelProvider.select((s) => s.isLoggedIn));

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true, // 打印路由日志
    // 2. 配置重定向
    redirect: (context, state) {
      final path = state.uri.path;

      // 允许访问的白名单 (Splash, Login, Register)
      final isPublic =
          path == '/splash' || path == '/login' || path == '/register';

      // 场景 1: 未登录且访问受保护页面 -> 跳转登录
      if (!isLoggedIn && !isPublic) {
        return '/login';
      }

      // 场景 2: 已登录且如果在登录/注册页 -> 跳转首页
      // 注意：保留 Splash 以便播放动画
      if (isLoggedIn && (path == '/login' || path == '/register')) {
        return '/home';
      }

      // 正常通行
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/calendar_add',
        name: 'calendar_add',
        parentNavigatorKey: null, // 显式指定根导航器，确保覆盖底部导航
        pageBuilder: (context, state) {
          final entry = state.extra as DiaryEntry?;
          return _slideTransition(
              context, state, CalendarAddPage(entry: entry));
        },
      ),
      GoRoute(
        path: '/detail/:id',
        name: 'detail',
        parentNavigatorKey: null,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          final entry = state.extra as DiaryEntry?;
          return _slideTransition(
              context, state, DiaryDetailPage(id: id, entry: entry));
        },
      ),

      // 使用 StatefulShellRoute 实现底部导航
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainPage(navigationShell: navigationShell);
        },
        branches: [
          // Tab 1: 首页
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          // Tab 2: 时间轴
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/timeline',
                name: 'timeline',
                builder: (context, state) => const TimelinePage(),
              ),
            ],
          ),
          // Tab 3: 统计
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/statistics',
                name: 'statistics',
                builder: (context, state) => const StatisticsPage(),
              ),
            ],
          ),
          // Tab 4: 我的
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/mine',
                name: 'mine',
                builder: (context, state) => const MinePage(),
                routes: [
                  GoRoute(
                    path: 'profile',
                    name: 'mine_profile',
                    parentNavigatorKey: null, // Full screen
                    pageBuilder: (context, state) => _slideTransition(
                        context, state, const EditProfilePage()),
                  ),
                  GoRoute(
                    path: 'reminder',
                    name: 'mine_reminder',
                    parentNavigatorKey: null,
                    pageBuilder: (context, state) => _slideTransition(
                        context, state, const ReminderSettingsPage()),
                  ),
                  GoRoute(
                    path: 'security',
                    name: 'mine_security',
                    parentNavigatorKey: null,
                    pageBuilder: (context, state) =>
                        _slideTransition(context, state, const SecurityPage()),
                  ),
                  GoRoute(
                    path: 'about',
                    name: 'mine_about',
                    parentNavigatorKey: null,
                    pageBuilder: (context, state) =>
                        _slideTransition(context, state, const AboutPage()),
                  ),
                  GoRoute(
                    path: 'animation',
                    name: 'mine_animation',
                    parentNavigatorKey: null,
                    pageBuilder: (context, state) => _slideTransition(
                        context, state, const AnimationDemoPage()),
                  ),
                  GoRoute(
                    path: 'animation_detail',
                    name: 'mine_animation_detail',
                    parentNavigatorKey: null,
                    pageBuilder: (context, state) {
                      final item = state.extra as Map<String, dynamic>;
                      return _slideTransition(
                          context, state, AnimationDetailPage(item: item));
                    },
                  ),
                  GoRoute(
                    path: 'form_demo',
                    name: 'mine_form_demo',
                    parentNavigatorKey: null,
                    pageBuilder: (context, state) =>
                        _slideTransition(context, state, const FormDemoPage()),
                  ),
                  GoRoute(
                    path: 'list_demo',
                    name: 'mine_list_demo',
                    parentNavigatorKey: null,
                    pageBuilder: (context, state) =>
                        _slideTransition(context, state, const ListDemoPage()),
                  ),
                  GoRoute(
                    path: 'i18n_demo',
                    name: 'mine_i18n_demo',
                    parentNavigatorKey: null,
                    pageBuilder: (context, state) =>
                        _slideTransition(context, state, const I18nDemoPage()),
                  ),
                  GoRoute(
                    path: 'map_demo',
                    name: 'mine_map_demo',
                    parentNavigatorKey: null,
                    pageBuilder: (context, state) =>
                        _slideTransition(context, state, const MapDemoPage()),
                  ),
                  GoRoute(
                    path: 'biometric_demo',
                    name: 'mine_biometric_demo',
                    parentNavigatorKey: null,
                    pageBuilder: (context, state) => _slideTransition(
                        context, state, const BiometricDemoPage()),
                  ),
                  GoRoute(
                    path: 'platform_channel_demo',
                    name: 'mine_platform_channel_demo',
                    parentNavigatorKey: null,
                    pageBuilder: (context, state) => _slideTransition(
                        context, state, const PlatformChannelDemoPage()),
                  ),
                  GoRoute(
                    path: 'websocket_demo',
                    name: 'mine_websocket_demo',
                    parentNavigatorKey: null,
                    pageBuilder: (context, state) => _slideTransition(
                        context, state, const WebsocketDemoPage()),
                  ),
                  GoRoute(
                    path: 'performance_demo',
                    name: 'mine_performance_demo',
                    parentNavigatorKey: null,
                    pageBuilder: (context, state) => _slideTransition(
                        context, state, const PerformanceDemoPage()),
                  ),
                  GoRoute(
                    path: 'lifecycle_demo',
                    name: 'mine_lifecycle_demo',
                    parentNavigatorKey: null,
                    pageBuilder: (context, state) => _slideTransition(
                        context, state, const LifecycleDemoPage()),
                  ),
                  GoRoute(
                    path: 'cicd_demo',
                    name: 'mine_cicd_demo',
                    parentNavigatorKey: null,
                    pageBuilder: (context, state) =>
                        _slideTransition(context, state, const CicdDemoPage()),
                  ),
                  GoRoute(
                    path: 'webview_demo',
                    name: 'mine_webview_demo',
                    parentNavigatorKey: null,
                    pageBuilder: (context, state) => _slideTransition(
                        context, state, const WebViewDemoPage()),
                  ),
                  GoRoute(
                    path: 'freezed_demo',
                    name: 'mine_freezed_demo',
                    parentNavigatorKey: null,
                    pageBuilder: (context, state) => _slideTransition(
                        context, state, const FreezedDemoPage()),
                  ),
                  GoRoute(
                    path: 'retrofit_demo',
                    name: 'mine_retrofit_demo',
                    parentNavigatorKey: null,
                    pageBuilder: (context, state) => _slideTransition(
                        context, state, const RetrofitDemoPage()),
                  ),
                  GoRoute(
                    path: 'push_demo',
                    name: 'mine_push_demo',
                    parentNavigatorKey: null,
                    pageBuilder: (context, state) => _slideTransition(
                        context, state, const PushDemoPage()),
                  ),
                  GoRoute(
                    path: 'chart_demo',
                    name: 'mine_chart_demo',
                    parentNavigatorKey: null,
                    pageBuilder: (context, state) => _slideTransition(
                        context, state, const ChartDemoPage()),
                  ),
                  GoRoute(
                    path: 'deep_link_map_demo',
                    name: 'mine_deep_link_map_demo',
                    parentNavigatorKey: null,
                    pageBuilder: (context, state) => _slideTransition(
                        context, state, const DeepLinkMapDemoPage()),
                  ),
                  GoRoute(
                    path: 'lottie_shimmer_demo',
                    name: 'mine_lottie_shimmer_demo',
                    parentNavigatorKey: null,
                    pageBuilder: (context, state) => _slideTransition(
                        context, state, const LottieShimmerDemoPage()),
                  ),
                  GoRoute(
                    path: 'day37_tools_demo',
                    name: 'mine_day37_tools_demo',
                    parentNavigatorKey: null,
                    pageBuilder: (context, state) => _slideTransition(
                        context, state, const Day37ToolsDemo()),
                  ),
                  GoRoute(
                    path: 'day38_tools_demo',
                    name: 'mine_day38_tools_demo',
                    parentNavigatorKey: null,
                    pageBuilder: (context, state) => _slideTransition(
                        context, state, const Day38ToolsDemo()),
                  ),
                  GoRoute(
                    path: 'day39_slidable_demo',
                    name: 'mine_day39_slidable_demo',
                    parentNavigatorKey: null,
                    pageBuilder: (context, state) => _slideTransition(
                        context, state, const Day39SlidableDemoHooks()),
                  ),
                  GoRoute(
                    path: 'day40_staggered_grid_demo',
                    name: 'mine_day40_staggered_grid_demo',
                    parentNavigatorKey: null,
                    pageBuilder: (context, state) => _slideTransition(
                        context, state, const Day40StaggeredGridDemo()),
                  ),
                  GoRoute(
                    path: 'day41_toast_badge_demo',
                    name: 'mine_day41_toast_badge_demo',
                    parentNavigatorKey: null,
                    pageBuilder: (context, state) => _slideTransition(
                        context, state, const Day41ToastBadgeDemo()),
                  ),
                  GoRoute(
                    path: 'day42_rating_dotted_demo',
                    name: 'mine_day42_rating_dotted_demo',
                    parentNavigatorKey: null,
                    pageBuilder: (context, state) => _slideTransition(
                        context, state, const Day42RatingDottedDemo()),
                  ),
                  GoRoute(
                    path: 'day43_pull_to_refresh_demo',
                    name: 'mine_day43_pull_to_refresh_demo',
                    parentNavigatorKey: null,
                    pageBuilder: (context, state) => _slideTransition(
                        context, state, const Day43PullToRefreshDemo()),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

// --- Animation Helpers ---

// iOS-style Slide Transition (Right to Left)
Page<dynamic> _slideTransition(
    BuildContext context, GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Slide from right (Offset(1, 0)) to center (Offset.zero)
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
