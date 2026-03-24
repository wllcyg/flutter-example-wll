import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/storage/shared_prefs_provider.dart';

/// 主题模式枚举
enum AppThemeMode {
  system, // 跟随系统
  light, // 浅色模式
  dark, // 深色模式
}

/// 主题模式 Provider
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, AppThemeMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeModeNotifier(prefs);
});

/// 主题模式状态管理
class ThemeModeNotifier extends StateNotifier<AppThemeMode> {
  final SharedPreferences prefs;

  ThemeModeNotifier(this.prefs) : super(_loadThemeMode(prefs));

  static const String _key = 'theme_mode';

  /// 从本地存储加载主题模式 (同步)
  static AppThemeMode _loadThemeMode(SharedPreferences prefs) {
    final modeIndex = prefs.getInt(_key) ?? 0;
    return AppThemeMode.values[modeIndex];
  }

  /// 设置主题模式
  void setThemeMode(AppThemeMode mode) {
    state = mode;
    prefs.setInt(_key, mode.index);
  }

  /// 切换主题模式 (循环切换)
  void toggleThemeMode() {
    final nextIndex = (state.index + 1) % AppThemeMode.values.length;
    setThemeMode(AppThemeMode.values[nextIndex]);
  }
}

/// 获取 Flutter 的 ThemeMode
extension AppThemeModeExtension on AppThemeMode {
  ThemeMode get flutterThemeMode {
    switch (this) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }

  String get displayName {
    switch (this) {
      case AppThemeMode.system:
        return '跟随系统';
      case AppThemeMode.light:
        return '浅色模式';
      case AppThemeMode.dark:
        return '深色模式';
    }
  }

  IconData get icon {
    switch (this) {
      case AppThemeMode.system:
        return Icons.brightness_auto;
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
    }
  }
}
