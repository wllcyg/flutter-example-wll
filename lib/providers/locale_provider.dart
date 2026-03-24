import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/storage/shared_prefs_provider.dart';

/// Locale Provider — 管理应用的语言环境
///
/// 设计思路（对标 theme_provider.dart）：
/// - 使用 StateNotifier 管理 Locale? 状态
/// - null 表示"跟随系统"
/// - 非 null 表示用户显式选择的语言
/// - 持久化到 SharedPreferences
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocaleNotifier(prefs);
});

class LocaleNotifier extends StateNotifier<Locale?> {
  final SharedPreferences prefs;

  static const String _key = 'app_locale';

  LocaleNotifier(this.prefs) : super(_loadLocale(prefs));

  /// 从 SharedPreferences 加载持久化的 Locale
  static Locale? _loadLocale(SharedPreferences prefs) {
    final code = prefs.getString(_key);
    if (code == null || code.isEmpty) return null; // 跟随系统
    return Locale(code);
  }

  /// 设置语言
  void setLocale(Locale locale) {
    state = locale;
    prefs.setString(_key, locale.languageCode);
  }

  /// 重置为跟随系统
  void resetToSystem() {
    state = null;
    prefs.remove(_key);
  }

  /// 当前是否为跟随系统
  bool get isFollowingSystem => state == null;
}
