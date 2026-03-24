/// 通用分页数据模型
///
/// 类似前端的分页状态管理，封装了分页场景所需的全部状态：
/// - [items]：当前已加载的所有数据
/// - [page]：当前页码（从 1 开始）
/// - [hasMore]：是否还有更多数据可加载
/// - [isLoadingMore]：是否正在加载下一页（用于 UI 显示底部 loading）
class PagedState<T> {
  final List<T> items;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;

  const PagedState({
    required this.items,
    required this.page,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  /// 初始状态工厂方法
  factory PagedState.initial() {
    return const PagedState(
      items: [],
      page: 0,
      hasMore: true,
      isLoadingMore: false,
    );
  }

  /// 不可变更新：使用 copyWith 模式
  PagedState<T> copyWith({
    List<T>? items,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return PagedState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  String toString() =>
      'PagedState(page: $page, items: ${items.length}, hasMore: $hasMore, isLoadingMore: $isLoadingMore)';
}
