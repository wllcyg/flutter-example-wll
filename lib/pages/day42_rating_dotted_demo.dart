import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

/// Day 42: 评分与虚线边框示例
///
/// 功能：
/// 1. flutter_rating_bar - 星级评分组件（商品评价、用户反馈）
/// 2. 自定义图标 - 用 SVG/图片替代默认星星
/// 3. 半星支持 - allowHalfRating 精细化评分
/// 4. 只读模式 - 展示评分结果（不可交互）
/// 5. dotted_border - 虚线边框（文件上传区域、占位框）
/// 6. 自定义虚线样式 - 间距、圆角、颜色

// ==================== State Management ====================

/// 商品评分状态
final productRatingProvider = StateProvider<double>((ref) => 3.5);

/// 服务评分状态
final serviceRatingProvider = StateProvider<double>((ref) => 4.0);

/// 物流评分状态
final deliveryRatingProvider = StateProvider<double>((ref) => 4.5);

/// 用户评论状态
final userReviewProvider = StateProvider<String>((ref) => '');

/// 用户选择的图片列表
final selectedImagesProvider = StateProvider<List<XFile>>((ref) => []);

// ==================== Main Page ====================

class Day42RatingDottedDemo extends HookConsumerWidget {
  const Day42RatingDottedDemo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Day 42: 评分与虚线边框'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ==================== Rating Bar 示例 ====================
            _buildSectionTitle('1. 基础星级评分'),
            const SizedBox(height: 12),
            _buildBasicRating(ref),

            const SizedBox(height: 24),
            _buildSectionTitle('2. 半星评分（精细化）'),
            const SizedBox(height: 12),
            _buildHalfRating(ref),

            const SizedBox(height: 24),
            _buildSectionTitle('3. 自定义图标评分'),
            const SizedBox(height: 12),
            _buildCustomIconRating(),

            const SizedBox(height: 24),
            _buildSectionTitle('4. 只读模式（展示评分）'),
            const SizedBox(height: 12),
            _buildReadOnlyRating(),

            const SizedBox(height: 24),
            _buildSectionTitle('5. 不同尺寸与样式'),
            const SizedBox(height: 12),
            _buildDifferentSizes(),

            const SizedBox(height: 24),
            _buildSectionTitle('6. 虚线边框基础'),
            const SizedBox(height: 12),
            _buildBasicDottedBorder(),

            const SizedBox(height: 24),
            _buildSectionTitle('7. 文件上传区域'),
            const SizedBox(height: 12),
            _buildFileUploadArea(),

            const SizedBox(height: 24),
            _buildSectionTitle('8. 自定义虚线样式'),
            const SizedBox(height: 12),
            _buildCustomDottedStyles(),

            const SizedBox(height: 24),
            _buildSectionTitle('9. 实战：商品评价表单'),
            const SizedBox(height: 12),
            _buildProductReviewForm(context, ref),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ==================== Section Title Widget ====================

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  // ==================== 1. 基础星级评分 ====================

  Widget _buildBasicRating(WidgetRef ref) {
    final rating = ref.watch(productRatingProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '请为商品打分：',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Center(
              child: RatingBar.builder(
                initialRating: rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (newRating) {
                  ref.read(productRatingProvider.notifier).state = newRating;
                  Fluttertoast.showToast(
                    msg: '评分：$newRating 星',
                    gravity: ToastGravity.BOTTOM,
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                '当前评分：${rating.toStringAsFixed(1)} 星',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 2. 半星评分 ====================

  Widget _buildHalfRating(WidgetRef ref) {
    final rating = ref.watch(serviceRatingProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '服务评分（支持半星）：',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Center(
              child: RatingBar.builder(
                initialRating: rating,
                minRating: 0.5,
                direction: Axis.horizontal,
                allowHalfRating: true, // 允许半星
                itemCount: 5,
                itemSize: 40,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (newRating) {
                  ref.read(serviceRatingProvider.notifier).state = newRating;
                },
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                '当前评分：${rating.toStringAsFixed(1)} 星',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 3. 自定义图标评分 ====================

  Widget _buildCustomIconRating() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 爱心图标
            const Text(
              '❤️ 喜欢程度：',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            RatingBar.builder(
              initialRating: 3,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 35,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.favorite,
                color: Colors.red,
              ),
              onRatingUpdate: (rating) {
                Fluttertoast.showToast(msg: '❤️ $rating');
              },
            ),

            const SizedBox(height: 24),

            // 表情图标
            const Text(
              '😊 满意度：',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            RatingBar.builder(
              initialRating: 4,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemSize: 35,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, index) => Icon(
                _getEmotionIcon(index),
                color: _getEmotionColor(index),
              ),
              onRatingUpdate: (rating) {
                Fluttertoast.showToast(msg: '😊 $rating');
              },
            ),

            const SizedBox(height: 24),

            // 拇指图标
            const Text(
              '👍 推荐指数：',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            RatingBar.builder(
              initialRating: 3.5,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 35,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.thumb_up,
                color: Colors.blue,
              ),
              onRatingUpdate: (rating) {
                Fluttertoast.showToast(msg: '👍 $rating');
              },
            ),
          ],
        ),
      ),
    );
  }

  // 获取表情图标
  IconData _getEmotionIcon(int index) {
    switch (index) {
      case 0:
        return Icons.sentiment_very_dissatisfied;
      case 1:
        return Icons.sentiment_dissatisfied;
      case 2:
        return Icons.sentiment_neutral;
      case 3:
        return Icons.sentiment_satisfied;
      case 4:
        return Icons.sentiment_very_satisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }

  // 获取表情颜色
  Color _getEmotionColor(int index) {
    switch (index) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.lightGreen;
      case 4:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // ==================== 4. 只读模式 ====================

  Widget _buildReadOnlyRating() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '商品评分展示（只读）：',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),

            // 商品 1
            _buildReadOnlyItem('苹果 iPhone 15 Pro', 4.8, 2345),
            const Divider(),

            // 商品 2
            _buildReadOnlyItem('小米 14 Ultra', 4.5, 1876),
            const Divider(),

            // 商品 3
            _buildReadOnlyItem('华为 Mate 60 Pro', 4.9, 3421),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyItem(String name, double rating, int reviewCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    RatingBarIndicator(
                      rating: rating,
                      itemBuilder: (context, index) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      itemCount: 5,
                      itemSize: 18.0,
                      direction: Axis.horizontal,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '($reviewCount)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 5. 不同尺寸与样式 ====================

  Widget _buildDifferentSizes() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 小尺寸
            const Text('小尺寸（20px）:'),
            const SizedBox(height: 8),
            RatingBar.builder(
              initialRating: 3.5,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 20,
              itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {},
            ),

            const SizedBox(height: 16),

            // 中等尺寸
            const Text('中等尺寸（30px）:'),
            const SizedBox(height: 8),
            RatingBar.builder(
              initialRating: 4.0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 30,
              itemPadding: const EdgeInsets.symmetric(horizontal: 3.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {},
            ),

            const SizedBox(height: 16),

            // 大尺寸
            const Text('大尺寸（45px）:'),
            const SizedBox(height: 8),
            RatingBar.builder(
              initialRating: 4.5,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 45,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {},
            ),

            const SizedBox(height: 16),

            // 发光效果
            const Text('发光效果:'),
            const SizedBox(height: 8),
            RatingBar.builder(
              initialRating: 5.0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemSize: 35,
              glow: true,
              glowColor: Colors.amber,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {},
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 6. 虚线边框基础 ====================

  Widget _buildBasicDottedBorder() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 基础虚线框
            DottedBorder(
              color: Colors.blue,
              strokeWidth: 2,
              dashPattern: const [8, 4],
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: const Center(
                  child: Text(
                    '基础虚线边框',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 圆角虚线框
            DottedBorder(
              color: Colors.green,
              strokeWidth: 2,
              borderType: BorderType.RRect,
              radius: const Radius.circular(12),
              dashPattern: const [6, 3],
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: const Center(
                  child: Text(
                    '圆角虚线边框',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 圆形虚线框
            DottedBorder(
              color: Colors.orange,
              strokeWidth: 2,
              borderType: BorderType.Circle,
              dashPattern: const [10, 5],
              child: Container(
                width: 120,
                height: 120,
                child: const Center(
                  child: Text(
                    '圆形\n虚线框',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 7. 文件上传区域 ====================

  Widget _buildFileUploadArea() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 图片上传
            DottedBorder(
              color: Colors.grey[400]!,
              strokeWidth: 2,
              borderType: BorderType.RRect,
              radius: const Radius.circular(8),
              dashPattern: const [8, 4],
              child: InkWell(
                onTap: () {
                  Fluttertoast.showToast(msg: '选择图片');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 48,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '点击上传图片',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '支持 JPG、PNG 格式',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 文件拖放区域
            DottedBorder(
              color: Colors.blue[300]!,
              strokeWidth: 2,
              borderType: BorderType.RRect,
              radius: const Radius.circular(12),
              dashPattern: const [10, 5],
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.file_upload_outlined,
                      size: 40,
                      color: Colors.blue[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '拖放文件到此处',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '或点击选择文件',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 8. 自定义虚线样式 ====================

  Widget _buildCustomDottedStyles() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 不同间距
            const Text(
              '不同间距：',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            DottedBorder(
              color: Colors.purple,
              strokeWidth: 2,
              dashPattern: const [15, 5], // 长线段 短间隔
              borderType: BorderType.RRect,
              radius: const Radius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                child: const Text('[15, 5] - 长线段、短间隔'),
              ),
            ),

            const SizedBox(height: 12),

            DottedBorder(
              color: Colors.teal,
              strokeWidth: 2,
              dashPattern: const [5, 5], // 短线段 短间隔
              borderType: BorderType.RRect,
              radius: const Radius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                child: const Text('[5, 5] - 短线段、短间隔'),
              ),
            ),

            const SizedBox(height: 12),

            DottedBorder(
              color: Colors.indigo,
              strokeWidth: 2,
              dashPattern: const [3, 3], // 点状
              borderType: BorderType.RRect,
              radius: const Radius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                child: const Text('[3, 3] - 点状效果'),
              ),
            ),

            const SizedBox(height: 16),

            // 不同粗细
            const Text(
              '不同粗细：',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),

            DottedBorder(
              color: Colors.red,
              strokeWidth: 1,
              dashPattern: const [8, 4],
              borderType: BorderType.RRect,
              radius: const Radius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                child: const Text('strokeWidth: 1'),
              ),
            ),

            const SizedBox(height: 12),

            DottedBorder(
              color: Colors.red,
              strokeWidth: 3,
              dashPattern: const [8, 4],
              borderType: BorderType.RRect,
              radius: const Radius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                child: const Text('strokeWidth: 3'),
              ),
            ),

            const SizedBox(height: 12),

            DottedBorder(
              color: Colors.red,
              strokeWidth: 5,
              dashPattern: const [8, 4],
              borderType: BorderType.RRect,
              radius: const Radius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                child: const Text('strokeWidth: 5'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 9. 实战：商品评价表单 ====================

  Widget _buildProductReviewForm(BuildContext context, WidgetRef ref) {
    final productRating = ref.watch(productRatingProvider);
    final serviceRating = ref.watch(serviceRatingProvider);
    final deliveryRating = ref.watch(deliveryRatingProvider);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📝 商品评价',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // 商品质量评分
            const Text(
              '商品质量：',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                RatingBar.builder(
                  initialRating: productRating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 30,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    ref.read(productRatingProvider.notifier).state = rating;
                  },
                ),
                const SizedBox(width: 12),
                Text(
                  productRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 服务态度评分
            const Text(
              '服务态度：',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                RatingBar.builder(
                  initialRating: serviceRating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 30,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    ref.read(serviceRatingProvider.notifier).state = rating;
                  },
                ),
                const SizedBox(width: 12),
                Text(
                  serviceRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 物流速度评分
            const Text(
              '物流速度：',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                RatingBar.builder(
                  initialRating: deliveryRating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 30,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    ref.read(deliveryRatingProvider.notifier).state = rating;
                  },
                ),
                const SizedBox(width: 12),
                Text(
                  deliveryRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // 评价内容输入
            const Text(
              '评价内容：',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: '请描述您的购物体验...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: (value) {
                ref.read(userReviewProvider.notifier).state = value;
              },
            ),

            const SizedBox(height: 16),

            // 上传图片
            const Text(
              '上传图片：',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            _buildImagePickerArea(context, ref),

            const SizedBox(height: 24),

            // 提交按钮
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  _submitReview(context, ref);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '提交评价',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 图片选择区域 ====================

  Widget _buildImagePickerArea(BuildContext context, WidgetRef ref) {
    final images = ref.watch(selectedImagesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (images.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: images.length + (images.length < 9 ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == images.length) {
                  return _buildAddMoreButton(context, ref);
                }
                return _buildImageItem(ref, images, index);
              },
            ),
          ),
        if (images.isEmpty)
          DottedBorder(
            color: Colors.grey[400]!,
            strokeWidth: 2,
            borderType: BorderType.RRect,
            radius: const Radius.circular(8),
            dashPattern: const [8, 4],
            child: InkWell(
              onTap: () => _pickImages(context, ref),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '添加晒图（最多9张）',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // 更多添加按钮
  Widget _buildAddMoreButton(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => _pickImages(context, ref),
      child: DottedBorder(
        color: Colors.grey[400]!,
        strokeWidth: 1.5,
        borderType: BorderType.RRect,
        radius: const Radius.circular(8),
        dashPattern: const [4, 2],
        child: const Center(
          child: Icon(Icons.add, color: Colors.grey, size: 32),
        ),
      ),
    );
  }

  // 单个图片展示
  Widget _buildImageItem(WidgetRef ref, List<XFile> images, int index) {
    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(images[index].path),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () {
              final newImages = List<XFile>.from(images)..removeAt(index);
              ref.read(selectedImagesProvider.notifier).state = newImages;
            },
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 选择图片逻辑 - 直接调用 image_picker，由插件自己处理权限
  Future<void> _pickImages(BuildContext context, WidgetRef ref) async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> pickedImages = await picker.pickMultiImage(
        imageQuality: 70,
      );

      if (pickedImages.isNotEmpty) {
        final currentImages = ref.read(selectedImagesProvider);
        final List<XFile> result = [...currentImages, ...pickedImages];
        ref.read(selectedImagesProvider.notifier).state =
            result.take(9).toList();
      }
    } catch (e) {
      // 如果用户拒绝权限，引导去设置
      final errStr = e.toString();
      if (errStr.contains('photo_access_denied') ||
          errStr.contains('permission')) {
        _showPermissionDialog(context);
      } else {
        Fluttertoast.showToast(msg: '选择图片失败: $errStr');
      }
    }
  }

  // 引导跳转设置对话框
  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('需要相册权限'),
        content: const Text('您已禁用相册访问权限，请前往系统设置中开启，否则无法上传图片。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: const Text('去设置'),
          ),
        ],
      ),
    );
  }

  // ==================== 提交评价 ====================

  void _submitReview(BuildContext context, WidgetRef ref) {
    final productRating = ref.read(productRatingProvider);
    final serviceRating = ref.read(serviceRatingProvider);
    final deliveryRating = ref.read(deliveryRatingProvider);
    final review = ref.read(userReviewProvider);
    final images = ref.read(selectedImagesProvider);

    // 计算平均分
    final avgRating =
        (productRating + serviceRating + deliveryRating) / 3;

    // 显示提交结果
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('评价提交成功'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('商品质量：${productRating.toStringAsFixed(1)} 星'),
            Text('服务态度：${serviceRating.toStringAsFixed(1)} 星'),
            Text('物流速度：${deliveryRating.toStringAsFixed(1)} 星'),
            const SizedBox(height: 8),
            Text(
              '综合评分：${avgRating.toStringAsFixed(1)} 星',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            Text('上传图片：${images.length} 张'),
            if (review.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('评价内容：'),
              Text(
                review,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // 提交后重置状态
              ref.read(selectedImagesProvider.notifier).state = [];
              ref.read(userReviewProvider.notifier).state = '';
              Fluttertoast.showToast(
                msg: '感谢您的评价！',
                backgroundColor: Colors.green,
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
