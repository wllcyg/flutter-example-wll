class DiaryEntry {
  final String id;
  final String userId;
  final String? title;
  final String? content;
  final String? moodLabel;
  final String? moodEmoji;
  final String? coverUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  DiaryEntry({
    required this.id,
    required this.userId,
    this.title,
    this.content,
    this.moodLabel,
    this.moodEmoji,
    this.coverUrl,
    required this.createdAt,
    this.updatedAt,
  });

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String?,
      content: json['content'] as String?,
      moodLabel: json['mood_label'] as String?,
      moodEmoji: json['mood_emoji'] as String?,
      coverUrl: json['cover_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String).toLocal()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'mood_label': moodLabel,
      'mood_emoji': moodEmoji,
      'cover_url': coverUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
