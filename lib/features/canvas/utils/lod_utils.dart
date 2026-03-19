/// Level-of-Detail system for canvas node rendering
library;

/// 4단계 LOD 레벨 — 줌 스케일 기반
enum LodLevel {
  /// < 0.5× — 8×8 컬러 점만 표시 (Bird's Eye View)
  birdEye,

  /// 0.5×–1.0× — 원형 아바타 + 이름만 표시 (Overview)
  overview,

  /// 1.0×–2.0× — 풀 NodeCard (Detail)
  detail,

  /// > 2.0× — 풀 NodeCard + 기억 배지 (Zoom In)
  zoom,
}

/// 현재 줌 스케일에서 LOD 레벨 결정
LodLevel lodFromScale(double scale) {
  if (scale < 0.5) return LodLevel.birdEye;
  if (scale < 1.0) return LodLevel.overview;
  if (scale < 2.0) return LodLevel.detail;
  return LodLevel.zoom;
}
