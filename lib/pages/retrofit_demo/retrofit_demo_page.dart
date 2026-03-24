import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dio/dio.dart';
import 'package:my_flutter_app/net/api_service.dart';
import 'package:my_flutter_app/models/post_item_freezed.dart';

/// Day 32 Demo：Retrofit 声明式网络请求演示
///
/// 使用 JSONPlaceholder (免费公开 API) 作为演示后端
/// 演示要点：
/// 1. GET 请求列表 / 单条
/// 2. POST 创建数据
/// 3. 分页查询
class RetrofitDemoPage extends StatefulWidget {
  const RetrofitDemoPage({super.key});

  @override
  State<RetrofitDemoPage> createState() => _RetrofitDemoPageState();
}

class _RetrofitDemoPageState extends State<RetrofitDemoPage> {
  late final ApiService _apiService;
  List<PostItemFreezed> _posts = [];
  bool _isLoading = false;
  String _log = '等待操作...\n';
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    // 创建 Dio 实例，配置 baseUrl 为 JSONPlaceholder
    final dio = Dio(BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
    // 用 Dio 实例创建 Retrofit Service
    _apiService = ApiService(dio);
  }

  void _appendLog(String msg) {
    setState(() {
      _log += '${DateTime.now().toString().substring(11, 19)} $msg\n';
    });
  }

  // GET 列表
  Future<void> _fetchPosts() async {
    setState(() => _isLoading = true);
    _appendLog('📡 GET /posts?_page=$_currentPage&_limit=5');
    try {
      final posts = await _apiService.getPostsPaged(_currentPage, 5);
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
      _appendLog('✅ 成功获取 ${posts.length} 条数据');
    } catch (e) {
      setState(() => _isLoading = false);
      _appendLog('❌ 请求失败: $e');
    }
  }

  // GET 单条
  Future<void> _fetchSinglePost(int id) async {
    _appendLog('📡 GET /posts/$id');
    try {
      final post = await _apiService.getPostById(id);
      _appendLog('✅ 获取成功: "${post.title}"');
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('帖子 #${post.id}'),
            content: Text(post.title),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('关闭'),
              )
            ],
          ),
        );
      }
    } catch (e) {
      _appendLog('❌ 请求失败: $e');
    }
  }

  // POST 创建
  Future<void> _createPost() async {
    _appendLog('📡 POST /posts');
    try {
      final newPost = await _apiService.createPost({
        'title': 'Retrofit 创建的帖子 🚀',
        'subtitle': '由 Day 32 Demo 创建于 ${DateTime.now()}',
        'likes': 0,
      });
      _appendLog('✅ 创建成功! 新帖子 ID: ${newPost.id}');
    } catch (e) {
      _appendLog('❌ 创建失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Day 32: Retrofit API')),
      body: Column(
        children: [
          // 操作按钮区域
          Container(
            padding: EdgeInsets.all(12.w),
            color: isDark ? Colors.grey.shade900 : Colors.blue.shade50,
            child: Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                _buildChipButton('📥 获取列表', _fetchPosts),
                _buildChipButton('📄 查看 #1', () => _fetchSinglePost(1)),
                _buildChipButton('➕ POST 创建', _createPost),
                _buildChipButton('⬅️ 上一页', () {
                  if (_currentPage > 1) {
                    _currentPage--;
                    _fetchPosts();
                  }
                }),
                _buildChipButton('➡️ 下一页', () {
                  _currentPage++;
                  _fetchPosts();
                }),
              ],
            ),
          ),

          // 数据列表
          Expanded(
            flex: 3,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _posts.isEmpty
                    ? Center(
                        child: Text(
                          '点击上方按钮发起请求',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14.sp,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.all(12.w),
                        itemCount: _posts.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final post = _posts[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: Text(
                                '${post.id}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            title: Text(
                              post.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            subtitle: Text(
                              '点赞: ${post.likes}',
                              style: TextStyle(fontSize: 12.sp),
                            ),
                            onTap: () => _fetchSinglePost(post.id),
                          );
                        },
                      ),
          ),

          // 日志面板
          Container(
            height: 180.h,
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: isDark ? Colors.black87 : const Color(0xFF1E1E1E),
              border: Border(
                top: BorderSide(color: Colors.blue.shade300, width: 2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '📋 请求日志 (Page: $_currentPage)',
                      style: TextStyle(
                        color: Colors.green.shade300,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _log = ''),
                      child: Text(
                        '清空',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Expanded(
                  child: SingleChildScrollView(
                    reverse: true,
                    child: SelectableText(
                      _log,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: Colors.grey.shade300,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipButton(String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(label, style: TextStyle(fontSize: 13.sp)),
      onPressed: onTap,
    );
  }
}
