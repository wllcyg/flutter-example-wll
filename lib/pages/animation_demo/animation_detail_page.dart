import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:my_flutter_app/res/colors.dart';

/// Hero 动画详情页面
///
/// Hero 动画的工作原理:
/// ========================================
/// 1. Flutter 在路由切换时会查找相同 tag 的 Hero 组件
/// 2. 计算起始位置和结束位置
/// 3. 创建一个 "overlay" 层，将 Hero 组件放在这个层上
/// 4. 在动画期间，这个 overlay 层的位置会从起始位置平滑过渡到结束位置
/// 5. 动画完成后，overlay 消失，组件回到正常的 widget tree 中
///
/// CSS 对比:
/// ========================================
/// Hero 动画类似于 CSS 的 View Transitions API:
///
/// ```css
/// /* CSS View Transitions */
/// ::view-transition-old(hero-image),
/// ::view-transition-new(hero-image) {
///   animation-duration: 0.3s;
/// }
/// ```
///
/// 或者使用 FLIP 动画技术 (First, Last, Invert, Play)

class AnimationDetailPage extends StatelessWidget {
  final Map<String, dynamic> item;

  const AnimationDetailPage({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tag = item['tag'] as String;
    final color = item['color'] as Color;
    final icon = item['icon'] as IconData;
    final title = item['title'] as String;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.h,
            pinned: true,
            backgroundColor: color,
            leading: IconButton(
              icon: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back, color: Colors.white, size: 20.w),
              ),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Center(
                child: Hero(
                  tag: tag,
                  child: Container(
                    width: 150.w,
                    height: 150.w,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.5),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 64.w,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildInfoCard(
                    '🚀 Hero 动画原理',
                    'Hero 动画通过在两个页面之间创建一个 Overlay 层，'
                        '将共享元素放在这个层上进行动画过渡。\n\n'
                        '关键点:\n'
                        '• 两个页面的 Hero 必须有相同的 tag\n'
                        '• 使用 Navigator 进行页面跳转\n'
                        '• 动画会自动计算起始和结束位置',
                    isDark,
                  ),
                  SizedBox(height: 16.h),
                  _buildCodeCard(
                    'Flutter 代码',
                    '''// 源页面
Hero(
  tag: 'unique_tag',
  child: Image.asset('image.png'),
)

// 目标页面 (使用相同 tag)
Hero(
  tag: 'unique_tag',
  child: Image.asset('image.png'),
)''',
                    isDark,
                  ),
                  SizedBox(height: 16.h),
                  _buildCodeCard(
                    'CSS 等价 (View Transitions API)',
                    '''/* CSS View Transitions */
.hero-element {
  view-transition-name: hero-image;
}

::view-transition-old(hero-image),
::view-transition-new(hero-image) {
  animation-duration: 300ms;
  animation-timing-function: ease-in-out;
}''',
                    isDark,
                  ),
                  SizedBox(height: 16.h),
                  _buildInfoCard(
                    '💡 使用技巧',
                    '1. Hero tag 必须是全局唯一的\n'
                        '2. 可以使用 flightShuttleBuilder 自定义过渡动画\n'
                        '3. 使用 placeholderBuilder 处理动画期间的占位\n'
                        '4. 确保两个 Hero 的 child 比例一致，避免变形',
                    isDark,
                  ),
                  SizedBox(height: 100.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String content, bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            content,
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.6,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeCard(String title, String code, bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.code, color: Colors.green, size: 18.w),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            code,
            style: TextStyle(
              fontSize: 12.sp,
              fontFamily: 'monospace',
              color: Colors.white,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
