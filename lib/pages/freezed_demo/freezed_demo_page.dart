import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_flutter_app/models/user_profile.dart';
import 'package:my_flutter_app/models/post_item_freezed.dart';

/// Day 31 Demo：freezed + json_serializable 代码生成演示
///
/// 演示要点：
/// 1. freezed 自动生成 copyWith / == / toString
/// 2. json_serializable 自动生成 toJson / fromJson
/// 3. Union Types (sealed class) 用于类型安全的状态管理
class FreezedDemoPage extends StatefulWidget {
  const FreezedDemoPage({super.key});

  @override
  State<FreezedDemoPage> createState() => _FreezedDemoPageState();
}

class _FreezedDemoPageState extends State<FreezedDemoPage> {
  // 模拟一个 UserProfile 实例
  UserProfile _user = const UserProfile(
    id: 'user_001',
    nickname: '前端转 Flutter 的墨酱',
    avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=demo',
    bio: '正在学习 freezed，感觉代码量少了一半！',
    followersCount: 128,
    followingCount: 42,
  );

  // 模拟 DataResult 状态切换
  DataResult<List<PostItemFreezed>> _postsResult =
      const DataResult.loading();

  @override
  void initState() {
    super.initState();
    // 模拟 2 秒后加载完成
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _postsResult = DataResult.success([
            PostItemFreezed(
              id: 1,
              title: 'freezed 真香指南',
              subtitle: '自动 copyWith、自动 == 比较',
              createdAt: DateTime.now(),
              likes: 666,
            ),
            const PostItemFreezed(
              id: 2,
              title: 'json_serializable 实战',
              subtitle: '告别手写 fromJson/toJson',
              likes: 233,
            ),
            const PostItemFreezed(
              id: 3,
              title: 'Union Types 的妙用',
              subtitle: 'Loading / Success / Error 类型安全',
              likes: 999,
            ),
          ]);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Day 31: Freezed 代码生成')),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // Section 1: UserProfile 展示
          _buildSectionTitle('1. Freezed Model 演示', isDark),
          _buildUserCard(isDark),
          SizedBox(height: 12.h),

          // copyWith 演示按钮
          _buildActionButton(
            '调用 copyWith 修改昵称',
            Icons.edit,
            () {
              setState(() {
                _user = _user.copyWith(
                  nickname: '墨酱 v${DateTime.now().second}',
                  followersCount: _user.followersCount + 1,
                );
              });
            },
          ),
          SizedBox(height: 8.h),

          // toJson 演示按钮
          _buildActionButton(
            '查看 toJson() 输出',
            Icons.code,
            () => _showJsonDialog(_user.toJson().toString()),
          ),
          SizedBox(height: 8.h),

          // fromJson 演示按钮
          _buildActionButton(
            '模拟 fromJson() 解析',
            Icons.download,
            () {
              final json = {
                'id': 'user_from_api',
                'nickname': '从 API 解析的用户',
                'avatar_url': 'https://example.com/avatar.png',
                'bio': '这个对象是通过 fromJson 创建的！',
                'followers_count': 9999,
                'following_count': 1,
              };
              setState(() {
                _user = UserProfile.fromJson(json);
              });
            },
          ),
          SizedBox(height: 8.h),

          // == 比较演示
          _buildActionButton(
            '测试 == 值相等比较',
            Icons.compare_arrows,
            () {
              const a = UserProfile(id: '1', nickname: 'test');
              const b = UserProfile(id: '1', nickname: 'test');
              final c = a.copyWith(nickname: 'different');
              _showJsonDialog(
                'a == b: ${a == b}\n'
                'a == c: ${a == c}\n\n'
                '手写 class 默认比较引用地址，freezed 自动按值比较！',
              );
            },
          ),

          SizedBox(height: 24.h),

          // Section 2: Union Types 演示
          _buildSectionTitle('2. Union Types 状态管理', isDark),
          SizedBox(height: 8.h),
          _buildUnionTypeDemo(isDark),

          SizedBox(height: 16.h),
          // 切换状态按钮
          Row(
            children: [
              Expanded(
                child: _buildSmallButton('Loading', () {
                  setState(() {
                    _postsResult = const DataResult.loading();
                  });
                  Future.delayed(const Duration(seconds: 1), () {
                    if (mounted) {
                      setState(() {
                        _postsResult = const DataResult.success([]);
                      });
                    }
                  });
                }),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildSmallButton('Error', () {
                  setState(() {
                    _postsResult =
                        const DataResult.error('模拟网络超时: 408 Timeout');
                  });
                }),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildSmallButton('Success', () {
                  setState(() {
                    _postsResult = DataResult.success([
                      PostItemFreezed(
                        id: 1,
                        title: '刷新后的数据',
                        subtitle: '${DateTime.now()}',
                        likes: 42,
                      ),
                    ]);
                  });
                }),
              ),
            ],
          ),

          SizedBox(height: 24.h),
          // Section 3: 对比
          _buildSectionTitle('3. 手写 vs Freezed 对比', isDark),
          SizedBox(height: 8.h),
          _buildComparisonCard(isDark),
        ],
      ),
    );
  }

  // ---------- UI 组件 ----------

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildUserCard(bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24.r,
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  _user.nickname.isNotEmpty ? _user.nickname[0] : '?',
                  style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _user.nickname,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      'ID: ${_user.id}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            _user.bio,
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildStatItem('粉丝', _user.followersCount),
              SizedBox(width: 24.w),
              _buildStatItem('关注', _user.followingCount),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
      ],
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20.w),
        label: Text(title),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),
    );
  }

  Widget _buildSmallButton(String label, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
      child: Text(label, style: TextStyle(fontSize: 13.sp)),
    );
  }

  Widget _buildUnionTypeDemo(bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: switch (_postsResult) {
        DataLoading() => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('加载中... (DataResult.loading)'),
                ],
              ),
            ),
          ),
        DataSuccess(:final data) => data.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('暂无数据 (DataResult.success but empty)'),
                ),
              )
            : Column(
                children: data
                    .map((post) => ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: Text('${post.id}'),
                          ),
                          title: Text(
                            post.title,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          subtitle: Text(post.subtitle),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.favorite,
                                  size: 16, color: Colors.red.shade300),
                              const SizedBox(width: 4),
                              Text('${post.likes}'),
                            ],
                          ),
                        ))
                    .toList(),
              ),
        DataError(:final message) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
      },
    );
  }

  Widget _buildComparisonCard(bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '❌ 手写 class（约 50 行/Model）',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade400,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '• 手写 constructor\n'
            '• 手写 copyWith()\n'
            '• 手写 toJson() / fromJson()\n'
            '• 手写 == 和 hashCode\n'
            '• 手写 toString()',
            style: TextStyle(fontSize: 13.sp, color: isDark ? Colors.grey.shade300 : Colors.black54),
          ),
          Divider(height: 24.h),
          Text(
            '✅ freezed（约 15 行/Model）',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade400,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '• 写一个 @freezed class 定义字段\n'
            '• 全部自动生成 ✨\n'
            '• 还额外赠送 Union Types！\n'
            '• 代码量减少 70%+',
            style: TextStyle(fontSize: 13.sp, color: isDark ? Colors.grey.shade300 : Colors.black54),
          ),
        ],
      ),
    );
  }

  void _showJsonDialog(String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('输出结果'),
        content: SingleChildScrollView(
          child: SelectableText(
            content,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
