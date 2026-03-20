/// 온도 일기 로그 도메인 모델
class TemperatureLog {
  const TemperatureLog({
    required this.id,
    required this.nodeId,
    required this.temperature,
    this.emotionTag,
    required this.date,
    required this.createdAt,
  });

  final String id;
  final String nodeId;
  final int temperature; // 0-5
  final String? emotionTag; // joy/longing/surprise/love/sadness
  final DateTime date;
  final DateTime createdAt;

  /// 감정 태그 한글 라벨
  String? get emotionLabel => emotionTag == null
      ? null
      : switch (emotionTag!) {
          'joy' => '기쁨',
          'longing' => '그리움',
          'surprise' => '놀람',
          'love' => '사랑',
          'sadness' => '슬픔',
          _ => emotionTag,
        };

  TemperatureLog copyWith({
    String? id,
    String? nodeId,
    int? temperature,
    String? emotionTag,
    DateTime? date,
    DateTime? createdAt,
    bool clearEmotionTag = false,
  }) {
    return TemperatureLog(
      id: id ?? this.id,
      nodeId: nodeId ?? this.nodeId,
      temperature: temperature ?? this.temperature,
      emotionTag: clearEmotionTag ? null : (emotionTag ?? this.emotionTag),
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TemperatureLog &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// 감정 태그 상수
abstract final class EmotionTags {
  static const String joy = 'joy';
  static const String longing = 'longing';
  static const String surprise = 'surprise';
  static const String love = 'love';
  static const String sadness = 'sadness';

  static const List<String> all = [joy, longing, surprise, love, sadness];

  static String label(String tag) => switch (tag) {
        joy => '기쁨',
        longing => '그리움',
        surprise => '놀람',
        love => '사랑',
        sadness => '슬픔',
        _ => tag,
      };
}
