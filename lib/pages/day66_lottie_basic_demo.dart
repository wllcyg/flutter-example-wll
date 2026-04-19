import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_flutter_app/res/colors.dart';

class Day66LottieBasicDemo extends StatefulWidget {
  const Day66LottieBasicDemo({super.key});

  @override
  State<Day66LottieBasicDemo> createState() => _Day66LottieBasicDemoState();
}

class _Day66LottieBasicDemoState extends State<Day66LottieBasicDemo> {
  bool _isAnimating = true;
  bool _repeat = true;
  bool _reverse = false;

  final List<Map<String, String>> _networkAnimations = [
    {
      'title': '成功状态',
      'url': 'https://assets10.lottiefiles.com/packages/lf20_Z98v7v.json'
    },
    {
      'title': '加载中',
      'url': 'https://assets10.lottiefiles.com/packages/lf20_hp6reS.json'
    },
    {
      'title': '空状态',
      'url': 'https://assets10.lottiefiles.com/packages/lf20_K7a9Dz.json'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Day 66: Lottie 基础'),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('1. 本地资源加载 (Asset)'),
            _buildCard(
              child: Column(
                children: [
                  Lottie.asset(
                    'assets/lottie/loading.json',
                    width: 200.w,
                    height: 200.w,
                    animate: _isAnimating,
                    repeat: _repeat,
                    reverse: _reverse,
                  ),
                  SizedBox(height: 16.h),
                  const Text('加载自 assets/lottie/loading.json',
                      style: TextStyle(color: Colors.grey)),
                  _buildControls(),
                ],
              ),
            ),
            _buildSectionTitle('2. 网络资源加载 (Network)'),
            SizedBox(
              height: 180.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: _networkAnimations.length,
                itemBuilder: (context, index) {
                  final item = _networkAnimations[index];
                  return _buildNetworkItem(item['url']!, item['title']!);
                },
              ),
            ),
            _buildSectionTitle('3. 常用实战场景'),
            _buildSceneGrid(),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 12.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: EdgeInsets.only(top: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildControlButton(
            icon: _isAnimating ? Icons.pause : Icons.play_arrow,
            label: _isAnimating ? '暂停' : '播放',
            onTap: () => setState(() => _isAnimating = !_isAnimating),
          ),
          _buildControlButton(
            icon: Icons.repeat,
            label: _repeat ? '循环开' : '循环关',
            onTap: () => setState(() => _repeat = !_repeat),
            isActive: _repeat,
          ),
          _buildControlButton(
            icon: Icons.swap_horiz,
            label: _reverse ? '正序' : '反序',
            onTap: () => setState(() => _reverse = !_reverse),
            isActive: _reverse,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon,
              color: isActive ? AppColors.primary : Colors.grey, size: 28.w),
          SizedBox(height: 4.h),
          Text(label,
              style: TextStyle(
                fontSize: 12.sp,
                color: isActive ? AppColors.primary : Colors.grey,
              )),
        ],
      ),
    );
  }

  Widget _buildNetworkItem(String url, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 140.w,
      margin: EdgeInsets.only(right: 12.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.network(
            url,
            width: 100.w,
            height: 100.w,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.error_outline, color: Colors.red);
            },
          ),
          SizedBox(height: 8.h),
          Text(title, style: TextStyle(fontSize: 14.sp)),
        ],
      ),
    );
  }

  Widget _buildSceneGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      mainAxisSpacing: 12.w,
      crossAxisSpacing: 12.w,
      childAspectRatio: 1.2,
      children: [
        _buildSceneCard('启动页动画', Icons.rocket_launch, Colors.blue),
        _buildSceneCard('空页面提示', Icons.folder_open, Colors.orange),
        _buildSceneCard('加载反馈', Icons.hourglass_bottom, Colors.purple),
        _buildSceneCard('操作结果', Icons.check_circle_outline, Colors.green),
      ],
    );
  }

  Widget _buildSceneCard(String title, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32.w),
          SizedBox(height: 8.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
