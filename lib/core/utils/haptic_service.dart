import 'package:flutter/services.dart';

/// 햅틱 피드백 서비스 — 3단계 티어 + 인터랙션별 명명 메서드
///
/// Tier 1 — Light  : 탭, 슬라이더 스텝, 탭 전환
/// Tier 2 — Medium : 노드 연결, 기억 추가, 드래그 시작
/// Tier 3 — Heavy  : 삭제 확인, 에러, 플랜 제한 도달
abstract final class HapticService {
  // ── 기본 티어 ─────────────────────────────────────────────────────────────

  /// Tier 1: 가벼운 탭 피드백
  static Future<void> light() => HapticFeedback.lightImpact();

  /// Tier 2: 중간 강도 — 연결/추가 액션
  static Future<void> medium() => HapticFeedback.mediumImpact();

  /// Tier 3: 강한 피드백 — 삭제/에러
  static Future<void> heavy() => HapticFeedback.heavyImpact();

  /// 선택 변경 (슬라이더, 탭 인디케이터)
  static Future<void> selection() => HapticFeedback.selectionClick();

  // ── 인터랙션별 명명 메서드 ─────────────────────────────────────────────────

  /// Ghost → 실제 인물 전환 완료 (heavyImpact × 2)
  static Future<void> ghostFill() async {
    await HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.heavyImpact();
  }

  /// 가계도 포스터 내보내기 완료 (heavyImpact × 2)
  static Future<void> heritageExport() async {
    await HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.heavyImpact();
  }

  /// 온도 슬라이더 스텝 변경 (selectionClick)
  static Future<void> vibeMeterStep() => HapticFeedback.selectionClick();

  /// 노드 연결 완료 (mediumImpact)
  static Future<void> connectionMade() => HapticFeedback.mediumImpact();

  /// 기억 저장 완료 (mediumImpact)
  static Future<void> memoryAdded() => HapticFeedback.mediumImpact();

  /// 노드 삭제 확인 (heavyImpact)
  static Future<void> nodeDeleted() => HapticFeedback.heavyImpact();

  /// 플랜 제한 도달 (heavyImpact)
  static Future<void> planLimitReached() => HapticFeedback.heavyImpact();

  /// 백업 완료 (lightImpact)
  static Future<void> backupComplete() => HapticFeedback.lightImpact();
}
