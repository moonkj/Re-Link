/// 꽃 타입 (Memory Bouquet) — Z세대 감성 이모티콘
enum FlowerType {
  sparkleHeart('rose', '✨', '두근두근'),
  fireHeart('tulip', '🔥', '불타는맘'),
  bubble('sunflower', '🫧', '나비야'),
  bolt('lily', '⚡', '응원해'),
  healingHeart('cherry_blossom', '🤍', '힐링'),
  star('star', '⭐', '최고야'),
  moon('moon', '🌙', '굿나잇'),
  clover('clover', '🍀', '행운을');

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
        orElse: () => FlowerType.sparkleHeart,
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
    this.isRead = false,
  });

  final String id;
  final String fromNodeId;
  final String toNodeId;
  final FlowerType flowerType;
  final DateTime date;
  final DateTime createdAt;
  final bool isRead;

  Bouquet copyWith({
    String? id,
    String? fromNodeId,
    String? toNodeId,
    FlowerType? flowerType,
    DateTime? date,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return Bouquet(
      id: id ?? this.id,
      fromNodeId: fromNodeId ?? this.fromNodeId,
      toNodeId: toNodeId ?? this.toNodeId,
      flowerType: flowerType ?? this.flowerType,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Bouquet && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
