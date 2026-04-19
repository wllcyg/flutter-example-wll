import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:my_flutter_app/res/colors.dart';

class Day69SkeletonizerDemo extends StatefulWidget {
  const Day69SkeletonizerDemo({super.key});

  @override
  State<Day69SkeletonizerDemo> createState() => _Day69SkeletonizerDemoState();
}

class _Day69SkeletonizerDemoState extends State<Day69SkeletonizerDemo> {
  bool _isLoading = true;

  // Mock data
  final List<Map<String, String>> _users = [
    {
      'name': 'Alisa Carpenter',
      'job': 'Product Designer',
      'avatar': 'https://i.pravatar.cc/150?u=1',
    },
    {
      'name': 'Jimmy Wright',
      'job': 'Software Engineer',
      'avatar': 'https://i.pravatar.cc/150?u=2',
    },
    {
      'name': 'Suzi Swanson',
      'job': 'Marketing Manager',
      'avatar': 'https://i.pravatar.cc/150?u=3',
    },
    {
      'name': 'Frankie Meyer',
      'job': 'HR Director',
      'avatar': 'https://i.pravatar.cc/150?u=4',
    },
    {
      'name': 'Clementine Gentry',
      'job': 'Sales Executive',
      'avatar': 'https://i.pravatar.cc/150?u=5',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Simulate initial loading
    _simulateLoading();
  }

  void _simulateLoading() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Day 69: 自动骨架屏'),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _simulateLoading,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Control Header
          _buildControlHeader(isDark),

          // Main Content with Skeletonizer
          Expanded(
            child: Skeletonizer(
              enabled: _isLoading,
              child: _buildUserList(isDark),
            ),
          ),

          // Comparison/Tips Footer
          _buildFooter(isDark),
        ],
      ),
    );
  }

  Widget _buildControlHeader(bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.primary, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              '当前正在展示数据加载状态的自动转换效果。',
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
          Switch(
            value: _isLoading,
            activeColor: AppColors.primary,
            onChanged: (val) => setState(() => _isLoading = val),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(bool isDark) {
    return ListView.builder(
      itemCount: _users.length,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemBuilder: (context, index) {
        final user = _users[index];
        return Card(
          elevation: 0,
          margin: EdgeInsets.only(bottom: 12.h),
          color: isDark ? AppColors.surfaceDark : Colors.grey[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: BorderSide(
              color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                // Avatar - Automatic Circle Shape
                ClipRRect(
                  borderRadius: BorderRadius.circular(30.r),
                  child: Image.network(
                    user['avatar']!,
                    width: 60.w,
                    height: 60.w,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 60.w,
                      height: 60.w,
                      color: AppColors.primary.withValues(alpha: 0.1),
                      child: Icon(Icons.person, color: AppColors.primary),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['name']!,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        user['job']!,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                // Demo of Skeleton.ignore - This button won't be skeletonized
                Skeleton.ignore(
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Connect'),
                  ),
                ),
                // Demo of Skeleton.keep - This icon keeps its shape but stays visible
                Skeleton.keep(
                  child: Icon(
                    Icons.more_vert,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter(bool isDark) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Skeletonizer 核心优势：',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 8.h),
          _buildTipRow('✅ 零重复：无需为加载态手写第二套 UI 代码。'),
          _buildTipRow('✅ 结构同步：真实布局变动，骨架屏自动同步。'),
          _buildTipRow('✅ 智能识别：自动推断图片、文字和容器形状。'),
          _buildTipRow('✅ 高度定制：支持排除特定组件 (Skeleton.ignore)。'),
        ],
      ),
    );
  }

  Widget _buildTipRow(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Text(
        text,
        style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
      ),
    );
  }
}
