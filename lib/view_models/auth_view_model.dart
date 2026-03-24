import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_view_model.g.dart';

// --- State 定义 ---
// 虽然 Supabase 有自己的 User 对象，但我们可能需要包装一些加载状态
class AuthState {
  final User? user;
  final bool isLoading;
  final String? errorMessage; // 简单的错误消息存储

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isLoggedIn => user != null;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // 允许置空
    );
  }
}

// --- ViewModel (Notifier) ---

// 使用 @riverpod 注解自动生成 Provider
// run: dart run build_runner build
@riverpod
class AuthViewModel extends _$AuthViewModel {
  final _supabase = Supabase.instance.client;

  @override
  AuthState build() {
    // 监听 Supabase 的 Auth 状态变化 (登录、登出等)
    _supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      // 当发生 AuthChange 时，更新我们的 State
      state = state.copyWith(user: session?.user);
    });

    // 初始状态：检查当前是否有用户
    return AuthState(user: _supabase.auth.currentUser);
  }

  // --- Actions ---

  // 邮箱 + 密码登录
  Future<bool> signInWithPassword({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      debugPrint("AuthViewModel: 正在尝试登录... Email: $email");
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      debugPrint(
          "AuthViewModel: 登录请求完成. User ID: ${response.user?.id}, Session: ${response.session != null ? '存在' : '为空'}");
      // 成功后，监听器会自动更新 user 状态，这里只需要重置 loading
      state = state.copyWith(isLoading: false);
      return response.user != null;
    } on AuthException catch (e) {
      debugPrint(
          "AuthViewModel: 登录失败 (AuthException) - Code: ${e.statusCode}, Msg: ${e.message}");
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      debugPrint("AuthViewModel: 登录失败 (Unknown) - $e");
      state = state.copyWith(isLoading: false, errorMessage: '未知错误: $e');
      return false;
    }
  }

  // 登出
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await _supabase.auth.signOut();
    // 显式清空 user 状态，确保导航到登录页时不会被 useEffect 重定向
    state = const AuthState(user: null, isLoading: false);
  }

  // 刷新用户信息
  Future<void> refreshUser() async {
    try {
      final response = await _supabase.auth.refreshSession();
      if (response.user != null) {
        state = state.copyWith(user: response.user);
      }
    } catch (e) {
      debugPrint("AuthViewModel: 刷新用户失败 - $e");
    }
  }

  // 重置错误信息
  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }
}
