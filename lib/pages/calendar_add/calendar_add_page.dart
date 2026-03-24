import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:my_flutter_app/res/styles.dart';
import 'package:my_flutter_app/res/colors.dart';
import 'package:my_flutter_app/models/mood.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:my_flutter_app/pages/calendar_add/widgets/attachment_button.dart';
import 'package:my_flutter_app/providers/diary_provider.dart';

import 'package:my_flutter_app/models/diary_entry.dart';

class CalendarAddPage extends ConsumerStatefulWidget {
  final DiaryEntry? entry;
  const CalendarAddPage({super.key, this.entry});

  @override
  ConsumerState<CalendarAddPage> createState() => _CalendarAddPageState();
}

class _CalendarAddPageState extends ConsumerState<CalendarAddPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  Mood? _selectedMood;
  File? _coverImage;
  String? _existingCoverUrl; // To store existing URL when editing
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  final List<Mood> _moods = [
    const Mood('开心', '😊', Color(0xFFFFC107)),
    const Mood('难过', '😔', Color(0xFF607D8B)),
    const Mood('生气', '😡', Color(0xFFF44336)),
    const Mood('惊讶', '😮', Color(0xFF9C27B0)),
    const Mood('疲惫', '😴', Color(0xFF795548)),
    const Mood('平静', '😌', Color(0xFF4CAF50)),
    const Mood('生病', '😷', Color(0xFFE91E63)),
    const Mood('期待', '🤩', Color(0xFFFF9800)),
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry?.title ?? '');
    _contentController =
        TextEditingController(text: widget.entry?.content ?? '');

    if (widget.entry != null) {
      // Pre-fill Mood
      if (widget.entry!.moodLabel != null) {
        try {
          _selectedMood = _moods.firstWhere(
            (m) => m.label == widget.entry!.moodLabel,
          );
        } catch (_) {
          // If mood not found in predefined list, maybe create a temp one or ignore
        }
      }
      // Pre-fill Cover URL
      _existingCoverUrl = widget.entry!.coverUrl;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _pickCoverImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _coverImage = File(image.path);
        // If user picks a new image, we should probably ignore the existing URL for display
        // But we keep _existingCoverUrl until save, to know if we need to replace or what.
        // Actually, logic: if _coverImage != null, use it. Else if _existingCoverUrl != null, use it.
      });
    }
  }

  Future<void> _saveDiary() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      SmartDialog.showToast('请输入正文内容');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('用户未登录');
      }

      // Use existing URL if no new image selected
      String? coverUrl = _existingCoverUrl;

      // If new local image selected, upload it
      if (_coverImage != null) {
        final extension =
            _coverImage!.path.substring(_coverImage!.path.lastIndexOf('.'));
        final fileName = '${DateTime.now().millisecondsSinceEpoch}$extension';
        final filePath = '${user.id}/$fileName';

        await Supabase.instance.client.storage
            .from('diary_covers')
            .uploadBinary(filePath, await _coverImage!.readAsBytes());

        coverUrl = Supabase.instance.client.storage
            .from('diary_covers')
            .getPublicUrl(filePath);
      }

      final data = {
        'user_id': user.id,
        'title': _titleController.text.trim(),
        'content': content,
        'mood_label': _selectedMood?.label,
        'mood_emoji': _selectedMood?.emoji,
        'cover_url': coverUrl,
        if (widget.entry == null)
          'created_at': DateTime.now().toIso8601String(),
        'updated_at':
            DateTime.now().toIso8601String(), // Always update updated_at
      };

      if (widget.entry != null) {
        // Update
        await Supabase.instance.client
            .from('diary_entries')
            .update(data)
            .eq('id', widget.entry!.id);
      } else {
        // Insert
        await Supabase.instance.client.from('diary_entries').insert(data);
      }

      ref.invalidate(diaryListProvider);
      if (mounted) {
        SmartDialog.showToast('保存成功');
        context.pop();
      }
    } catch (e) {
      debugPrint('Save error: $e');
      if (mounted) {
        SmartDialog.showToast('保存失败: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMoodSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '选择心情',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 20.h),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 16.h,
                  crossAxisSpacing: 16.w,
                  childAspectRatio: 1,
                ),
                itemCount: _moods.length,
                itemBuilder: (context, index) {
                  final mood = _moods[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMood = mood;
                      });
                      context.pop();
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          mood.emoji,
                          style: TextStyle(fontSize: 32.sp),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          mood.label,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('zh_CN', null);
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy年MM月dd日 EEEE', 'zh_CN').format(now);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        elevation: 0,
        title: Text(
          dateStr,
          style: AppStyles.text18.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: isDark ? Colors.white : Colors.black, size: 20.w),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.h),
            // 标题区域
            Text('标题（可选）',
                style: TextStyle(
                    fontSize: 14.sp,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary)),
            SizedBox(height: 10.h),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: '标题（可选）',
                filled: true,
                fillColor: isDark
                    ? AppColors.inputBackgroundDark
                    : AppColors.inputBackground,
                border: InputBorder.none,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                hintStyle: TextStyle(
                    color: AppColors.textPlaceholder, fontSize: 16.sp),
              ),
              style: TextStyle(
                  fontSize: 16.sp,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary),
            ),
            SizedBox(height: 20.h),

            // 正文区域
            Text('正文',
                style: TextStyle(
                    fontSize: 14.sp,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary)),
            SizedBox(height: 10.h),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.inputBackgroundDark
                      : AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 12.h),
                child: TextField(
                  controller: _contentController,
                  focusNode: _focusNode,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: '今天发生了什么？',
                    filled: true,
                    fillColor: Colors.transparent,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isCollapsed: true,
                    hintStyle: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.textPlaceholder,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // 附件功能区 - 始终可见
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                AttachmentButton(
                  icon: Icons.image,
                  label: '添加封面',
                  color: AppColors.primary,
                  onTap: _pickCoverImage,
                  customIcon: _coverImage != null
                      ? ClipOval(
                          child: Image.file(
                            _coverImage!,
                            width: 24.w,
                            height: 24.w,
                            fit: BoxFit.cover,
                          ),
                        )
                      : (_existingCoverUrl != null
                          ? ClipOval(
                              child: Image.network(
                                _existingCoverUrl!,
                                width: 24.w,
                                height: 24.w,
                                fit: BoxFit.cover,
                              ),
                            )
                          : null),
                  onClear: (_coverImage != null || _existingCoverUrl != null)
                      ? () => setState(() {
                            _coverImage = null;
                            _existingCoverUrl = null;
                          })
                      : null,
                ),
                SizedBox(width: 8.w),
                AttachmentButton(
                  icon: Icons.sentiment_satisfied_alt,
                  label: _selectedMood?.label ?? '心情标签',
                  color: AppColors.primary,
                  onTap: _showMoodSelector,
                  customIcon: _selectedMood != null
                      ? Text(
                          _selectedMood!.emoji,
                          style: TextStyle(fontSize: 24.sp),
                        )
                      : null,
                  onClear: _selectedMood != null
                      ? () => setState(() => _selectedMood = null)
                      : null,
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // 底部按钮
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextButton(
                    onPressed: () => context.pop(),
                    style: TextButton.styleFrom(
                      backgroundColor: isDark
                          ? AppColors.inputBackgroundDark
                          : AppColors.inputBackground,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text('取消',
                        style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  flex: 2,
                  child: TextButton(
                    onPressed: _isLoading ? null : _saveDiary,
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 24.w,
                            height: 24.w,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text('保存',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}
