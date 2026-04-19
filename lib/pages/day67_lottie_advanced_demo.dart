import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_flutter_app/res/colors.dart';

class Day67LottieAdvancedDemo extends StatefulWidget {
  const Day67LottieAdvancedDemo({super.key});

  @override
  State<Day67LottieAdvancedDemo> createState() => _Day67LottieAdvancedDemoState();
}

class _Day67LottieAdvancedDemoState extends State<Day67LottieAdvancedDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double _animationProgress = 0.0;
  Color _customColor = AppColors.primary;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    // 监听进度变化
    _controller.addListener(() {
      setState(() {
        _animationProgress = _controller.value;
      });
    });

    // 监听状态变化 (如播放完成)
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        debugPrint('Animation Completed!');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Day 67: Lottie 进阶'),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildAnimationCard(isDark),
            _buildControlPanel(isDark),
            _buildColorPanel(isDark),
            _buildInfoSection(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimationCard(bool isDark) {
    return Container(
      width: double.infinity,
      height: 300.h,
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          if (!isDark)
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5))
        ],
      ),
      child: Center(
        child: Lottie.asset(
          'assets/lottie/loading.json',
          controller: _controller,
          width: 250.w,
          height: 250.w,
          onLoaded: (composition) {
            // 设置控制器时长与动画文件一致
            _controller.duration = composition.duration;
          },
          delegates: LottieDelegates(
            values: [
              // 演示动态修改颜色 (需要 JSON 中有对应的层级名称，此处为通用示例)
              ValueDelegate.color(
                const ['**', 'Fill 1'],
                value: _customColor,
              ),
              ValueDelegate.color(
                const ['**', 'Stroke 1'],
                value: _customColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlPanel(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('当前进度', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${(_animationProgress * 100).toStringAsFixed(1)}%'),
            ],
          ),
          Slider(
            value: _animationProgress,
            activeColor: AppColors.primary,
            onChanged: (val) {
              _controller.value = val;
            },
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionBtn(Icons.play_arrow, '播放', () => _controller.forward()),
              _buildActionBtn(Icons.pause, '暂停', () => _controller.stop()),
              _buildActionBtn(Icons.replay, '重置', () => _controller.reset()),
              _buildActionBtn(Icons.fast_rewind, '倒放', () => _controller.reverse()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorPanel(bool isDark) {
    final colors = [
      AppColors.primary,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.cyan
    ];
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('动态颜色修改', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: colors.map((c) {
              return InkWell(
                onTap: () => setState(() => _customColor = c),
                child: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _customColor == c ? Colors.white : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: c.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(bool isDark) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            _buildInfoItem('Controller 集成', '使用 AnimationController 实现精确控制'),
            _buildInfoItem('帧跳转', '滑块可直接定位到动画的任意百分比进度'),
            _buildInfoItem('颜色替换', '使用 ValueDelegate 实现运行时的主题换肤'),
            _buildInfoItem('内存管理', 'Dispose 页面时自动释放动画控制器'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String title, String desc) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: AppColors.primary, size: 18),
          SizedBox(width: 8.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                children: [
                  TextSpan(
                      text: '$title: ',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: desc),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, String label, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }
}
