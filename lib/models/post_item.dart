/// Demo 用的帖子数据模型
///
/// 用于 Day 19 列表性能优化演示，模拟真实的列表数据。
class PostItem {
  final int id;
  final String title;
  final String subtitle;
  final String avatar;
  final DateTime createdAt;
  final int likes;

  const PostItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.avatar,
    required this.createdAt,
    this.likes = 0,
  });

  @override
  String toString() => 'PostItem(id: $id, title: $title)';
}
