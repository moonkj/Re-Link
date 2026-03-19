/// NodeModel / RelationType / NodeEdge 단위 테스트
/// 커버: node_model.dart — displayName, isAlive, copyWith, ==, RelationType.label, NodeEdge
import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/shared/models/node_model.dart';

final _epoch = DateTime.utc(2024);

void main() {
  // ── NodeModel ──────────────────────────────────────────────────────────────

  group('NodeModel 기본 속성', () {
    test('nickname 있을 때 displayName = "name (nickname)"', () {
      final n = NodeModel(
        id: 'n1', name: '홍길동', nickname: '길동이', createdAt: _epoch,
      );
      expect(n.displayName, '홍길동 (길동이)');
    });

    test('nickname 없을 때 displayName = name', () {
      final n = NodeModel(id: 'n1', name: '홍길동', createdAt: _epoch);
      expect(n.displayName, '홍길동');
    });

    test('deathDate=null → isAlive=true', () {
      final n = NodeModel(id: 'n1', name: '홍', createdAt: _epoch);
      expect(n.isAlive, isTrue);
    });

    test('deathDate 설정 → isAlive=false', () {
      final n = NodeModel(
        id: 'n1', name: '홍', createdAt: _epoch,
        deathDate: DateTime(2020),
      );
      expect(n.isAlive, isFalse);
    });

    test('기본 temperature=2, isGhost=false', () {
      final n = NodeModel(id: 'n1', name: '홍', createdAt: _epoch);
      expect(n.temperature, 2);
      expect(n.isGhost, isFalse);
    });

    test('기본 positionX/Y=0.0, tags=[]', () {
      final n = NodeModel(id: 'n1', name: '홍', createdAt: _epoch);
      expect(n.positionX, 0.0);
      expect(n.positionY, 0.0);
      expect(n.tags, isEmpty);
    });
  });

  group('NodeModel copyWith', () {
    late NodeModel base;
    setUp(() {
      base = NodeModel(id: 'n1', name: '홍길동', createdAt: _epoch);
    });

    test('name 변경', () {
      expect(base.copyWith(name: '김철수').name, '김철수');
    });

    test('nickname 변경', () {
      expect(base.copyWith(nickname: '철수').nickname, '철수');
    });

    test('isGhost 변경', () {
      expect(base.copyWith(isGhost: true).isGhost, isTrue);
    });

    test('temperature 변경', () {
      expect(base.copyWith(temperature: 5).temperature, 5);
    });

    test('position 변경', () {
      final n = base.copyWith(positionX: 10.0, positionY: 20.0);
      expect(n.positionX, 10.0);
      expect(n.positionY, 20.0);
    });

    test('tags 변경', () {
      final n = base.copyWith(tags: ['가족', '친구']);
      expect(n.tags, ['가족', '친구']);
    });

    test('변경 없으면 원래 값 유지', () {
      final n = base.copyWith();
      expect(n.id, base.id);
      expect(n.name, base.name);
    });
  });

  group('NodeModel == / hashCode', () {
    test('같은 id → 동등', () {
      final a = NodeModel(id: 'n1', name: '홍', createdAt: _epoch);
      final b = NodeModel(id: 'n1', name: '다른이름', createdAt: _epoch);
      expect(a, equals(b));
    });

    test('다른 id → 불동등', () {
      final a = NodeModel(id: 'n1', name: '홍', createdAt: _epoch);
      final b = NodeModel(id: 'n2', name: '홍', createdAt: _epoch);
      expect(a, isNot(equals(b)));
    });

    test('hashCode는 id 기반', () {
      final a = NodeModel(id: 'n1', name: '홍', createdAt: _epoch);
      expect(a.hashCode, 'n1'.hashCode);
    });
  });

  // ── RelationType ──────────────────────────────────────────────────────────

  group('RelationType.label', () {
    test('parent → "부모"', () => expect(RelationType.parent.label, '부모'));
    test('child → "자녀"', () => expect(RelationType.child.label, '자녀'));
    test('spouse → "배우자"', () => expect(RelationType.spouse.label, '배우자'));
    test('sibling → "형제/자매"', () => expect(RelationType.sibling.label, '형제/자매'));
    test('other → "기타"', () => expect(RelationType.other.label, '기타'));
    test('5가지 값 존재', () => expect(RelationType.values.length, 5));
  });

  // ── NodeEdge ──────────────────────────────────────────────────────────────

  group('NodeEdge', () {
    test('필드 저장 및 접근', () {
      final e = NodeEdge(
        id: 'e1',
        fromNodeId: 'n1',
        toNodeId: 'n2',
        relation: RelationType.spouse,
        label: '결혼',
        createdAt: _epoch,
      );
      expect(e.id, 'e1');
      expect(e.fromNodeId, 'n1');
      expect(e.toNodeId, 'n2');
      expect(e.relation, RelationType.spouse);
      expect(e.label, '결혼');
    });

    test('label=null 허용', () {
      final e = NodeEdge(
        id: 'e2',
        fromNodeId: 'n1',
        toNodeId: 'n3',
        relation: RelationType.parent,
        createdAt: _epoch,
      );
      expect(e.label, isNull);
    });

    test('모든 RelationType으로 NodeEdge 생성 가능', () {
      for (final r in RelationType.values) {
        final e = NodeEdge(
          id: 'e_$r',
          fromNodeId: 'a',
          toNodeId: 'b',
          relation: r,
          createdAt: _epoch,
        );
        expect(e.relation, r);
      }
    });
  });
}
