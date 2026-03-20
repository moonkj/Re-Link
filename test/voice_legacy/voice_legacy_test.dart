import 'package:flutter_test/flutter_test.dart';

/// VoiceLegacyTable 스키마를 반영한 순수 테스트용 모델.
/// DB 의존 없이 봉인 상태 로직을 검증한다.
class _VoiceLegacyFields {
  _VoiceLegacyFields({
    required this.id,
    required this.fromNodeId,
    required this.toNodeId,
    required this.title,
    required this.voicePath,
    this.durationSeconds = 0,
    this.openCondition = 'date',
    this.openDate,
    this.isOpened = false,
    this.openedAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String fromNodeId;
  final String toNodeId;
  final String title;
  final String voicePath;
  final int durationSeconds;
  final String openCondition; // 'date' or 'manual'
  final DateTime? openDate;
  final bool isOpened;
  final DateTime? openedAt;
  final DateTime createdAt;
}

/// 봉인 상태를 나타내는 enum
enum SealStatus {
  sealed, // 봉인됨 (아직 열 수 없음)
  openable, // 열림 가능 (openDate 도래 && !isOpened)
  opened, // 이미 열림
}

/// 봉인 상태 판별 로직 (순수 함수)
SealStatus determineSealStatus(_VoiceLegacyFields legacy, {DateTime? now}) {
  if (legacy.isOpened) return SealStatus.opened;

  if (legacy.openCondition == 'manual') {
    // manual 조건: 항상 openable (수동 열기 가능)
    return SealStatus.openable;
  }

  // date 조건
  if (legacy.openDate == null) return SealStatus.sealed;

  final currentTime = now ?? DateTime.now();
  if (currentTime.isAfter(legacy.openDate!) ||
      currentTime.isAtSameMomentAs(legacy.openDate!)) {
    return SealStatus.openable;
  }

  return SealStatus.sealed;
}

void main() {
  // ═══════════════════════════════════════════════════════════════════════════
  // 1. 모델 필드 검증
  // ═══════════════════════════════════════════════════════════════════════════
  group('VoiceLegacy 모델 필드 검증', () {
    test('필수 필드가 모두 올바르게 저장된다', () {
      final legacy = _VoiceLegacyFields(
        id: 'vl-001',
        fromNodeId: 'node-dad',
        toNodeId: 'node-son',
        title: '아들에게 보내는 메시지',
        voicePath: '/voice/msg_001.m4a',
        durationSeconds: 120,
        openCondition: 'date',
        openDate: DateTime(2030, 1, 1),
      );

      expect(legacy.id, 'vl-001');
      expect(legacy.fromNodeId, 'node-dad');
      expect(legacy.toNodeId, 'node-son');
      expect(legacy.title, '아들에게 보내는 메시지');
      expect(legacy.voicePath, '/voice/msg_001.m4a');
      expect(legacy.durationSeconds, 120);
      expect(legacy.openCondition, 'date');
      expect(legacy.openDate, DateTime(2030, 1, 1));
    });

    test('durationSeconds 기본값은 0', () {
      final legacy = _VoiceLegacyFields(
        id: 'vl-002',
        fromNodeId: 'a',
        toNodeId: 'b',
        title: 'test',
        voicePath: '/v.m4a',
      );
      expect(legacy.durationSeconds, 0);
    });

    test('openCondition 기본값은 "date"', () {
      final legacy = _VoiceLegacyFields(
        id: 'vl-003',
        fromNodeId: 'a',
        toNodeId: 'b',
        title: 'test',
        voicePath: '/v.m4a',
      );
      expect(legacy.openCondition, 'date');
    });

    test('isOpened 기본값은 false', () {
      final legacy = _VoiceLegacyFields(
        id: 'vl-004',
        fromNodeId: 'a',
        toNodeId: 'b',
        title: 'test',
        voicePath: '/v.m4a',
      );
      expect(legacy.isOpened, isFalse);
    });

    test('openedAt은 기본 null (아직 열리지 않음)', () {
      final legacy = _VoiceLegacyFields(
        id: 'vl-005',
        fromNodeId: 'a',
        toNodeId: 'b',
        title: 'test',
        voicePath: '/v.m4a',
      );
      expect(legacy.openedAt, isNull);
    });

    test('createdAt 기본값은 현재 시각 근방이다', () {
      final before = DateTime.now();
      final legacy = _VoiceLegacyFields(
        id: 'vl-006',
        fromNodeId: 'a',
        toNodeId: 'b',
        title: 'test',
        voicePath: '/v.m4a',
      );
      final after = DateTime.now();

      expect(
        legacy.createdAt.isAfter(
          before.subtract(const Duration(seconds: 1)),
        ),
        isTrue,
      );
      expect(
        legacy.createdAt.isBefore(after.add(const Duration(seconds: 1))),
        isTrue,
      );
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. 수신자/발신자 관계 검증
  // ═══════════════════════════════════════════════════════════════════════════
  group('수신자/발신자 관계 검증', () {
    test('fromNodeId와 toNodeId가 서로 다르다', () {
      final legacy = _VoiceLegacyFields(
        id: 'vl-010',
        fromNodeId: 'node-mom',
        toNodeId: 'node-daughter',
        title: '딸에게',
        voicePath: '/v.m4a',
      );
      expect(legacy.fromNodeId, isNot(equals(legacy.toNodeId)));
    });

    test('fromNodeId와 toNodeId가 같아도 객체 생성은 가능 (자기자신에게)', () {
      final legacy = _VoiceLegacyFields(
        id: 'vl-011',
        fromNodeId: 'node-me',
        toNodeId: 'node-me',
        title: '미래의 나에게',
        voicePath: '/v.m4a',
      );
      expect(legacy.fromNodeId, legacy.toNodeId);
    });

    test('같은 발신자가 여러 수신자에게 보낼 수 있다', () {
      final legacies = [
        _VoiceLegacyFields(
          id: 'vl-012',
          fromNodeId: 'node-grandpa',
          toNodeId: 'node-son',
          title: '아들에게',
          voicePath: '/v1.m4a',
        ),
        _VoiceLegacyFields(
          id: 'vl-013',
          fromNodeId: 'node-grandpa',
          toNodeId: 'node-daughter',
          title: '딸에게',
          voicePath: '/v2.m4a',
        ),
        _VoiceLegacyFields(
          id: 'vl-014',
          fromNodeId: 'node-grandpa',
          toNodeId: 'node-grandson',
          title: '손자에게',
          voicePath: '/v3.m4a',
        ),
      ];

      final fromGrandpa =
          legacies.where((l) => l.fromNodeId == 'node-grandpa').toList();
      expect(fromGrandpa.length, 3);

      final toNodeIds = fromGrandpa.map((l) => l.toNodeId).toSet();
      expect(toNodeIds.length, 3);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. openCondition 검증
  // ═══════════════════════════════════════════════════════════════════════════
  group('openCondition enum/string 검증', () {
    test('"date" 조건은 유효하다', () {
      final legacy = _VoiceLegacyFields(
        id: 'vl-020',
        fromNodeId: 'a',
        toNodeId: 'b',
        title: 'test',
        voicePath: '/v.m4a',
        openCondition: 'date',
        openDate: DateTime(2030, 6, 15),
      );
      expect(legacy.openCondition, 'date');
      expect(legacy.openDate, isNotNull);
    });

    test('"manual" 조건은 유효하다', () {
      final legacy = _VoiceLegacyFields(
        id: 'vl-021',
        fromNodeId: 'a',
        toNodeId: 'b',
        title: 'test',
        voicePath: '/v.m4a',
        openCondition: 'manual',
      );
      expect(legacy.openCondition, 'manual');
    });

    test('"date" 조건에 openDate가 null이면 영원히 봉인', () {
      final legacy = _VoiceLegacyFields(
        id: 'vl-022',
        fromNodeId: 'a',
        toNodeId: 'b',
        title: 'test',
        voicePath: '/v.m4a',
        openCondition: 'date',
        openDate: null,
      );
      expect(legacy.openCondition, 'date');
      expect(legacy.openDate, isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. 봉인 상태 로직 (3가지 상태)
  // ═══════════════════════════════════════════════════════════════════════════
  group('봉인 상태 로직', () {
    test('봉인(sealed): openDate가 미래이고 아직 열리지 않음', () {
      final legacy = _VoiceLegacyFields(
        id: 'vl-030',
        fromNodeId: 'a',
        toNodeId: 'b',
        title: 'future',
        voicePath: '/v.m4a',
        openCondition: 'date',
        openDate: DateTime(2099, 12, 31),
        isOpened: false,
      );

      final status = determineSealStatus(legacy, now: DateTime(2026, 3, 21));
      expect(status, SealStatus.sealed);
    });

    test('열림가능(openable): openDate가 과거이고 아직 열리지 않음', () {
      final legacy = _VoiceLegacyFields(
        id: 'vl-031',
        fromNodeId: 'a',
        toNodeId: 'b',
        title: 'past',
        voicePath: '/v.m4a',
        openCondition: 'date',
        openDate: DateTime(2025, 1, 1),
        isOpened: false,
      );

      final status = determineSealStatus(legacy, now: DateTime(2026, 3, 21));
      expect(status, SealStatus.openable);
    });

    test('열림가능(openable): openDate가 정확히 현재 시각과 같음', () {
      final exactTime = DateTime(2026, 6, 15, 12, 0);
      final legacy = _VoiceLegacyFields(
        id: 'vl-032',
        fromNodeId: 'a',
        toNodeId: 'b',
        title: 'exact',
        voicePath: '/v.m4a',
        openCondition: 'date',
        openDate: exactTime,
        isOpened: false,
      );

      final status = determineSealStatus(legacy, now: exactTime);
      expect(status, SealStatus.openable);
    });

    test('열림(opened): isOpened가 true', () {
      final legacy = _VoiceLegacyFields(
        id: 'vl-033',
        fromNodeId: 'a',
        toNodeId: 'b',
        title: 'opened',
        voicePath: '/v.m4a',
        openCondition: 'date',
        openDate: DateTime(2025, 1, 1),
        isOpened: true,
        openedAt: DateTime(2025, 6, 1),
      );

      final status = determineSealStatus(legacy, now: DateTime(2026, 3, 21));
      expect(status, SealStatus.opened);
    });

    test('열림(opened): isOpened가 true면 openDate 미래여도 opened', () {
      final legacy = _VoiceLegacyFields(
        id: 'vl-034',
        fromNodeId: 'a',
        toNodeId: 'b',
        title: 'force-opened',
        voicePath: '/v.m4a',
        openCondition: 'date',
        openDate: DateTime(2099, 12, 31),
        isOpened: true,
        openedAt: DateTime(2026, 1, 1),
      );

      final status = determineSealStatus(legacy, now: DateTime(2026, 3, 21));
      expect(status, SealStatus.opened);
    });

    test('봉인(sealed): "date" 조건인데 openDate가 null이면 영원히 봉인', () {
      final legacy = _VoiceLegacyFields(
        id: 'vl-035',
        fromNodeId: 'a',
        toNodeId: 'b',
        title: 'no-date',
        voicePath: '/v.m4a',
        openCondition: 'date',
        openDate: null,
        isOpened: false,
      );

      final status = determineSealStatus(legacy, now: DateTime(2026, 3, 21));
      expect(status, SealStatus.sealed);
    });

    test('열림가능(openable): "manual" 조건이면 즉시 openable', () {
      final legacy = _VoiceLegacyFields(
        id: 'vl-036',
        fromNodeId: 'a',
        toNodeId: 'b',
        title: 'manual',
        voicePath: '/v.m4a',
        openCondition: 'manual',
        isOpened: false,
      );

      final status = determineSealStatus(legacy, now: DateTime(2026, 3, 21));
      expect(status, SealStatus.openable);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 5. 공개 조건 로직 — DateTime 비교
  // ═══════════════════════════════════════════════════════════════════════════
  group('공개 조건 — DateTime 비교', () {
    test('openDate 1초 전은 sealed', () {
      final openDate = DateTime(2026, 6, 15, 12, 0, 0);
      final legacy = _VoiceLegacyFields(
        id: 'vl-040',
        fromNodeId: 'a',
        toNodeId: 'b',
        title: 'test',
        voicePath: '/v.m4a',
        openCondition: 'date',
        openDate: openDate,
      );

      final oneSecBefore = openDate.subtract(const Duration(seconds: 1));
      expect(determineSealStatus(legacy, now: oneSecBefore), SealStatus.sealed);
    });

    test('openDate 1초 후는 openable', () {
      final openDate = DateTime(2026, 6, 15, 12, 0, 0);
      final legacy = _VoiceLegacyFields(
        id: 'vl-041',
        fromNodeId: 'a',
        toNodeId: 'b',
        title: 'test',
        voicePath: '/v.m4a',
        openCondition: 'date',
        openDate: openDate,
      );

      final oneSecAfter = openDate.add(const Duration(seconds: 1));
      expect(
        determineSealStatus(legacy, now: oneSecAfter),
        SealStatus.openable,
      );
    });

    test('openDate 한참 뒤 — 여전히 openable', () {
      final legacy = _VoiceLegacyFields(
        id: 'vl-042',
        fromNodeId: 'a',
        toNodeId: 'b',
        title: 'test',
        voicePath: '/v.m4a',
        openCondition: 'date',
        openDate: DateTime(2025, 1, 1),
      );

      final farFuture = DateTime(2050, 12, 31);
      expect(
        determineSealStatus(legacy, now: farFuture),
        SealStatus.openable,
      );
    });
  });
}
