// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paged_posts_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pagedPostsHash() => r'f3c891c4d87d6555036d4779f4b75caa247793f6';

/// 分页帖子列表 Provider
///
/// 使用 Riverpod 的 AsyncNotifier 管理分页状态：
/// - build() — 初始化加载第一页
/// - refresh() — 下拉刷新，重置到第一页
/// - loadMore() — 上拉加载下一页，追加数据
///
/// 对标前端的 useInfiniteQuery (React Query) 或 Pinia 分页 action
///
/// Copied from [PagedPosts].
@ProviderFor(PagedPosts)
final pagedPostsProvider =
    AutoDisposeAsyncNotifierProvider<PagedPosts, PagedState<PostItem>>.internal(
  PagedPosts.new,
  name: r'pagedPostsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$pagedPostsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PagedPosts = AutoDisposeAsyncNotifier<PagedState<PostItem>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
