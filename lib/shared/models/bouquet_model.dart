/// 꽃 타입 (Memory Bouquet)
enum FlowerType {
  rose('rose', '\u{1F339}', '장미'),
  tulip('tulip', '\u{1F337}', '튤립'),
  sunflower('sunflower', '\u{1F33B}', '해바라기'),
  lily('lily', '\u{1FAB7}', '백합'),
  cherryBlossom('cherry_blossom', '\u{1F338}', '벚꽃');

  const FlowerType(this.dbValue, this.emoji, this.label);

  /// DB에 저장되는 문자열
  final String dbValue;

  /// 이모지 표현
  final String emoji;

  /// 한국어 라벨
  final String label;

  /// DB 문자열에서 enum으로 변환
  static FlowerType fromDb(String value) => FlowerType.values.firstWhere(
        (e) => e.dbValue == value,
        orElse: () => FlowerType.rose,
      );
}

/// Memory Bouquet 도메인 모델
class Bouquet {
  const Bouquet({
    required this.id,
    required this.fromNodeId,
    required this.toNodeId,
    required this.flowerType,
    required this.date,
    required this.createdAt,
  });

  final String id;
  final String fromNodeId;
  final String toNodeId;
  final FlowerType flowerType;
  final DateTime date;
  final DateTime createdAt;

  Bouquet copyWith({
    String? id,
    String? fromNodeId,
    String? toNodeId,
    FlowerType? flowerType,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return Bouquet(
      id: id ?? this.id,
      fromNodeId: fromNodeId ?? this.fromNodeId,
      toNodeId: toNodeId ?? this.toNodeId,
      flowerType: flowerType ?? this.flowerType,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Bouquet && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
