/// NodeModel 확장 단위 테스트
/// 커버: node_model.dart — copyWith clear 플래그, isAlive, displayName, RelationType
import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/shared/models/node_model.dart';

final _epoch = DateTime.utc(2024);

void main() {
  // ── copyWith clear 플래그 ────────────────────────────────────────────────

  group('NodeModel copyWith — clear 플래그', () {
    late NodeModel full;

    setUp(() {
      full = NodeModel(
        id: 'n1',
        name: '홍길동',
        nickname: '길동이',
        photoPath: 'media/photos/photo1.webp',
        r2PhotoKey: 'r2/photos/photo1.webp',
        bio: '테스트 바이오입니다',
        birthDate: DateTime(1990, 5, 15),
        deathDate: DateTime(2060, 12, 31),
        isGhost: false,
        temperature: 3,
        positionX: 100.0,
        positionY: 200.0,
        tags: ['가족', '부모'],
        createdAt: _epoch,
        updatedAt: DateTime(2024, 6, 1),
      );
    });

    test('clearNickname=true → nickname=null', () {
      final result = full.copyWith(clearNickname: true);
      expect(result.nickname, isNull);
      // 다른 필드는 유지
      expect(result.name, '홍길동');
      expect(result.photoPath, 'media/photos/photo1.webp');
    });

    test('clearPhotoPath=true → photoPath=null', () {
      final result = full.copyWith(clearPhotoPath: true);
      expect(result.photoPath, isNull);
      expect(result.r2PhotoKey, 'r2/photos/photo1.webp'); // 다른 필드 유지
    });

    test('clearR2PhotoKey=true → r2PhotoKey=null', () {
      final result = full.copyWith(clearR2PhotoKey: true);
      expect(result.r2PhotoKey, isNull);
      expect(result.photoPath, 'media/photos/photo1.webp'); // 다른 필드 유지
    });

    test('clearBio=true → bio=null', () {
      final result = full.copyWith(clearBio: true);
      expect(result.bio, isNull);
    });

    test('clearBirthDate=true → birthDate=null', () {
      final result = full.copyWith(clearBirthDate: true);
      expect(result.birthDate, isNull);
    });

    test('clearDeathDate=true → deathDate=null', () {
      final result = full.copyWith(clearDeathDate: true);
      expect(result.deathDate, isNull);
    });

    test('모든 clear 플래그 동시 사용', () {
      final result = full.copyWith(
        clearNickname: true,
        clearPhotoPath: true,
        clearR2PhotoKey: true,
        clearBio: true,
        clearBirthDate: true,
        clearDeathDate: true,
      );
      expect(result.nickname, isNull);
      expect(result.photoPath, isNull);
      expect(result.r2PhotoKey, isNull);
      expect(result.bio, isNull);
      expect(result.birthDate, isNull);
      expect(result.deathDate, isNull);
      // 다른 필드는 유지
      expect(result.id, 'n1');
      expect(result.name, '홍길동');
      expect(result.temperature, 3);
      expect(result.positionX, 100.0);
      expect(result.positionY, 200.0);
      expect(result.tags, ['가족', '부모']);
    });

    test('clear=false + 새 값 → 새 값 적용', () {
      final result = full.copyWith(
        clearNickname: false,
        nickname: '새별명',
      );
      expect(result.nickname, '새별명');
    });

    test('clear=true + 새 값 → clear가 우선 (null)', () {
      final result = full.copyWith(
        clearNickname: true,
        nickname: '무시될별명',
      );
      // clearNickname이 true이면 nickname은 null
      expect(result.nickname, isNull);
    });

    test('clear 플래그 없이 copyWith → 기존 값 유지', () {
      final result = full.copyWith();
      expect(result.nickname, '길동이');
      expect(result.photoPath, 'media/photos/photo1.webp');
      expect(result.bio, '테스트 바이오입니다');
      expect(result.birthDate, DateTime(1990, 5, 15));
      expect(result.deathDate, DateTime(2060, 12, 31));
    });
  });

  // ── isAlive getter ────────────────────────────────────────────────────────

  group('NodeModel isAlive', () {
    test('deathDate=null → isAlive=true', () {
      final node = NodeModel(id: 'n1', name: '살아있음', createdAt: _epoch);
      expect(node.isAlive, isTrue);
    });

    test('deathDate 있음 → isAlive=false', () {
      final node = NodeModel(
        id: 'n1',
        name: '돌아가심',
        deathDate: DateTime(2020, 3, 15),
        createdAt: _epoch,
      );
      expect(node.isAlive, isFalse);
    });

    test('copyWith으로 deathDate 제거 → isAlive=true', () {
      final dead = NodeModel(
        id: 'n1',
        name: '테스트',
        deathDate: DateTime(2020),
        createdAt: _epoch,
      );
      expect(dead.isAlive, isFalse);

      final alive = dead.copyWith(clearDeathDate: true);
      expect(alive.isAlive, isTrue);
    });

    test('copyWith으로 deathDate 설정 → isAlive=false', () {
      final alive = NodeModel(id: 'n1', name: '테스트', createdAt: _epoch);
      expect(alive.isAlive, isTrue);

      final dead = alive.copyWith(deathDate: DateTime(2025));
      expect(dead.isAlive, isFalse);
    });
  });

  // ── displayName getter ────────────────────────────────────────────────────

  group('NodeModel displayName', () {
    test('nickname 있으면 "name (nickname)"', () {
      final node = NodeModel(
        id: 'n1',
        name: '김철수',
        nickname: '아빠',
        createdAt: _epoch,
      );
      expect(node.displayName, '김철수 (아빠)');
    });

    test('nickname 없으면 name만', () {
      final node = NodeModel(id: 'n1', name: '김철수', createdAt: _epoch);
      expect(node.displayName, '김철수');
    });

    test('copyWith으로 nickname 추가 → displayName 변경', () {
      final node = NodeModel(id: 'n1', name: '이영희', createdAt: _epoch);
      expect(node.displayName, '이영희');

      final withNick = node.copyWith(nickname: '엄마');
      expect(withNick.displayName, '이영희 (엄마)');
    });

    test('copyWith으로 nickname 제거 → name만', () {
      final node = NodeModel(
        id: 'n1',
        name: '박지성',
        nickname: '지성이',
        createdAt: _epoch,
      );
      expect(node.displayName, '박지성 (지성이)');

      final cleared = node.copyWith(clearNickname: true);
      expect(cleared.displayName, '박지성');
    });
  });

  // ── RelationType enum ────────────────────────────────────────────────────

  group('RelationType', () {
    test('5가지 값 존재', () {
      expect(RelationType.values.length, 5);
    });

    test('모든 값 이름', () {
      expect(RelationType.values.map((e) => e.name).toList(),
          ['parent', 'child', 'spouse', 'sibling', 'other']);
    });

    test('parent label → 부모', () {
      expect(RelationType.parent.label, '부모');
    });

    test('child label → 자녀', () {
      expect(RelationType.child.label, '자녀');
    });

    test('spouse label → 배우자', () {
      expect(RelationType.spouse.label, '배우자');
    });

    test('sibling label → 형제/자매', () {
      expect(RelationType.sibling.label, '형제/자매');
    });

    test('other label → 기타', () {
      expect(RelationType.other.label, '기타');
    });
  });

  // ── == / hashCode ─────────────────────────────────────────────────────────

  group('NodeModel == / hashCode', () {
    test('같은 id, 다른 필드 → 동등', () {
      final a = NodeModel(
        id: 'same-id',
        name: '이름A',
        temperature: 0,
        createdAt: _epoch,
      );
      final b = NodeModel(
        id: 'same-id',
        name: '이름B',
        temperature: 5,
        createdAt: DateTime(2025),
      );
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('다른 id → 불동등', () {
      final a = NodeModel(id: 'id-a', name: '홍', createdAt: _epoch);
      final b = NodeModel(id: 'id-b', name: '홍', createdAt: _epoch);
      expect(a, isNot(equals(b)));
    });

    test('Set에서 id 기반 중복 제거', () {
      final set = <NodeModel>{
        NodeModel(id: 'n1', name: 'A', createdAt: _epoch),
        NodeModel(id: 'n1', name: 'B', createdAt: _epoch),
        NodeModel(id: 'n2', name: 'C', createdAt: _epoch),
      };
      expect(set.length, 2);
    });
  });

  // ── NodeEdge ──────────────────────────────────────────────────────────────

  group('NodeEdge', () {
    test('label이 null인 엣지 생성', () {
      final edge = NodeEdge(
        id: 'e1',
        fromNodeId: 'n1',
        toNodeId: 'n2',
        relation: RelationType.parent,
        createdAt: _epoch,
      );
      expect(edge.label, isNull);
    });

    test('label이 있는 엣지 생성', () {
      final edge = NodeEdge(
        id: 'e2',
        fromNodeId: 'n1',
        toNodeId: 'n2',
        relation: RelationType.other,
        label: '멘토',
        createdAt: _epoch,
      );
      expect(edge.label, '멘토');
      expect(edge.relation, RelationType.other);
    });
  });

  // ── 기본값 ────────────────────────────────────────────────────────────────

  group('NodeModel 기본값', () {
    test('isGhost 기본값 = false', () {
      final n = NodeModel(id: 'n', name: '홍', createdAt: _epoch);
      expect(n.isGhost, isFalse);
    });

    test('temperature 기본값 = 2', () {
      final n = NodeModel(id: 'n', name: '홍', createdAt: _epoch);
      expect(n.temperature, 2);
    });

    test('positionX/Y 기본값 = 0.0', () {
      final n = NodeModel(id: 'n', name: '홍', createdAt: _epoch);
      expect(n.positionX, 0.0);
      expect(n.positionY, 0.0);
    });

    test('tags 기본값 = 빈 리스트', () {
      final n = NodeModel(id: 'n', name: '홍', createdAt: _epoch);
      expect(n.tags, isEmpty);
    });

    test('optional 필드 기본값 = null', () {
      final n = NodeModel(id: 'n', name: '홍', createdAt: _epoch);
      expect(n.nickname, isNull);
      expect(n.photoPath, isNull);
      expect(n.r2PhotoKey, isNull);
      expect(n.bio, isNull);
      expect(n.birthDate, isNull);
      expect(n.deathDate, isNull);
      expect(n.updatedAt, isNull);
    });
  });
}
