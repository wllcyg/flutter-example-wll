import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

/// Day 40: 瀑布流布局 - 小红书风格
class Day40StaggeredGridDemo extends HookWidget {
  const Day40StaggeredGridDemo({super.key});

  @override
  Widget build(BuildContext context) {
    // 模拟小红书内容数据
    final items = useState<List<FeedItem>>(_generateMockData());
    final isLoading = useState(false);
    final layoutMode = useState<LayoutMode>(LayoutMode.masonry);

    // 模拟下拉刷新
    Future<void> onRefresh() async {
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1));
      items.value = _generateMockData();
      isLoading.value = false;
    }

    // 模拟加载更多
    final scrollController = useScrollController();
    useEffect(() {
      void onScroll() {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          if (!isLoading.value) {
            isLoading.value = true;
            Future.delayed(const Duration(seconds: 1), () {
              items.value = [...items.value, ..._generateMockData(offset: items.value.length)];
              isLoading.value = false;
            });
          }
        }
      }

      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, [scrollController]);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Day 40: 瀑布流布局'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // 布局切换按钮
          PopupMenuButton<LayoutMode>(
            icon: const Icon(Icons.view_module),
            onSelected: (mode) => layoutMode.value = mode,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: LayoutMode.masonry,
                child: Text('瀑布流 (Masonry)'),
              ),
              const PopupMenuItem(
                value: LayoutMode.staggered,
                child: Text('交错网格 (Staggered)'),
              ),
              const PopupMenuItem(
                value: LayoutMode.quilted,
                child: Text('拼接网格 (Quilted)'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 功能说明
          _buildHeader(layoutMode.value),
          
          // 瀑布流内容
          Expanded(
            child: RefreshIndicator(
              onRefresh: onRefresh,
              child: _buildGridView(
                layoutMode.value,
                items.value,
                scrollController,
              ),
            ),
          ),
          
          // 加载指示器
          if (isLoading.value)
            Container(
              padding: const EdgeInsets.all(16),
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(LayoutMode mode) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'flutter_staggered_grid_view 核心功能',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '当前模式: ${mode.displayName}',
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            mode.description,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(
    LayoutMode mode,
    List<FeedItem> items,
    ScrollController controller,
  ) {
    switch (mode) {
      case LayoutMode.masonry:
        // 瀑布流布局 - 小红书风格
        return MasonryGridView.count(
          controller: controller,
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          padding: const EdgeInsets.all(8),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return _FeedCard(item: items[index]);
          },
        );

      case LayoutMode.staggered:
        // 交错网格布局 - 使用 StaggeredGrid
        return StaggeredGrid.count(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: items.map((item) => _FeedCard(item: item)).toList(),
        );

      case LayoutMode.quilted:
        // 拼接网格布局 - 不规则大小
        return StaggeredGrid.count(
          crossAxisCount: 4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: List.generate(items.length, (index) {
            // 循环使用不同的 tile 大小
            final patterns = [
              (crossAxis: 2, mainAxis: 2), // 大图
              (crossAxis: 1, mainAxis: 1), // 小图
              (crossAxis: 1, mainAxis: 1), // 小图
              (crossAxis: 2, mainAxis: 1), // 横图
            ];
            final pattern = patterns[index % patterns.length];
            
            return StaggeredGridTile.count(
              crossAxisCellCount: pattern.crossAxis,
              mainAxisCellCount: pattern.mainAxis,
              child: _FeedCard(item: items[index]),
            );
          }),
        );
    }
  }

  // 生成模拟数据
  static List<FeedItem> _generateMockData({int offset = 0}) {
    final List<FeedItem> mockItems = [];
    
    // 使用 picsum.photos 稳定的图片源
    for (int i = 0; i < 20; i++) {
      final index = offset + i;
      final imageId = 100 + index; // picsum 图片 ID
      final height = 300 + (index % 5) * 80; // 动态高度：300, 380, 460, 540, 620
      
      mockItems.add(FeedItem(
        id: index,
        imageUrl: 'https://picsum.photos/id/$imageId/400/$height',
        title: _getTitles()[index % _getTitles().length],
        author: '用户${1000 + index}',
        avatar: 'https://i.pravatar.cc/150?img=${(index % 70) + 1}',
        likes: 100 + index * 10,
      ));
    }
    
    return mockItems;
  }

  static List<String> _getTitles() {
    return [
      '今日份的美好分享 ✨',
      '这个地方太美了！必须打卡',
      '超好吃的美食推荐 🍜',
      '穿搭灵感｜简约风格',
      '旅行 Vlog｜说走就走',
      '艺术展览｜周末好去处',
      '咖啡店探店｜氛围感拉满',
      '读书笔记｜最近在看的书',
      '健身日常｜坚持打卡',
      '摄影技巧｜手机也能拍大片',
    ];
  }
}

/// 小红书风格卡片
class _FeedCard extends HookWidget {
  final FeedItem item;

  const _FeedCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isLiked = useState(false);
    
    // 从 URL 中提取图片尺寸，计算宽高比
    final imageAspectRatio = _getImageAspectRatio(item.imageUrl);

    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('查看详情: ${item.title}'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片区域 - 关键：使用正确的宽高比避免抖动
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: AspectRatio(
                aspectRatio: imageAspectRatio,
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported, size: 40),
                  ),
                ),
              ),
            ),
            
            // 内容区域
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // 作者信息
                  Row(
                    children: [
                      // 头像
                      CircleAvatar(
                        radius: 12,
                        backgroundImage: CachedNetworkImageProvider(item.avatar),
                      ),
                      const SizedBox(width: 6),
                      
                      // 用户名
                      Expanded(
                        child: Text(
                          item.author,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      // 点赞按钮
                      GestureDetector(
                        onTap: () => isLiked.value = !isLiked.value,
                        child: Icon(
                          isLiked.value ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: isLiked.value ? Colors.red : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatLikes(item.likes + (isLiked.value ? 1 : 0)),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 从 URL 中解析图片宽高比，避免加载后抖动
  double _getImageAspectRatio(String url) {
    // URL 格式: https://picsum.photos/id/100/400/300
    final regex = RegExp(r'/(\d+)/(\d+)$');
    final match = regex.firstMatch(url);
    
    if (match != null) {
      final width = double.parse(match.group(1)!);
      final height = double.parse(match.group(2)!);
      return width / height;
    }
    
    // 默认宽高比
    return 1.0;
  }

  String _formatLikes(int likes) {
    if (likes >= 10000) {
      return '${(likes / 10000).toStringAsFixed(1)}w';
    } else if (likes >= 1000) {
      return '${(likes / 1000).toStringAsFixed(1)}k';
    }
    return likes.toString();
  }
}

/// 内容数据模型
class FeedItem {
  final int id;
  final String imageUrl;
  final String title;
  final String author;
  final String avatar;
  final int likes;

  FeedItem({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.author,
    required this.avatar,
    required this.likes,
  });
}

/// 布局模式
enum LayoutMode {
  masonry('瀑布流', '根据内容高度自动排列，Pinterest 风格'),
  staggered('交错网格', '固定列数，内容自适应高度'),
  quilted('拼接网格', '不规则大小组合，杂志风格');

  final String displayName;
  final String description;

  const LayoutMode(this.displayName, this.description);
}
