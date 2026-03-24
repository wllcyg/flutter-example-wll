import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_flutter_app/repositories/diary_repository.dart';
import 'package:my_flutter_app/repositories/impl/supabase_diary_repository.dart';

part 'repository_providers.g.dart';

/// 提供 DiaryRepository 实例
/// 后续如果要切换数据源，只需修改这里！
@riverpod
DiaryRepository diaryRepository(DiaryRepositoryRef ref) {
  return SupabaseDiaryRepository(Supabase.instance.client);
}
