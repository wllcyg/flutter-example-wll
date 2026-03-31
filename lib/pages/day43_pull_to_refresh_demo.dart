import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'dart:async';

/// Day 43: 增强版下拉刷新 —— pull_to_refresh
/// 
/// 该组件解决了 Flutter 原生 RefreshIndicator 的两大痛点：
/// 1. 不支持“上拉加载更多”。
/// 2. 状态反馈（刷新成功/失败/无更多数据）不够直观。
/// 
/// 本 Demo 演示了如何将 pull_to_refresh 与 Riverpod 结合，
/// 实现一个具备高度交互感的分页列表。

// ==================== Data Model ====================

class NewsItem {
  final String id;
  final String title;
  final String description;
  final String time;

  NewsItem({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
  });
}

// ==================== State Management (Riverpod) ====================

class NewsState {
  final List<NewsItem> items;
  final bool hasMore;
  final int page;

  NewsState({
    required this.items,
    required this.hasMore,
    required this.page,
  });

  NewsState copyWith({
    List<NewsItem>? items,
    bool? hasMore,
    int? page,
  }) {
    return NewsState(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
    );
  }
}

class NewsNotifier extends AutoDisposeAsyncNotifier<NewsState> {
  @override
  FutureOr<NewsState> build() async {
    // 初始加载第一页数据
    return _fetchData(page: 1);
  }

  Future<NewsState> _fetchData({required int page}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(seconds: 2));

    // 模拟分页数据（每页 10 条，总共 3 页）
    if (page > 3) {
      final currentState = state.value;
      return currentState!.copyWith(hasMore: false);
    }

    final newItems = List.generate(
      10,
      (index) => NewsItem(
        id: '${page}_$index',
        title: '🔥 热门资讯 # ${(page - 1) * 10 + index + 1}',
        description: '这是一条模拟的深度新闻报道内容，揭秘了 Flutter 生态中 pull_to_refresh 的高级用法以及如何构建极致体验的分页列表。',
        time: '${DateTime.now().hour}:${DateTime.now().minute}',
      ),
    );

    if (page == 1) {
      return NewsState(items: newItems, hasMore: true, page: 1);
    } else {
      final currentState = state.value;
      return currentState!.copyWith(
        items: [...currentState.items, ...newItems],
        page: page,
        hasMore: page < 3, // 假设总共 3 页
      );
    }
  }

  /// 下拉刷新
  Future<void> refresh(RefreshController controller) async {
    try {
      state = const AsyncValue.loading();
      final newState = await _fetchData(page: 1);
      state = AsyncValue.data(newState);
      controller.refreshCompleted();
      controller.resetNoData(); // 刷新后重置“无更多数据”状态
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      controller.refreshFailed();
    }
  }

  /// 上拉加载更多
  Future<void> loadMore(RefreshController controller) async {
    final currentState = state.value;
    if (currentState == null || !currentState.hasMore) {
      controller.loadNoData();
      return;
    }

    try {
      final newState = await _fetchData(page: currentState.page + 1);
      state = AsyncValue.data(newState);
      if (newState.hasMore) {
        controller.loadComplete();
      } else {
        controller.loadNoData();
      }
    } catch (e) {
      controller.loadFailed();
    }
  }
}

final newsProvider = AsyncNotifierProvider.autoDispose<NewsNotifier, NewsState>(() {
  return NewsNotifier();
});

// ==================== UI Components ====================

class Day43PullToRefreshDemo extends HookConsumerWidget {
  const Day43PullToRefreshDemo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsState = ref.watch(newsProvider);
    final refreshController = useMemoized(() => RefreshController(initialRefresh: false));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Day 43: 增强版下拉刷新'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showExplainDialog(context),
          )
        ],
      ),
      body: newsState.when(
        data: (data) => _buildList(context, ref, data, refreshController),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('加载失败: $err'),
              ElevatedButton(
                onPressed: () => ref.invalidate(newsProvider),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    NewsState state,
    RefreshController controller,
  ) {
    return SmartRefresher(
      controller: controller,
      enablePullDown: true,
      enablePullUp: true,
      // 自定义 Header (水滴效果)
      header: const WaterDropHeader(
        waterDropColor: Colors.blueAccent,
        refresh: CircularProgressIndicator(strokeWidth: 2),
        complete: Icon(Icons.check, color: Colors.green),
      ),
      // 自定义 Footer (带状态文字)
      footer: CustomFooter(
        builder: (context, mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            body = const Text("上拉加载更多");
          } else if (mode == LoadStatus.loading) {
            body = const CircularProgressIndicator(strokeWidth: 2);
          } else if (mode == LoadStatus.failed) {
            body = const Text("加载失败！点击重试！");
          } else if (mode == LoadStatus.canLoading) {
            body = const Text("松手，加载更多");
          } else {
            body = const Text("没有更多数据啦 ☕️");
          }
          return SizedBox(
            height: 55.0,
            child: Center(child: body),
          );
        },
      ),
      onRefresh: () => ref.read(newsProvider.notifier).refresh(controller),
      onLoading: () => ref.read(newsProvider.notifier).loadMore(controller),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (c, i) => _buildNewsCard(state.items[i]),
        separatorBuilder: (c, i) => const SizedBox(height: 12),
        itemCount: state.items.length,
      ),
    );
  }

  Widget _buildNewsCard(NewsItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'TRENDING',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                item.time,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3436),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF636E72),
              height: 1.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.remove_red_eye_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              const Text('1.2k', style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(width: 16),
              const Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              const Text('85', style: TextStyle(color: Colors.grey, fontSize: 12)),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text('了解更多'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showExplainDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('技术解析'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• SmartRefresher: 核心驱动容器。'),
            Text('• WaterDropHeader: 经典的类似 iOS 的水滴效果。'),
            Text('• CustomFooter: 通过 LoadStatus 自定义加载完成、失败、无数据后的 UI。'),
            Text('• Riverpod Bridge: 将 Controller 的生命周期状态（Completed, Failed）与 Provider 同步。'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }
}
