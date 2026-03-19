/// 기억 타입
enum MemoryType {
  photo,
  voice,
  note,
  ai;

  String get label => switch (this) {
        photo => '사진',
        voice => '음성',
        note => '메모',
        ai => 'AI 대화',
      };
}

/// 기억 모델
class MemoryModel {
  const MemoryModel({
    required this.id,
    required this.nodeId,
    required this.familyId,
    required this.createdBy,
    required this.type,
    this.title,
    this.description,
    this.fileUrl,
    this.thumbnailUrl,
    this.durationSeconds,
    this.dateTaken,
    this.tags = const [],
    required this.createdAt,
  });

  final String id;
  final String nodeId;
  final String familyId;
  final String createdBy;
  final MemoryType type;
  final String? title;
  final String? description;
  final String? fileUrl;
  final String? thumbnailUrl;
  final int? durationSeconds; // 음성 캡슐용
  final DateTime? dateTaken;
  final List<String> tags;
  final DateTime createdAt;

  String? get formattedDuration {
    if (durationSeconds == null) return null;
    final minutes = durationSeconds! ~/ 60;
    final seconds = durationSeconds! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  MemoryModel copyWith({
    String? id,
    String? nodeId,
    String? familyId,
    String? createdBy,
    MemoryType? type,
    String? title,
    String? description,
    String? fileUrl,
    String? thumbnailUrl,
    int? durationSeconds,
    DateTime? dateTaken,
    List<String>? tags,
    DateTime? createdAt,
  }) {
    return MemoryModel(
      id: id ?? this.id,
      nodeId: nodeId ?? this.nodeId,
      familyId: familyId ?? this.familyId,
      createdBy: createdBy ?? this.createdBy,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      fileUrl: fileUrl ?? this.fileUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      dateTaken: dateTaken ?? this.dateTaken,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory MemoryModel.fromJson(Map<String, dynamic> json) {
    return MemoryModel(
      id: json['id'] as String,
      nodeId: json['node_id'] as String,
      familyId: json['family_id'] as String,
      createdBy: json['created_by'] as String,
      type: MemoryType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MemoryType.note,
      ),
      title: json['title'] as String?,
      description: json['description'] as String?,
      fileUrl: json['file_url'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      durationSeconds: json['duration_seconds'] as int?,
      dateTaken: json['date_taken'] != null
          ? DateTime.parse(json['date_taken'] as String)
          : null,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'node_id': nodeId,
        'family_id': familyId,
        'created_by': createdBy,
        'type': type.name,
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (fileUrl != null) 'file_url': fileUrl,
        if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
        if (durationSeconds != null) 'duration_seconds': durationSeconds,
        if (dateTaken != null) 'date_taken': dateTaken!.toIso8601String(),
        'tags': tags,
        'created_at': createdAt.toIso8601String(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemoryModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
