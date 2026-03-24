import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_flutter_app/models/diary_entry.dart';
import 'package:my_flutter_app/repositories/diary_repository.dart';

/// Supabase 实现的 DiaryRepository
class SupabaseDiaryRepository implements DiaryRepository {
  final SupabaseClient _client;

  SupabaseDiaryRepository(this._client);

  String? get _userId => _client.auth.currentUser?.id;

  @override
  Future<List<DiaryEntry>> getDiaries() async {
    if (_userId == null) return [];

    final data = await _client
        .from('diary_entries')
        .select()
        .eq('user_id', _userId!)
        .order('created_at', ascending: false);

    return (data as List).map((e) => DiaryEntry.fromJson(e)).toList();
  }

  @override
  Future<DiaryEntry?> getDiaryById(String id) async {
    final data =
        await _client.from('diary_entries').select().eq('id', id).maybeSingle();

    return data != null ? DiaryEntry.fromJson(data) : null;
  }

  @override
  Future<DiaryEntry> createDiary({
    required String title,
    required String content,
    String? moodLabel,
    String? moodEmoji,
  }) async {
    final data = await _client
        .from('diary_entries')
        .insert({
          'user_id': _userId,
          'title': title,
          'content': content,
          'mood_label': moodLabel,
          'mood_emoji': moodEmoji,
        })
        .select()
        .single();

    return DiaryEntry.fromJson(data);
  }

  @override
  Future<DiaryEntry> updateDiary(DiaryEntry entry) async {
    final data = await _client
        .from('diary_entries')
        .update(entry.toJson())
        .eq('id', entry.id)
        .select()
        .single();

    return DiaryEntry.fromJson(data);
  }

  @override
  Future<void> deleteDiary(String id) async {
    await _client.from('diary_entries').delete().eq('id', id);
  }
}
