import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_flutter_app/models/post_item.dart';
import 'package:my_flutter_app/models/paged_state.dart';
import 'package:my_flutter_app/providers/paged_posts_provider.dart';
import 'package:my_flutter_app/res/colors.dart';

/// Day 19 学习示例：列表性能优化 Demo 页面
///
/// 核心知识点：
/// 1. ListView vs ListView.builder vs ListView.separated — 渲染策略对比
/// 2. RefreshIndicator — 下拉刷新（对标前端 pull-to-refresh）
/// 3. ScrollController + 上拉加载更多 — 监听滚动到底触发加载
/// 4. PagedState<T> — 分页数据模型设计
/// 5. Riverpod AsyncNotifier — 管理分页状态
/// 6. Sliver 系列组件 — SliverAppBar / SliverList / SliverGrid 组合布局
/// 7. const 构造 / itemExtent / AutomaticKeepAlive — 常见优化
class ListDemoPage extends HookConsumerWidget {
  const ListDemoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Day 19：列表优化'),
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor:
                isDark ? AppColors.textSecondaryDark : Colors.grey,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
            tabs: const [
              Tab(text: 'ListView 对比'),
              Tab(text: '分页列表'),
              Tab(text: 'Sliver 布局'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ListViewComparisonTab(),
            _PaginatedListTab(),
            _SliverDemoTab(),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Tab 1: ListView 对比
// ============================================================

class _ListViewComparisonTab extends StatelessWidget {
  const _ListViewComparisonTab();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 知识点说明卡片
          _KnowledgeCard(
            isDark: isDark,
            title: 'ListView 三兄弟区别',
            points: const [
              '📌 ListView(children) — 一次性构建所有子项，适合短列表（<20个）',
              '🚀 ListView.builder — 懒加载按需构建，适合长列表（推荐）',
              '📏 ListView.separated — 在 builder 基础上自动插入分隔符',
            ],
          ),
          SizedBox(height: 16.h),

          // 方式 1: 普通 ListView
          _SectionHeader(title: '① ListView(children: [...])', isDark: isDark),
          SizedBox(height: 8.h),
          _buildBasicListView(isDark),
          SizedBox(height: 24.h),

          // 方式 2: ListView.builder
          _SectionHeader(title: '② ListView.builder', isDark: isDark),
          SizedBox(height: 8.h),
          _buildBuilderListView(isDark),
          SizedBox(height: 24.h),

          // 方式 3: ListView.separated
          _SectionHeader(title: '③ ListView.separated', isDark: isDark),
          SizedBox(height: 8.h),
          _buildSeparatedListView(isDark),
          SizedBox(height: 24.h),

          // 优化提示
          _KnowledgeCard(
            isDark: isDark,
            title: '💡 性能优化小贴士',
            points: const [
              'const 构造 — 告诉 Flutter 该 Widget 不会变，跳过重建',
              'itemExtent — 固定列表项高度，提升滚动性能',
              'AutomaticKeepAlive — Tab 切换时保持列表项状态',
              'RepaintBoundary — 隔离重绘区域，减少 GPU 开销',
            ],
          ),
        ],
      ),
    );
  }

  /// 普通 ListView：一次性构建所有 children
  Widget _buildBasicListView(bool isDark) {
    return Container(
      height: 200.h,
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: ListView(
          // ⚠️ 这种方式会一次性构建所有 Widget
          // 对标前端：Array.map 直接渲染（无虚拟列表）
          padding: EdgeInsets.symmetric(vertical: 4.h),
          children: List.generate(
            10,
            (index) => _SimpleListTile(
              index: index,
              tag: 'basic',
              isDark: isDark,
            ),
          ),
        ),
      ),
    );
  }

  /// ListView.builder：懒加载按需构建
  Widget _buildBuilderListView(bool isDark) {
    return Container(
      height: 200.h,
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: ListView.builder(
          // ✅ 只构建可见区域的 Widget，性能优秀
          // 对标前端：react-window / vue-virtual-scroller
          padding: EdgeInsets.symmetric(vertical: 4.h),
          itemCount: 100,
          itemExtent: 56.h, // ✅ 固定高度优化：Flutter 无需逐个测量
          itemBuilder: (context, index) => _SimpleListTile(
            index: index,
            tag: 'builder',
            isDark: isDark,
          ),
        ),
      ),
    );
  }

  /// ListView.separated：自带分隔线
  Widget _buildSeparatedListView(bool isDark) {
    return Container(
      height: 200.h,
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: ListView.separated(
          // ✅ 自动在每两个 item 之间插入 separatorBuilder
          // 对标前端：Array.flatMap + 分隔符节点
          padding: EdgeInsets.symmetric(vertical: 4.h),
          itemCount: 50,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            indent: 72.w,
            color: isDark ? Colors.grey[800] : Colors.grey[200],
          ),
          itemBuilder: (context, index) => _SimpleListTile(
            index: index,
            tag: 'separated',
            isDark: isDark,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Tab 2: 分页列表（下拉刷新 + 上拉加载）
// ============================================================

class _PaginatedListTab extends HookConsumerWidget {
  const _PaginatedListTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pagedPostsAsync = ref.watch(pagedPostsProvider);

    // ScrollController — 监听滚动到底
    final scrollController = useScrollController();

    // 注册滚动监听
    useEffect(() {
      void onScroll() {
        // 距离底部 200px 时触发加载
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          ref.read(pagedPostsProvider.notifier).loadMore();
        }
      }

      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, [scrollController]);

    return pagedPostsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.w, color: Colors.red),
            SizedBox(height: 16.h),
            Text('加载失败: $err',
                style: TextStyle(fontSize: 14.sp, color: Colors.red)),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => ref.invalidate(pagedPostsProvider),
              child: const Text('重试'),
            ),
          ],
        ),
      ),
      data: (pagedState) => RefreshIndicator(
        // ✅ 下拉刷新（对标前端 pull-to-refresh）
        onRefresh: () => ref.read(pagedPostsProvider.notifier).refresh(),
        color: AppColors.primary,
        child: ListView.builder(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(), // 确保能触发下拉刷新
          itemCount: pagedState.items.length + 1, // +1 用于底部状态指示器
          itemBuilder: (context, index) {
            // 最后一项：加载状态指示器
            if (index == pagedState.items.length) {
              return _buildLoadMoreIndicator(pagedState, isDark);
            }

            // 正常列表项
            final item = pagedState.items[index];
            return _PostCard(item: item, isDark: isDark);
          },
        ),
      ),
    );
  }

  /// 底部加载更多指示器
  Widget _buildLoadMoreIndicator(PagedState<PostItem> state, bool isDark) {
    if (state.isLoadingMore) {
      // 正在加载
      return Container(
        padding: EdgeInsets.all(16.h),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16.w,
              height: 16.w,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              '正在加载更多...',
              style: TextStyle(
                fontSize: 13.sp,
                color: isDark ? AppColors.textSecondaryDark : Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (!state.hasMore) {
      // 没有更多数据
      return Container(
        padding: EdgeInsets.all(20.h),
        alignment: Alignment.center,
        child: Column(
          children: [
            Container(
              width: 40.w,
              height: 2.h,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(1.r),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '— 已经到底啦 —',
              style: TextStyle(
                fontSize: 13.sp,
                color: isDark ? AppColors.textSecondaryDark : Colors.grey,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              '共 ${state.items.length} 条数据',
              style: TextStyle(
                fontSize: 12.sp,
                color: isDark
                    ? AppColors.textSecondaryDark.withValues(alpha: 0.6)
                    : Colors.grey[400],
              ),
            ),
          ],
        ),
      );
    }

    // 有更多数据，等待触发
    return SizedBox(height: 20.h);
  }
}

// ============================================================
// Tab 3: Sliver 布局
// ============================================================

class _SliverDemoTab extends StatelessWidget {
  const _SliverDemoTab();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomScrollView(
      // ✅ CustomScrollView 是 Sliver 系列的容器
      // 可以组合多种 Sliver 组件实现复杂的滚动布局
      slivers: [
        // 1. SliverAppBar — 可折叠头部
        SliverAppBar(
          expandedHeight: 200.h,
          floating: false,
          pinned: true, // 收起后 AppBar 固定在顶部
          automaticallyImplyLeading: false,
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.primary,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              'Sliver 组合布局',
              style: TextStyle(fontSize: 16.sp, color: Colors.white),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.7),
                    Colors.deepPurple,
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.layers, size: 48.w, color: Colors.white70),
                    SizedBox(height: 8.h),
                    Text(
                      '向上滑动查看折叠效果 ↑',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // 2. SliverToBoxAdapter — 放置任意非 Sliver Widget
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: _KnowledgeCard(
              isDark: isDark,
              title: 'Sliver 知识要点',
              points: const [
                'SliverAppBar — 可折叠/浮动的顶部栏',
                'SliverList — 列表（同 ListView.builder）',
                'SliverGrid — 网格（同 GridView.builder）',
                'SliverToBoxAdapter — 包裹普通 Widget',
                'SliverPersistentHeader — 悬浮吸顶头部',
              ],
            ),
          ),
        ),

        // 3. SliverPersistentHeader — 悬浮吸顶标题
        SliverPersistentHeader(
          pinned: true,
          delegate: _SectionHeaderDelegate(
            title: '📋 SliverList 区域',
            isDark: isDark,
          ),
        ),

        // 4. SliverList — 列表区域
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _SimpleListTile(
              index: index,
              tag: 'sliver-list',
              isDark: isDark,
            ),
            childCount: 5,
          ),
        ),

        // 5. SliverPersistentHeader — 另一个吸顶标题
        SliverPersistentHeader(
          pinned: true,
          delegate: _SectionHeaderDelegate(
            title: '🔲 SliverGrid 区域',
            isDark: isDark,
          ),
        ),

        // 6. SliverGrid — 网格区域
        SliverPadding(
          padding: EdgeInsets.all(12.w),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 1.4,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _GridCard(index: index, isDark: isDark),
              childCount: 8,
            ),
          ),
        ),

        // 7. 底部间距
        SliverToBoxAdapter(
          child: SizedBox(height: 32.h),
        ),
      ],
    );
  }
}

// ============================================================
// 通用 UI 组件
// ============================================================

/// 知识点卡片
class _KnowledgeCard extends StatelessWidget {
  final bool isDark;
  final String title;
  final List<String> points;

  const _KnowledgeCard({
    required this.isDark,
    required this.title,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.primary.withValues(alpha: 0.15)
            : AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
            ),
          ),
          SizedBox(height: 8.h),
          ...points.map((point) => Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Text(
                  point,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color:
                        isDark ? AppColors.textSecondaryDark : Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

/// Section 小标题
class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;

  const _SectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.textPrimaryDark : const Color(0xFF111518),
      ),
    );
  }
}

/// 简单列表项（用于 ListView 对比）
class _SimpleListTile extends StatelessWidget {
  final int index;
  final String tag;
  final bool isDark;

  const _SimpleListTile({
    required this.index,
    required this.tag,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];
    final color = colors[index % colors.length];

    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 18.r,
        backgroundColor: color.withValues(alpha: 0.15),
        child: Text(
          '${index + 1}',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
      title: Text(
        '列表项 #${index + 1}（$tag）',
        style: TextStyle(
          fontSize: 14.sp,
          color: isDark ? AppColors.textPrimaryDark : const Color(0xFF111518),
        ),
      ),
      subtitle: Text(
        '这是第 ${index + 1} 个列表项的描述文本',
        style: TextStyle(
          fontSize: 12.sp,
          color: isDark ? AppColors.textSecondaryDark : Colors.grey,
        ),
      ),
    );
  }
}

/// 帖子卡片（用于分页列表）
class _PostCard extends StatelessWidget {
  final PostItem item;
  final bool isDark;

  const _PostCard({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 序号头像
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            alignment: Alignment.center,
            child: Text(
              '#${item.id}',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 12.w),

          // 文本区域
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : const Color(0xFF111518),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color:
                        isDark ? AppColors.textSecondaryDark : Colors.grey[600],
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 14.w,
                      color: Colors.red[300],
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${item.likes}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : Colors.grey[500],
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Icon(
                      Icons.access_time,
                      size: 14.w,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : Colors.grey[400],
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      _formatTime(item.createdAt),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    return '${diff.inDays}天前';
  }
}

/// 网格卡片（用于 SliverGrid）
class _GridCard extends StatelessWidget {
  final int index;
  final bool isDark;

  const _GridCard({required this.index, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final colors = [
      [const Color(0xFF667EEA), const Color(0xFF764BA2)],
      [const Color(0xFFF093FB), const Color(0xFFF5576C)],
      [const Color(0xFF4FACFE), const Color(0xFF00F2FE)],
      [const Color(0xFF43E97B), const Color(0xFF38F9D7)],
      [const Color(0xFFFA709A), const Color(0xFFFEE140)],
      [const Color(0xFFA18CD1), const Color(0xFFFBC2EB)],
      [const Color(0xFFFCCB90), const Color(0xFFD57EEB)],
      [const Color(0xFF09203F), const Color(0xFF537895)],
    ];
    final gradient = colors[index % colors.length];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [gradient[0], gradient[1]],
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _gridIcons[index % _gridIcons.length],
              size: 28.w,
              color: Colors.white,
            ),
            SizedBox(height: 8.h),
            Text(
              'Grid ${index + 1}',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _gridIcons = [
    Icons.dashboard,
    Icons.star,
    Icons.favorite,
    Icons.bookmark,
    Icons.lightbulb,
    Icons.palette,
    Icons.rocket_launch,
    Icons.auto_awesome,
  ];
}

/// SliverPersistentHeader 的 Delegate
class _SectionHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  final bool isDark;

  _SectionHeaderDelegate({required this.title, required this.isDark});

  @override
  double get minExtent => 48.h;

  @override
  double get maxExtent => 48.h;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: 48.h,
      color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F7FA),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.textPrimaryDark : const Color(0xFF111518),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SectionHeaderDelegate oldDelegate) {
    return title != oldDelegate.title || isDark != oldDelegate.isDark;
  }
}
