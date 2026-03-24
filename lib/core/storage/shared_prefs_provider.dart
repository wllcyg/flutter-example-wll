import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1. 获取持久化实例的 Provider
// 先抛出 UnimplementedError，在 main.dart 中获取实例后 override
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(' sharedPreferencesProvider 未被初始化');
});

// 2. 一个具体业务配置的 Provider 样例（如主题模式）
class AppSettingsNotifier extends StateNotifier<bool> {
  final SharedPreferences prefs;

  AppSettingsNotifier(this.prefs) : super(prefs.getBool('isDark') ?? false);

  void toggleTheme() {
    state = !state;
    prefs.setBool('isDark', state);
  }
}

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AppSettingsNotifier(prefs);
});
