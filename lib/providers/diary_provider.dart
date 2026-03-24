import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:my_flutter_app/models/diary_entry.dart';
import 'package:my_flutter_app/providers/repository_providers.dart';

part 'diary_provider.g.dart';

/// 日记列表 Provider (重构后)
/// 现在通过 Repository 获取数据，不再直接依赖 Supabase
@riverpod
class DiaryList extends _$DiaryList {
  @override
  Future<List<DiaryEntry>> build() async {
    // ✅ 通过 Repository 获取数据
    final repository = ref.watch(diaryRepositoryProvider);
    return repository.getDiaries();
  }

  /// 删除日记
  Future<void> deleteEntry(String id) async {
    final repository = ref.read(diaryRepositoryProvider);
    await repository.deleteDiary(id);
    ref.invalidateSelf(); // 刷新列表
  }

  /// 添加日记
  Future<DiaryEntry> addEntry({
    required String title,
    required String content,
    String? moodLabel,
    String? moodEmoji,
  }) async {
    final repository = ref.read(diaryRepositoryProvider);
    final entry = await repository.createDiary(
      title: title,
      content: content,
      moodLabel: moodLabel,
      moodEmoji: moodEmoji,
    );
    ref.invalidateSelf(); // 刷新列表
    return entry;
  }

  /// 更新日记
  Future<DiaryEntry> updateEntry(DiaryEntry entry) async {
    final repository = ref.read(diaryRepositoryProvider);
    final updated = await repository.updateDiary(entry);
    ref.invalidateSelf(); // 刷新列表
    return updated;
  }
}

/// 单条日记详情 Provider
@riverpod
Future<DiaryEntry?> diaryDetail(DiaryDetailRef ref, String id) async {
  final repository = ref.watch(diaryRepositoryProvider);
  return repository.getDiaryById(id);
}
