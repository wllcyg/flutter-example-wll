import 'package:dio/dio.dart';
import 'package:my_flutter_app/models/post_item_freezed.dart';

/// Day 32 示例：Dio 封装声明式 API 接口
/// 移除 retrofit 依赖，改用 dio 直接封装，功能完全等价
class ApiService {
  final Dio _dio;

  ApiService(Dio dio) : _dio = dio;

  /// 获取帖子列表（GET /posts）
  Future<List<PostItemFreezed>> getPosts() async {
    final res = await _dio.get('/posts');
    return (res.data as List).map((e) => PostItemFreezed.fromJson(e)).toList();
  }

  /// 获取单个帖子（GET /posts/{id}）
  Future<PostItemFreezed> getPostById(int id) async {
    final res = await _dio.get('/posts/$id');
    return PostItemFreezed.fromJson(res.data);
  }

  /// 创建帖子（POST /posts）
  Future<PostItemFreezed> createPost(Map<String, dynamic> body) async {
    final res = await _dio.post('/posts', data: body);
    return PostItemFreezed.fromJson(res.data);
  }

  /// 更新帖子（PUT /posts/{id}）
  Future<PostItemFreezed> updatePost(int id, Map<String, dynamic> body) async {
    final res = await _dio.put('/posts/$id', data: body);
    return PostItemFreezed.fromJson(res.data);
  }

  /// 删除帖子（DELETE /posts/{id}）
  Future<void> deletePost(int id) async {
    await _dio.delete('/posts/$id');
  }

  /// 分页查询（GET /posts?_page=1&_limit=10）
  Future<List<PostItemFreezed>> getPostsPaged(int page, int limit) async {
    final res = await _dio.get('/posts', queryParameters: {
      '_page': page,
      '_limit': limit,
    });
    return (res.data as List).map((e) => PostItemFreezed.fromJson(e)).toList();
  }
}
