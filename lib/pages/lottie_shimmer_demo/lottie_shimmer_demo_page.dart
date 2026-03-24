import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:my_flutter_app/res/colors.dart';

class LottieShimmerDemoPage extends ConsumerStatefulWidget {
  const LottieShimmerDemoPage({super.key});

  @override
  ConsumerState<LottieShimmerDemoPage> createState() => _LottieShimmerDemoPageState();
}

class _LottieShimmerDemoPageState extends ConsumerState<LottieShimmerDemoPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late final AnimationController _lottieController;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // 初始化 Lottie 动画控制器
    _lottieController = AnimationController(vsync: this);

    // 模拟数据加载，3秒后隐藏骨架屏
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        elevation: 0,
        title: Text(
          'Lottie & 骨架屏',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black,
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: '骨架屏'),
            Tab(text: 'Lottie 播放'),
            Tab(text: '空状态动画'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildShimmerTab(isDark),
          _buildLottieControlTab(isDark),
          _buildEmptyStateTab(isDark),
        ],
      ),
    );
  }

  // === Tab 1: 骨架屏演示 ===
  Widget _buildShimmerTab(bool isDark) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '内容列表',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              Switch(
                value: _isLoading,
                activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                activeThumbColor: AppColors.primary,
                onChanged: (val) {
                  setState(() {
                    _isLoading = val;
                  });
                },
              )
            ],
          ),
        ),
        Expanded(
          child: _isLoading ? _buildShimmerList(isDark) : _buildDataList(isDark),
        ),
      ],
    );
  }

  Widget _buildShimmerList(bool isDark) {
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return ListView.builder(
      itemCount: 6,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemBuilder: (_, __) => Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60.w,
                height: 60.w,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 14.h,
                      color: Colors.white,
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      width: 150.w,
                      height: 12.h,
                      color: Colors.white,
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      width: 100.w,
                      height: 12.h,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataList(bool isDark) {
    return ListView.builder(
      itemCount: 6,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemBuilder: (_, index) => Container(
        margin: EdgeInsets.only(bottom: 16.h),
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
          children: [
            CircleAvatar(
              radius: 30.r,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Icon(Icons.person, color: AppColors.primary, size: 30.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '用户昵称 $index',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '这是一条加载完成的真实数据内容描述...',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === Tab 2: Lottie 控制演示 ===
  Widget _buildLottieControlTab(bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Container(
            height: 300.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                )
              ],
            ),
            child: Lottie.network(
              'https://raw.githubusercontent.com/xvrh/lottie-flutter/master/example/assets/Mobilo/A.json',
              controller: _lottieController,
              onLoaded: (composition) {
                // Configure the AnimationController with the duration of the
                // Lottie file and start the animation.
                _lottieController
                  ..duration = composition.duration
                  ..forward()
                  ..repeat();
              },
            ),
          ),
          SizedBox(height: 24.h),
          Wrap(
            spacing: 16.w,
            runSpacing: 16.h,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => _lottieController.forward(),
                icon: const Icon(Icons.play_arrow),
                label: const Text('播放'),
              ),
              ElevatedButton.icon(
                onPressed: () => _lottieController.stop(),
                icon: const Icon(Icons.stop),
                label: const Text('停止'),
              ),
              ElevatedButton.icon(
                onPressed: () => _lottieController.repeat(),
                icon: const Icon(Icons.loop),
                label: const Text('循环'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  _lottieController.reset();
                  _lottieController.forward();
                },
                icon: const Icon(Icons.replay),
                label: const Text('重置并播放'),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Text(
            '这里使用了 Lottie.network 也就是从网络加载 JSON。也可以使用 Lottie.asset 加载本地资产。',
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }

  // === Tab 3: 空状态/错误状态动画 ===
  Widget _buildEmptyStateTab(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // A popular empty state lottie
          SizedBox(
            height: 250.h,
            child: Lottie.network(
              'https://raw.githubusercontent.com/xvrh/lottie-flutter/master/example/assets/HamburgerArrow.json',
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            '什么都没有找到喔...',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '相比于静态的图片，使用 Lottie\n能够大幅度提升空页面的趣味性和用户体验',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          SizedBox(height: 32.h),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.r),
              ),
            ),
            child: const Text('去看看其他'),
          ),
        ],
      ),
    );
  }
}
