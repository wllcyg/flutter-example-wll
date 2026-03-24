import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:my_flutter_app/res/colors.dart';

/// Flutter 动画学习演示页面
///
/// 动画对比: CSS vs Flutter
/// ========================================
///
/// | CSS 属性/概念         | Flutter 对应              | 说明                          |
/// |-----------------------|---------------------------|-------------------------------|
/// | transition            | AnimatedFoo / TweenAnimation | 隐式动画/补间动画            |
/// | @keyframes            | AnimationController       | 显式动画控制                   |
/// | animation-duration    | Duration                  | 动画时长                       |
/// | animation-timing-function | Curves              | 动画曲线 (ease, linear 等)    |
/// | animation-delay       | Future.delayed / Timer    | 延迟执行                       |
/// | transform: scale()    | ScaleTransition           | 缩放动画                       |
/// | transform: rotate()   | RotationTransition        | 旋转动画                       |
/// | transform: translate()| SlideTransition           | 位移动画                       |
/// | opacity               | FadeTransition            | 透明度动画                     |
/// | CSS Variables         | Tween<T>                  | 动画值插值                     |
/// | :hover                | GestureDetector + setState | 状态变化触发                  |
///
/// Hero 动画 (共享元素过渡)
/// ========================================
/// Flutter 的 Hero 动画类似于 CSS 中的 View Transitions API
/// 它可以在两个页面之间创建平滑的过渡效果，让元素看起来"飞"到新位置
///
/// 使用方法:
/// 1. 在源页面用 Hero 包裹元素，设置 tag
/// 2. 在目标页面用相同 tag 的 Hero 包裹对应元素
/// 3. 使用 Navigator 进行页面跳转，Hero 动画会自动执行

class AnimationDemoPage extends StatefulWidget {
  const AnimationDemoPage({super.key});

  @override
  State<AnimationDemoPage> createState() => _AnimationDemoPageState();
}

class _AnimationDemoPageState extends State<AnimationDemoPage>
    with TickerProviderStateMixin {
  // 隐式动画状态
  bool _isExpanded = false;
  double _opacity = 1.0;

  // 显式动画控制器
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // 旋转动画控制器 (类似 CSS: animation: rotate 2s linear infinite)
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(); // 无限循环

    // 脉冲动画控制器 (类似 CSS: animation: pulse 1s ease-in-out infinite)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true); // 往返循环

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          '动画学习',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor:
            isDark ? Theme.of(context).colorScheme.surface : Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('1️⃣ 隐式动画 (Implicit Animations)', isDark),
            _buildDescription(
              'CSS 等价: transition: all 0.3s ease;\n'
              'Flutter 使用 AnimatedFoo 系列组件自动处理状态变化',
              isDark,
            ),
            _buildImplicitAnimationDemo(isDark),
            SizedBox(height: 24.h),
            _buildSectionTitle('2️⃣ 显式动画 (Explicit Animations)', isDark),
            _buildDescription(
              'CSS 等价: @keyframes + animation\n'
              'Flutter 使用 AnimationController 手动控制动画',
              isDark,
            ),
            _buildExplicitAnimationDemo(isDark),
            SizedBox(height: 24.h),
            _buildSectionTitle('3️⃣ Hero 动画 (共享元素过渡)', isDark),
            _buildDescription(
              'CSS 等价: View Transitions API\n'
              '点击卡片查看 Hero 动画效果',
              isDark,
            ),
            _buildHeroAnimationDemo(isDark),
            SizedBox(height: 24.h),
            _buildSectionTitle('4️⃣ 常用曲线对比', isDark),
            _buildCurvesDemo(isDark),
            SizedBox(height: 100.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.textPrimaryDark : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDescription(String text, bool isDark) {
    return Container(
      padding: EdgeInsets.all(12.w),
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13.sp,
          color: isDark ? AppColors.textSecondaryDark : Colors.black54,
          height: 1.5,
        ),
      ),
    );
  }

  /// 隐式动画演示
  Widget _buildImplicitAnimationDemo(bool isDark) {
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
        children: [
          // AnimatedContainer 演示
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: _isExpanded ? 200.w : 100.w,
              height: _isExpanded ? 100.h : 50.h,
              decoration: BoxDecoration(
                color: _isExpanded ? Colors.orange : AppColors.primary,
                borderRadius: BorderRadius.circular(_isExpanded ? 20.r : 8.r),
              ),
              alignment: Alignment.center,
              child: Text(
                '点击展开/收缩',
                style: TextStyle(color: Colors.white, fontSize: 12.sp),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // AnimatedOpacity 演示
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedOpacity(
                opacity: _opacity,
                duration: const Duration(milliseconds: 500),
                child: Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child:
                      Icon(Icons.visibility, color: Colors.white, size: 24.w),
                ),
              ),
              SizedBox(width: 16.w),
              ElevatedButton(
                onPressed: () => setState(() {
                  _opacity = _opacity == 1.0 ? 0.2 : 1.0;
                }),
                child: const Text('切换透明度'),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // AnimatedDefaultTextStyle 演示
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: _isExpanded ? 24.sp : 14.sp,
              fontWeight: _isExpanded ? FontWeight.bold : FontWeight.normal,
              color: _isExpanded ? Colors.orange : AppColors.primary,
            ),
            child: const Text('动态文字样式'),
          ),
        ],
      ),
    );
  }

  /// 显式动画演示
  Widget _buildExplicitAnimationDemo(bool isDark) {
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // RotationTransition 演示
          Column(
            children: [
              RotationTransition(
                turns: _rotationController,
                child: Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.blue, Colors.purple],
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(Icons.refresh, color: Colors.white, size: 24.w),
                ),
              ),
              SizedBox(height: 8.h),
              Text('无限旋转',
                  style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark ? Colors.white70 : Colors.black54)),
            ],
          ),

          // ScaleTransition 演示 (脉冲效果)
          Column(
            children: [
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.favorite, color: Colors.white, size: 24.w),
                ),
              ),
              SizedBox(height: 8.h),
              Text('脉冲效果',
                  style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark ? Colors.white70 : Colors.black54)),
            ],
          ),
        ],
      ),
    );
  }

  /// Hero 动画演示
  Widget _buildHeroAnimationDemo(bool isDark) {
    final items = [
      {
        'tag': 'hero_1',
        'color': Colors.indigo,
        'icon': Icons.rocket_launch,
        'title': '火箭'
      },
      {
        'tag': 'hero_2',
        'color': Colors.teal,
        'icon': Icons.nature,
        'title': '自然'
      },
      {
        'tag': 'hero_3',
        'color': Colors.amber,
        'icon': Icons.star,
        'title': '星星'
      },
    ];

    return SizedBox(
      height: 120.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: () {
              context.push('/mine/animation_detail', extra: item);
            },
            child: Container(
              width: 100.w,
              margin: EdgeInsets.only(right: 12.w),
              child: Column(
                children: [
                  Hero(
                    tag: item['tag'] as String,
                    child: Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        color: item['color'] as Color,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (item['color'] as Color).withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: Colors.white,
                        size: 32.w,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    item['title'] as String,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 动画曲线对比演示
  Widget _buildCurvesDemo(bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCurveRow('linear', 'CSS: linear', Curves.linear, isDark),
          _buildCurveRow('ease', 'CSS: ease', Curves.ease, isDark),
          _buildCurveRow('easeIn', 'CSS: ease-in', Curves.easeIn, isDark),
          _buildCurveRow('easeOut', 'CSS: ease-out', Curves.easeOut, isDark),
          _buildCurveRow(
              'easeInOut', 'CSS: ease-in-out', Curves.easeInOut, isDark),
          _buildCurveRow(
              'bounceOut', 'CSS: cubic-bezier (弹跳)', Curves.bounceOut, isDark),
          _buildCurveRow('elasticOut', 'CSS: cubic-bezier (弹性)',
              Curves.elasticOut, isDark),
        ],
      ),
    );
  }

  Widget _buildCurveRow(
      String name, String cssEquivalent, Curve curve, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          SizedBox(
            width: 100.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87)),
                Text(cssEquivalent,
                    style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
              ],
            ),
          ),
          Expanded(
            child: _CurveAnimationDemo(curve: curve),
          ),
        ],
      ),
    );
  }
}

/// 单个曲线动画演示组件
class _CurveAnimationDemo extends StatefulWidget {
  final Curve curve;
  const _CurveAnimationDemo({required this.curve});

  @override
  State<_CurveAnimationDemo> createState() => _CurveAnimationDemoState();
}

class _CurveAnimationDemoState extends State<_CurveAnimationDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = CurvedAnimation(parent: _controller, curve: widget.curve);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: 20.h,
          alignment: Alignment.centerLeft,
          child: Transform.translate(
            offset: Offset(_animation.value * 150.w, 0),
            child: Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}
