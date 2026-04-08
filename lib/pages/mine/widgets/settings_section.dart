import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:my_flutter_app/res/colors.dart';
import 'package:my_flutter_app/providers/theme_provider.dart';

class SettingsSection extends ConsumerWidget {
  const SettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Appearance Section (外观设置)
        _buildSectionTitle('外观设置', isDark),
        _buildSectionContainer([
          _buildThemeItem(
            context: context,
            ref: ref,
            themeMode: themeMode,
            isDark: isDark,
          ),
        ], isDark),

        // Basic Functionality Section
        _buildSectionTitle('基础功能', isDark),
        _buildSectionContainer([
          _buildListItem(
              context: context,
              icon: Icons.notifications,
              title: '提醒设置',
              onTap: () => context.push('/mine/reminder'),
              showBorder: false,
              isDark: isDark),
        ], isDark),

        // Privacy & Security Section
        _buildSectionTitle('隐私与安全', isDark),
        _buildSectionContainer([
          _buildListItem(
              context: context,
              icon: Icons.lock,
              title: '账号安全',
              onTap: () => context.push('/mine/security'),
              showBorder: true,
              isDark: isDark),
          _buildListItem(
              context: context,
              icon: Icons.info,
              title: '关于应用',
              onTap: () => context.push('/mine/about'),
              showBorder: false,
              isDark: isDark),
        ], isDark),

        // Developer Tools Section
        _buildSectionTitle('开发者工具', isDark),
        _buildSectionContainer([
          _buildListItem(
              context: context,
              icon: Icons.animation,
              title: '动画学习',
              onTap: () => context.push('/mine/animation'),
              showBorder: true,
              isDark: isDark),
          _buildListItem(
              context: context,
              icon: Icons.checklist,
              title: '表单校验',
              onTap: () => context.push('/mine/form_demo'),
              showBorder: true,
              isDark: isDark),
          _buildListItem(
              context: context,
              icon: Icons.view_list_rounded,
              title: '列表优化',
              onTap: () => context.push('/mine/list_demo'),
              showBorder: true,
              isDark: isDark),
          _buildListItem(
              context: context,
              icon: Icons.translate,
              title: 'i18n 国际化',
              onTap: () => context.push('/mine/i18n_demo'),
              showBorder: true,
              isDark: isDark),
          _buildListItem(
              context: context,
              icon: Icons.map_outlined,
              title: '地图示例',
              onTap: () => context.push('/mine/map_demo'),
              showBorder: true,
              isDark: isDark),
          _buildListItem(
              context: context,
              icon: Icons.fingerprint,
              title: '生物识别',
              onTap: () => context.push('/mine/biometric_demo'),
              showBorder: true,
              isDark: isDark),
          _buildListItem(
              context: context,
              icon: Icons.compare_arrows,
              title: '平台通道',
              onTap: () => context.push('/mine/platform_channel_demo'),
              showBorder: true,
              isDark: isDark),
          _buildListItem(
              context: context,
              icon: Icons.battery_charging_full,
              title: '周期与性能',
              onTap: () => context.push('/mine/lifecycle_demo'),
              showBorder: true,
              isDark: isDark),
          _buildListItem(
              context: context,
              icon: Icons.build_circle,
              title: '多环境部署',
              onTap: () => context.push('/mine/cicd_demo'),
              showBorder: true,
              isDark: isDark),
          _buildListItem(
              context: context,
              icon: Icons.chat_bubble_outline,
              title: 'WebSocket 通信',
              onTap: () => context.push('/mine/websocket_demo'),
              showBorder: true,
              isDark: isDark),
          _buildListItem(
              context: context,
              icon: Icons.language,
              title: 'WebView 深度实战',
              onTap: () => context.push('/mine/webview_demo'),
              showBorder: true,
              isDark: isDark),
          _buildListItem(
              context: context,
              icon: Icons.brush,
              title: 'CustomPainter 实战 (已应用)',
              onTap: () {}, // 效果已应用在头像背景
              showBorder: true,
              isDark: isDark),
          _buildListItem(
              context: context,
              icon: Icons.speed,
              title: '性能调优与重绘',
              onTap: () => context.push('/mine/performance_demo'),
              showBorder: true,
              isDark: isDark),
          _buildListItem(
              context: context,
              icon: Icons.data_object,
              title: 'Freezed 代码生成',
              onTap: () => context.push('/mine/freezed_demo'),
              showBorder: true,
              isDark: isDark),
          _buildListItem(
              context: context,
              icon: Icons.api,
              title: 'Retrofit API',
              onTap: () => context.push('/mine/retrofit_demo'),
              showBorder: true,
              isDark: isDark),
          _buildListItem(
              context: context,
              icon: Icons.notifications_active,
              title: '推送通知',
              onTap: () => context.push('/mine/push_demo'),
              showBorder: true,
              isDark: isDark),
          _buildListItem(
              context: context,
              icon: Icons.bar_chart,
              title: '图表可视化',
              onTap: () => context.push('/mine/chart_demo'),
              showBorder: true,
              isDark: isDark),
          _buildListItem(
              context: context,
              icon: Icons.open_in_new,
              title: '外部App唤起 (Deep Link)',
              onTap: () => context.push('/mine/deep_link_map_demo'),
              showBorder: true,
              isDark: isDark),
          _buildListItem(
              context: context,
              icon: Icons.movie_filter,
              title: 'Lottie & 骨架屏动画',
              onTap: () => context.push('/mine/lottie_shimmer_demo'),
              showBorder: true,
              isDark: isDark),
          _buildListItem(
              context: context,
              icon: Icons.handyman,
              title: '常用工具包 (一)',
              onTap: () => context.push('/mine/day37_tools_demo'),
              showBorder: true,
              isDark: isDark),
          _buildListItem(
              context: context,
              icon: Icons.qr_code_scanner,
              title: '常用工具包 (二)',
              onTap: () => context.push('/mine/day38_tools_demo'),
              showBorder: true,
              isDark: isDark),
          _buildListItem(
              context: context,
              icon: Icons.swipe,
              title: '列表侧滑操作',
              onTap: () => context.push('/mine/day39_slidable_demo'),
              showBorder: true,
              isDark: isDark),
          _buildListItem(
              context: context,
              icon: Icons.grid_view,
              title: '瀑布流布局',
              onTap: () => context.push('/mine/day40_staggered_grid_demo'),
              showBorder: true,
              isDark: isDark),
          _buildListItem(
              context: context,
              icon: Icons.message_outlined,
              title: 'Toast & Badge 角标',
              onTap: () => context.push('/mine/day41_toast_badge_demo'),
              showBorder: true,
              isDark: isDark),
          _buildListItem(
              context: context,
              icon: Icons.star_outline,
              title: '评分与虚线',
              onTap: () => context.push('/mine/day42_rating_dotted_demo'),
              showBorder: true,
              isDark: isDark),
          _buildListItem(
              context: context,
              icon: Icons.refresh,
              title: '增强版下拉刷新',
              onTap: () => context.push('/mine/day43_pull_to_refresh_demo'),
              showBorder: true,
              isDark: isDark),
          _buildListItem(
              context: context,
              icon: Icons.cloud_upload_outlined,
              title: 'COS 图片上传',
              onTap: () => context.push('/mine/day44_cos_upload_demo'),
              showBorder: false,
              isDark: isDark),
        ], isDark),
      ],
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 16.w, 8.h),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: isDark
                ? AppColors.textSecondaryDark
                : const Color(0xFF111518).withValues(alpha: 0.5),
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionContainer(List<Widget> children, bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildThemeItem({
    required BuildContext context,
    required WidgetRef ref,
    required AppThemeMode themeMode,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () => _showThemeSelector(context, ref, themeMode),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              alignment: Alignment.center,
              child: Icon(themeMode.icon, color: AppColors.primary, size: 24.w),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                '深色模式',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : const Color(0xFF111518),
                ),
              ),
            ),
            Text(
              themeMode.displayName,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : const Color(0xFF60778A),
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.chevron_right,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : const Color(0xFF60778A),
                size: 24.w),
          ],
        ),
      ),
    );
  }

  void _showThemeSelector(
      BuildContext context, WidgetRef ref, AppThemeMode currentMode) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 8.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[600] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                '选择主题模式',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : Colors.black,
                ),
              ),
              SizedBox(height: 16.h),
              ...AppThemeMode.values.map((mode) => ListTile(
                    leading: Icon(
                      mode.icon,
                      color: currentMode == mode
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.textSecondaryDark
                              : Colors.grey),
                    ),
                    title: Text(
                      mode.displayName,
                      style: TextStyle(
                        color:
                            isDark ? AppColors.textPrimaryDark : Colors.black,
                      ),
                    ),
                    trailing: currentMode == mode
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () {
                      ref.read(themeModeProvider.notifier).setThemeMode(mode);
                      Navigator.pop(context);
                    },
                  )),
              SizedBox(height: 16.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool showBorder = true,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: AppColors.primary, size: 24.w),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : const Color(0xFF111518),
                ),
              ),
            ),
            Icon(Icons.chevron_right,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : const Color(0xFF60778A),
                size: 24.w),
          ],
        ),
      ),
    );
  }
}
