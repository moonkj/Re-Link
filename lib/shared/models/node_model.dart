/// 인물 노드 모델
class NodeModel {
  const NodeModel({
    required this.id,
    required this.familyId,
    required this.name,
    this.nickname,
    this.birthDate,
    this.deathDate,
    this.photoUrl,
    this.bio,
    this.isGhost = false,
    this.temperature = 2, // 0–5 (기본: neutral)
    this.positionX = 0.0,
    this.positionY = 0.0,
    this.tags = const [],
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String familyId;
  final String name;
  final String? nickname;
  final DateTime? birthDate;
  final DateTime? deathDate;
  final String? photoUrl;
  final String? bio;

  /// Ghost Node: 실제 인물 미확인 조상
  final bool isGhost;

  /// 온도 레벨 0(icy) ~ 5(fire)
  final int temperature;

  /// 캔버스 위치
  final double positionX;
  final double positionY;

  final List<String> tags;
  final DateTime createdAt;
  final DateTime? updatedAt;

  bool get isAlive => deathDate == null;

  String get displayName => nickname != null ? '$name ($nickname)' : name;

  NodeModel copyWith({
    String? id,
    String? familyId,
    String? name,
    String? nickname,
    DateTime? birthDate,
    DateTime? deathDate,
    String? photoUrl,
    String? bio,
    bool? isGhost,
    int? temperature,
    double? positionX,
    double? positionY,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NodeModel(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      birthDate: birthDate ?? this.birthDate,
      deathDate: deathDate ?? this.deathDate,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      isGhost: isGhost ?? this.isGhost,
      temperature: temperature ?? this.temperature,
      positionX: positionX ?? this.positionX,
      positionY: positionY ?? this.positionY,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory NodeModel.fromJson(Map<String, dynamic> json) {
    return NodeModel(
      id: json['id'] as String,
      familyId: json['family_id'] as String,
      name: json['name'] as String,
      nickname: json['nickname'] as String?,
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'] as String)
          : null,
      deathDate: json['death_date'] != null
          ? DateTime.parse(json['death_date'] as String)
          : null,
      photoUrl: json['photo_url'] as String?,
      bio: json['bio'] as String?,
      isGhost: json['is_ghost'] as bool? ?? false,
      temperature: json['temperature'] as int? ?? 2,
      positionX: (json['position_x'] as num?)?.toDouble() ?? 0.0,
      positionY: (json['position_y'] as num?)?.toDouble() ?? 0.0,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'family_id': familyId,
      'name': name,
      if (nickname != null) 'nickname': nickname,
      if (birthDate != null) 'birth_date': birthDate!.toIso8601String(),
      if (deathDate != null) 'death_date': deathDate!.toIso8601String(),
      if (photoUrl != null) 'photo_url': photoUrl,
      if (bio != null) 'bio': bio,
      'is_ghost': isGhost,
      'temperature': temperature,
      'position_x': positionX,
      'position_y': positionY,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NodeModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// 노드 간 관계 (엣지)
enum RelationType {
  parent,
  child,
  spouse,
  sibling,
  other;

  String get label => switch (this) {
        parent => '부모',
        child => '자녀',
        spouse => '배우자',
        sibling => '형제/자매',
        other => '기타',
      };
}

class NodeEdge {
  const NodeEdge({
    required this.id,
    required this.familyId,
    required this.fromNodeId,
    required this.toNodeId,
    required this.relation,
    this.label,
    required this.createdAt,
  });

  final String id;
  final String familyId;
  final String fromNodeId;
  final String toNodeId;
  final RelationType relation;
  final String? label;
  final DateTime createdAt;

  factory NodeEdge.fromJson(Map<String, dynamic> json) {
    return NodeEdge(
      id: json['id'] as String,
      familyId: json['family_id'] as String,
      fromNodeId: json['from_node_id'] as String,
      toNodeId: json['to_node_id'] as String,
      relation: RelationType.values.firstWhere(
        (e) => e.name == json['relation'],
        orElse: () => RelationType.other,
      ),
      label: json['label'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'family_id': familyId,
        'from_node_id': fromNodeId,
        'to_node_id': toNodeId,
        'relation': relation.name,
        if (label != null) 'label': label,
        'created_at': createdAt.toIso8601String(),
      };
}
