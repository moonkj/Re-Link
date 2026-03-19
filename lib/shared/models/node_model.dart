/// 인물 노드 도메인 모델 (로컬 퍼스트 — familyId 없음)
class NodeModel {
  const NodeModel({
    required this.id,
    required this.name,
    this.nickname,
    this.photoPath,    // 로컬 파일 경로
    this.bio,
    this.birthDate,
    this.deathDate,
    this.isGhost = false,
    this.temperature = 2,
    this.positionX = 0.0,
    this.positionY = 0.0,
    this.tags = const [],
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String? nickname;
  final String? photoPath;  // 로컬 파일 경로 (Supabase URL 아님)
  final String? bio;
  final DateTime? birthDate;
  final DateTime? deathDate;
  final bool isGhost;
  final int temperature;    // 0(icy) ~ 5(fire)
  final double positionX;
  final double positionY;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? updatedAt;

  bool get isAlive => deathDate == null;
  String get displayName => nickname != null ? '$name ($nickname)' : name;

  NodeModel copyWith({
    String? id,
    String? name,
    String? nickname,
    String? photoPath,
    String? bio,
    DateTime? birthDate,
    DateTime? deathDate,
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
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      photoPath: photoPath ?? this.photoPath,
      bio: bio ?? this.bio,
      birthDate: birthDate ?? this.birthDate,
      deathDate: deathDate ?? this.deathDate,
      isGhost: isGhost ?? this.isGhost,
      temperature: temperature ?? this.temperature,
      positionX: positionX ?? this.positionX,
      positionY: positionY ?? this.positionY,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NodeModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// 노드 간 관계 (Adjacency List)
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
    required this.fromNodeId,
    required this.toNodeId,
    required this.relation,
    this.label,
    required this.createdAt,
  });

  final String id;
  final String fromNodeId;
  final String toNodeId;
  final RelationType relation;
  final String? label;
  final DateTime createdAt;
}
