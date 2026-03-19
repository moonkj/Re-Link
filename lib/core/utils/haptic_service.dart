import 'package:flutter/services.dart';

/// 햅틱 피드백 서비스 — 3단계 티어
///
/// Tier 1 — Light  : 탭, 슬라이더 스텝, 탭 전환
/// Tier 2 — Medium : 노드 연결, 기억 추가, 드래그 시작
/// Tier 3 — Heavy  : 삭제 확인, 에러, 플랜 제한 도달
abstract final class HapticService {
  /// Tier 1: 가벼운 탭 피드백
  static Future<void> light() => HapticFeedback.lightImpact();

  /// Tier 2: 중간 강도 — 연결/추가 액션
  static Future<void> medium() => HapticFeedback.mediumImpact();

  /// Tier 3: 강한 피드백 — 삭제/에러
  static Future<void> heavy() => HapticFeedback.heavyImpact();

  /// 선택 변경 (슬라이더, 탭 인디케이터)
  static Future<void> selection() => HapticFeedback.selectionClick();
}
