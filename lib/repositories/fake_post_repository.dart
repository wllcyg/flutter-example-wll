import 'dart:math';
import 'package:my_flutter_app/models/post_item.dart';

/// 模拟后端 API 的 Repository
///
/// 用 Future.delayed 模拟网络延迟，生成假数据，支持分页请求。
/// 对标前端的 mock API / json-server。
class FakePostRepository {
  static const int _totalItems = 85; // 总数据量，模拟有限数据集
  final _random = Random();

  /// 模拟分页获取帖子列表
  ///
  /// - [page]：页码，从 1 开始
  /// - [pageSize]：每页条数，默认 20
  /// - 返回：当前页的数据列表
  /// - 当 page * pageSize >= _totalItems 时返回空列表表示没有更多数据
  Future<List<PostItem>> fetchPosts({
    int page = 1,
    int pageSize = 20,
  }) async {
    // 模拟网络延迟 (800ms ~ 1500ms)
    await Future.delayed(
      Duration(milliseconds: 800 + _random.nextInt(700)),
    );

    // 模拟偶尔的网络错误 (约 5% 概率)
    // if (_random.nextInt(20) == 0) {
    //   throw Exception('网络异常，请稍后重试');
    // }

    // 计算当前页的数据范围
    final startIndex = (page - 1) * pageSize;
    if (startIndex >= _totalItems) {
      return []; // 没有更多数据
    }

    final endIndex = min(startIndex + pageSize, _totalItems);
    final count = endIndex - startIndex;

    // 生成模拟数据
    return List.generate(count, (index) {
      final itemIndex = startIndex + index;
      return PostItem(
        id: itemIndex + 1,
        title: _titles[itemIndex % _titles.length],
        subtitle: _subtitles[itemIndex % _subtitles.length],
        avatar:
            'https://api.dicebear.com/7.x/avataaars/svg?seed=user$itemIndex',
        createdAt: DateTime.now().subtract(Duration(hours: itemIndex * 3)),
        likes: _random.nextInt(999),
      );
    });
  }

  // 模拟标题集合
  static const _titles = [
    'Flutter 列表性能优化实战',
    '深入理解 ListView.builder',
    'Sliver 家族完全指南',
    '下拉刷新最佳实践',
    'ScrollController 高级用法',
    '分页加载设计模式',
    'Riverpod 状态管理进阶',
    'CustomScrollView 组合技巧',
    'AutomaticKeepAlive 原理解析',
    'Widget 复用与 const 优化',
    '高性能列表的 10 个小技巧',
    'SliverAppBar 动效实现',
    'InfiniteScroll 无限滚动方案',
    '列表项动画过渡效果',
    'RepaintBoundary 性能调优',
  ];

  // 模拟副标题集合
  static const _subtitles = [
    '掌握列表渲染的核心原理，告别卡顿',
    '按需构建 vs 一次性构建的性能差异',
    '学习 Sliver 协议，组合出任意滚动布局',
    'RefreshIndicator 与自定义刷新头',
    '监听滚动位置，实现各种交互效果',
    '前端通用的分页状态模型设计',
    'AsyncNotifier 管理异步分页数据',
    '多种 Sliver 组件的灵活组合',
    '保持列表项状态，避免切换 Tab 时重建',
    '减少不必要的 rebuild，提升帧率',
    '从真实项目中总结的优化经验',
    '可折叠头部 + 固定导航栏效果',
    '边滑边加载的流畅体验',
    '列表增删改时的平滑动画',
    '精确控制重绘区域，减少 GPU 开销',
  ];
}
