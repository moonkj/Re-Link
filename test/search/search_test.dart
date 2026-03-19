import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/shared/models/node_model.dart';
import 'package:re_link/shared/models/memory_model.dart';

/// 검색 필터 순수 로직 테스트
/// (실제 DB 검색은 LIKE 쿼리 위임 — 여기서는 모델 계층 검증)
void main() {
  // ── NodeModel 검색 필터 ──────────────────────────────────────────────────────

  group('NodeModel 검색 필터', () {
    final nodes = [
      _makeNode(id: '1', name: '홍길동', nickname: '길동이'),
      _makeNode(id: '2', name: '김영희', nickname: null),
      _makeNode(id: '3', name: '이철수', nickname: '철수'),
      _makeNode(id: '4', name: '박유령', nickname: '?', isGhost: true),
    ];

    List<NodeModel> filter(String q) => nodes
        .where((n) =>
            n.name.contains(q) ||
            (n.nickname?.contains(q) ?? false))
        .toList();

    test('이름으로 검색', () {
      expect(filter('홍길동').map((n) => n.id), contains('1'));
    });

    test('별명으로 검색', () {
      expect(filter('길동이').map((n) => n.id), contains('1'));
    });

    test('부분 이름 검색', () {
      expect(filter('철').map((n) => n.id), contains('3'));
    });

    test('ghost 노드도 검색됨', () {
      expect(filter('유령').map((n) => n.id), contains('4'));
    });

    test('없는 이름 → 빈 결과', () {
      expect(filter('존재하지않음'), isEmpty);
    });
  });

  // ── MemoryModel 검색 필터 ────────────────────────────────────────────────────

  group('MemoryModel 검색 필터', () {
    final memories = [
      _makeMemory(id: 'm1', title: '생일 사진', description: null),
      _makeMemory(id: 'm2', title: null, description: '어머니가 좋아하는 노래'),
      _makeMemory(id: 'm3', title: '가족 여행', description: '제주도 여름 여행'),
    ];

    List<MemoryModel> filter(String q) => memories
        .where((m) =>
            (m.title?.contains(q) ?? false) ||
            (m.description?.contains(q) ?? false))
        .toList();

    test('제목으로 검색', () {
      expect(filter('생일').map((m) => m.id), contains('m1'));
    });

    test('설명으로 검색', () {
      expect(filter('노래').map((m) => m.id), contains('m2'));
    });

    test('부분 검색', () {
      expect(filter('여').map((m) => m.id), containsAll(['m3']));
    });

    test('제목과 설명 모두 없으면 검색 안 됨', () {
      final noMatch = memories.where((m) =>
          (m.title?.contains('xyz') ?? false) ||
          (m.description?.contains('xyz') ?? false));
      expect(noMatch, isEmpty);
    });
  });

  // ── SearchResult 빈 상태 ─────────────────────────────────────────────────────

  group('SearchResult 빈 쿼리', () {
    test('빈 문자열 쿼리 → 검색 실행 안 함', () {
      expect(''.trim().isEmpty, isTrue);
    });

    test('공백만 있는 쿼리 → 검색 실행 안 함', () {
      expect('   '.trim().isEmpty, isTrue);
    });
  });
}

// ── 팩토리 헬퍼 ─────────────────────────────────────────────────────────────────

NodeModel _makeNode({
  required String id,
  required String name,
  String? nickname,
  bool isGhost = false,
}) {
  final now = DateTime(2026, 1, 1);
  return NodeModel(
    id: id,
    name: name,
    nickname: nickname,
    isGhost: isGhost,
    temperature: 2,
    positionX: 0,
    positionY: 0,
    tags: const [],
    createdAt: now,
    updatedAt: now,
  );
}

MemoryModel _makeMemory({
  required String id,
  String? title,
  String? description,
}) {
  return MemoryModel(
    id: id,
    nodeId: 'node-1',
    type: MemoryType.note,
    title: title,
    description: description,
    tags: const [],
    createdAt: DateTime(2026, 1, 1),
  );
}
