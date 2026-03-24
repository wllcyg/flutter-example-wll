import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:my_flutter_app/models/paged_state.dart';
import 'package:my_flutter_app/models/post_item.dart';
import 'package:my_flutter_app/repositories/fake_post_repository.dart';

part 'paged_posts_provider.g.dart';

/// 分页帖子列表 Provider
///
/// 使用 Riverpod 的 AsyncNotifier 管理分页状态：
/// - build() — 初始化加载第一页
/// - refresh() — 下拉刷新，重置到第一页
/// - loadMore() — 上拉加载下一页，追加数据
///
/// 对标前端的 useInfiniteQuery (React Query) 或 Pinia 分页 action
@riverpod
class PagedPosts extends _$PagedPosts {
  final _repository = FakePostRepository();
  static const _pageSize = 20;

  @override
  Future<PagedState<PostItem>> build() async {
    // 初始化：加载第一页
    final items = await _repository.fetchPosts(page: 1, pageSize: _pageSize);
    return PagedState(
      items: items,
      page: 1,
      hasMore: items.length >= _pageSize,
    );
  }

  /// 下拉刷新：重置到第一页
  Future<void> refresh() async {
    // 重新加载第一页
    final items = await _repository.fetchPosts(page: 1, pageSize: _pageSize);
    state = AsyncData(PagedState(
      items: items,
      page: 1,
      hasMore: items.length >= _pageSize,
    ));
  }

  /// 上拉加载更多：追加下一页数据
  Future<void> loadMore() async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    // 防止重复加载或已无更多数据
    if (currentState.isLoadingMore || !currentState.hasMore) return;

    // 标记正在加载（UI 层据此显示底部 loading）
    state = AsyncData(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = currentState.page + 1;
      final newItems = await _repository.fetchPosts(
        page: nextPage,
        pageSize: _pageSize,
      );

      state = AsyncData(currentState.copyWith(
        items: [...currentState.items, ...newItems],
        page: nextPage,
        hasMore: newItems.length >= _pageSize,
        isLoadingMore: false,
      ));
    } catch (e) {
      // 加载失败：恢复非加载状态，保留已有数据
      state = AsyncData(currentState.copyWith(isLoadingMore: false));
    }
  }
}
