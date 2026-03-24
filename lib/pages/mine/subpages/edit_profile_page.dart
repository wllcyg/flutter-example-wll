import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:my_flutter_app/res/colors.dart';
import 'package:my_flutter_app/view_models/auth_view_model.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _nameController = TextEditingController();
  final _picker = ImagePicker();
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authViewModelProvider).user;
    if (user != null) {
      final name = user.userMetadata?['full_name'] as String? ??
          user.email?.split('@')[0] ??
          '';
      _nameController.text = name;
      _avatarUrl = user.userMetadata?['avatar_url'] as String?;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      SmartDialog.showLoading(msg: "上传头像中...");

      final file = File(image.path);
      final fileExt = image.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      // upload to 'diary_covers' bucket (as we know it exists) under 'avatars' folder
      final filePath = 'avatars/$fileName';

      await Supabase.instance.client.storage
          .from('diary_covers')
          .upload(filePath, file);

      final String publicUrl = Supabase.instance.client.storage
          .from('diary_covers')
          .getPublicUrl(filePath);

      setState(() {
        _avatarUrl = publicUrl;
      });

      SmartDialog.showToast("头像上传成功");
    } catch (e) {
      SmartDialog.showToast("上传失败: $e");
    } finally {
      SmartDialog.dismiss();
    }
  }

  Future<void> _saveProfile() async {
    SmartDialog.showLoading(msg: "保存中...");
    try {
      final user = ref.read(authViewModelProvider).user;
      if (user == null) return;

      final updates = UserAttributes(
        data: {
          'full_name': _nameController.text,
          if (_avatarUrl != null) 'avatar_url': _avatarUrl,
        },
      );

      await Supabase.instance.client.auth.updateUser(updates);

      // Refresh user data
      await ref.read(authViewModelProvider.notifier).refreshUser();

      SmartDialog.showToast("保存成功");
      if (mounted) context.pop();
    } catch (e) {
      SmartDialog.showToast("保存失败: $e");
    } finally {
      SmartDialog.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("编辑资料"),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: Text("保存",
                style: TextStyle(color: AppColors.primary, fontSize: 16.sp)),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // Avatar Placeholder
            Center(
              child: GestureDetector(
                onTap: _pickAndUploadAvatar,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50.w,
                      backgroundColor: Colors.grey[200],
                      backgroundImage:
                          _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
                      child: _avatarUrl == null
                          ? Icon(Icons.person, size: 60.w, color: Colors.grey)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.camera_alt,
                            color: Colors.white, size: 20.w),
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 30.h),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "昵称",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
