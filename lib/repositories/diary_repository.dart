import 'package:my_flutter_app/models/diary_entry.dart';

/// Diary 数据仓库接口 (抽象层)
/// 定义所有日记相关的数据操作，不关心具体实现
abstract class DiaryRepository {
  /// 获取当前用户的所有日记
  Future<List<DiaryEntry>> getDiaries();

  /// 根据 ID 获取单条日记
  Future<DiaryEntry?> getDiaryById(String id);

  /// 创建日记
  Future<DiaryEntry> createDiary({
    required String title,
    required String content,
    String? moodLabel,
    String? moodEmoji,
  });

  /// 更新日记
  Future<DiaryEntry> updateDiary(DiaryEntry entry);

  /// 删除日记
  Future<void> deleteDiary(String id);
}
