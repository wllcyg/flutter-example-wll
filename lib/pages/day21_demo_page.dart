import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class Day21ImageProcessingPage extends StatefulWidget {
  const Day21ImageProcessingPage({super.key});

  @override
  State<Day21ImageProcessingPage> createState() =>
      _Day21ImageProcessingPageState();
}

class _Day21ImageProcessingPageState extends State<Day21ImageProcessingPage> {
  File? _imageFile;
  bool _isProcessing = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _processImage(ImageSource source) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // 1. Pick Image
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) return;

      // 2. Crop Image
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: '裁剪图片',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: '裁剪图片',
            resetButtonHidden: true,
          ),
        ],
      );

      if (croppedFile == null) return;

      // 3. Compress Image
      final tempDir = await getTemporaryDirectory();
      final targetPath =
          '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final XFile? compressedFile =
          await FlutterImageCompress.compressAndGetFile(
        croppedFile.path,
        targetPath,
        quality: 80,
        minWidth: 1080,// test
        minHeight: 1080,
        format: CompressFormat.jpeg,
      );

      if (compressedFile == null) return;

      setState(() {
        _imageFile = File(compressedFile.path);
      });

      // Optional 4. Upload to Supabase could be handled here.

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('处理成功！已获取压缩后的图片')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('图片处理失败: $e')),
        );
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('图片处理全流程'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _isProcessing
                ? const CircularProgressIndicator()
                : CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.grey[200],
                    backgroundImage:
                        _imageFile != null ? FileImage(_imageFile!) : null,
                    child: _imageFile == null
                        ? const Icon(Icons.person, size: 80, color: Colors.grey)
                        : null,
                  ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _isProcessing
                      ? null
                      : () => _processImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('拍照'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _isProcessing
                      ? null
                      : () => _processImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('相册'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
