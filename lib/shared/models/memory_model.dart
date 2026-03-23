/// 기억 타입 (AI 제거)
enum MemoryType {
  photo,
  voice,
  note,
  video;

  String get label => switch (this) {
        photo => '사진',
        voice => '음성',
        note => '메모',
        video => '영상',
      };
}

/// 기억 도메인 모델 (로컬 퍼스트)
class MemoryModel {
  const MemoryModel({
    required this.id,
    required this.nodeId,
    required this.type,
    this.title,
    this.description,
    this.filePath,          // 로컬 파일 경로 (사진/음성)
    this.thumbnailPath,     // 로컬 썸네일 경로
    this.r2FileKey,         // R2 클라우드 파일 키
    this.r2ThumbnailKey,    // R2 클라우드 썸네일 키
    this.durationSeconds,
    this.dateTaken,
    this.tags = const [],
    required this.createdAt,
    this.isPrivate = false,
  });

  final String id;
  final String nodeId;
  final MemoryType type;
  final String? title;
  final String? description;
  final String? filePath;
  final String? thumbnailPath;
  final String? r2FileKey;
  final String? r2ThumbnailKey;
  final int? durationSeconds;
  final DateTime? dateTaken;
  final List<String> tags;
  final DateTime createdAt;
  final bool isPrivate;

  String? get formattedDuration {
    if (durationSeconds == null) return null;
    final m = durationSeconds! ~/ 60;
    final s = durationSeconds! % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  MemoryModel copyWith({
    String? id,
    String? nodeId,
    MemoryType? type,
    String? title,
    String? description,
    String? filePath,
    String? thumbnailPath,
    String? r2FileKey,
    String? r2ThumbnailKey,
    int? durationSeconds,
    DateTime? dateTaken,
    List<String>? tags,
    DateTime? createdAt,
    bool? isPrivate,
    bool clearR2FileKey = false,
    bool clearR2ThumbnailKey = false,
  }) {
    return MemoryModel(
      id: id ?? this.id,
      nodeId: nodeId ?? this.nodeId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      filePath: filePath ?? this.filePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      r2FileKey: clearR2FileKey ? null : (r2FileKey ?? this.r2FileKey),
      r2ThumbnailKey: clearR2ThumbnailKey ? null : (r2ThumbnailKey ?? this.r2ThumbnailKey),
      durationSeconds: durationSeconds ?? this.durationSeconds,
      dateTaken: dateTaken ?? this.dateTaken,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      isPrivate: isPrivate ?? this.isPrivate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemoryModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
