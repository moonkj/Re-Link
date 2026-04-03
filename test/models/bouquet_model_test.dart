/// FlowerType / Bouquet 단위 테스트
/// 커버: bouquet_model.dart — FlowerType enum 값, emoji, label, dbValue, fromDb, Bouquet copyWith/==/hashCode
import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/shared/models/bouquet_model.dart';

void main() {
  // ── FlowerType enum 값 ────────────────────────────────────────────────────

  group('FlowerType — enum 값 수', () {
    test('8가지 꽃 타입 존재', () {
      expect(FlowerType.values.length, 8);
    });

    test('모든 enum 이름', () {
      expect(
        FlowerType.values.map((e) => e.name).toList(),
        [
          'sparkleHeart',
          'fireHeart',
          'bubble',
          'bolt',
          'healingHeart',
          'star',
          'moon',
          'clover',
        ],
      );
    });
  });

  // ── dbValue ───────────────────────────────────────────────────────────────

  group('FlowerType — dbValue', () {
    test('sparkleHeart → rose', () => expect(FlowerType.sparkleHeart.dbValue, 'rose'));
    test('fireHeart → tulip', () => expect(FlowerType.fireHeart.dbValue, 'tulip'));
    test('bubble → sunflower', () => expect(FlowerType.bubble.dbValue, 'sunflower'));
    test('bolt → lily', () => expect(FlowerType.bolt.dbValue, 'lily'));
    test('healingHeart → cherry_blossom', () => expect(FlowerType.healingHeart.dbValue, 'cherry_blossom'));
    test('star → star', () => expect(FlowerType.star.dbValue, 'star'));
    test('moon → moon', () => expect(FlowerType.moon.dbValue, 'moon'));
    test('clover → clover', () => expect(FlowerType.clover.dbValue, 'clover'));
  });

  // ── emoji ─────────────────────────────────────────────────────────────────

  group('FlowerType — emoji', () {
    final expectedEmojis = {
      FlowerType.sparkleHeart: '\u2728', // ✨
      FlowerType.fireHeart: '\uD83D\uDD25', // 🔥 — actually let's just check non-empty
      FlowerType.bubble: '\uD83E\uDEE7', // 🫧
      FlowerType.bolt: '\u26A1', // ⚡
      FlowerType.healingHeart: '\uD83E\uDD0D', // 🤍
      FlowerType.star: '\u2B50', // ⭐
      FlowerType.moon: '\uD83C\uDF19', // 🌙
      FlowerType.clover: '\uD83C\uDF40', // 🍀
    };

    for (final flower in FlowerType.values) {
      test('${flower.name} emoji는 비어있지 않음', () {
        expect(flower.emoji, isNotEmpty);
      });
    }

    test('sparkleHeart emoji = ✨', () {
      expect(FlowerType.sparkleHeart.emoji, '✨');
    });

    test('fireHeart emoji = 🔥', () {
      expect(FlowerType.fireHeart.emoji, '🔥');
    });

    test('star emoji = ⭐', () {
      expect(FlowerType.star.emoji, '⭐');
    });

    test('moon emoji = 🌙', () {
      expect(FlowerType.moon.emoji, '🌙');
    });

    test('clover emoji = 🍀', () {
      expect(FlowerType.clover.emoji, '🍀');
    });
  });

  // ── label ─────────────────────────────────────────────────────────────────

  group('FlowerType — label', () {
    test('sparkleHeart → 두근두근', () => expect(FlowerType.sparkleHeart.label, '두근두근'));
    test('fireHeart → 불타는맘', () => expect(FlowerType.fireHeart.label, '불타는맘'));
    test('bubble → 나비야', () => expect(FlowerType.bubble.label, '나비야'));
    test('bolt → 응원해', () => expect(FlowerType.bolt.label, '응원해'));
    test('healingHeart → 힐링', () => expect(FlowerType.healingHeart.label, '힐링'));
    test('star → 최고야', () => expect(FlowerType.star.label, '최고야'));
    test('moon → 굿나잇', () => expect(FlowerType.moon.label, '굿나잇'));
    test('clover → 행운을', () => expect(FlowerType.clover.label, '행운을'));
  });

  // ── fromDb ────────────────────────────────────────────────────────────────

  group('FlowerType.fromDb', () {
    test('모든 dbValue → 올바른 enum 변환', () {
      for (final flower in FlowerType.values) {
        expect(FlowerType.fromDb(flower.dbValue), flower);
      }
    });

    test('rose → sparkleHeart', () {
      expect(FlowerType.fromDb('rose'), FlowerType.sparkleHeart);
    });

    test('tulip → fireHeart', () {
      expect(FlowerType.fromDb('tulip'), FlowerType.fireHeart);
    });

    test('sunflower → bubble', () {
      expect(FlowerType.fromDb('sunflower'), FlowerType.bubble);
    });

    test('lily → bolt', () {
      expect(FlowerType.fromDb('lily'), FlowerType.bolt);
    });

    test('cherry_blossom → healingHeart', () {
      expect(FlowerType.fromDb('cherry_blossom'), FlowerType.healingHeart);
    });

    test('star → star', () {
      expect(FlowerType.fromDb('star'), FlowerType.star);
    });

    test('moon → moon', () {
      expect(FlowerType.fromDb('moon'), FlowerType.moon);
    });

    test('clover → clover', () {
      expect(FlowerType.fromDb('clover'), FlowerType.clover);
    });

    test('알 수 없는 값 → sparkleHeart (기본값)', () {
      expect(FlowerType.fromDb('unknown_flower'), FlowerType.sparkleHeart);
    });

    test('빈 문자열 → sparkleHeart (기본값)', () {
      expect(FlowerType.fromDb(''), FlowerType.sparkleHeart);
    });
  });

  // ── dbValue 고유성 ────────────────────────────────────────────────────────

  group('FlowerType dbValue 고유성', () {
    test('모든 dbValue가 고유함', () {
      final dbValues = FlowerType.values.map((e) => e.dbValue).toSet();
      expect(dbValues.length, FlowerType.values.length);
    });
  });

  // ── Bouquet 모델 ──────────────────────────────────────────────────────────

  group('Bouquet', () {
    final now = DateTime(2026, 4, 3);

    test('필드 접근', () {
      final bouquet = Bouquet(
        id: 'b1',
        fromNodeId: 'n1',
        toNodeId: 'n2',
        flowerType: FlowerType.sparkleHeart,
        date: now,
        createdAt: now,
      );

      expect(bouquet.id, 'b1');
      expect(bouquet.fromNodeId, 'n1');
      expect(bouquet.toNodeId, 'n2');
      expect(bouquet.flowerType, FlowerType.sparkleHeart);
      expect(bouquet.isRead, isFalse); // 기본값
    });

    test('isRead 기본값 = false', () {
      final bouquet = Bouquet(
        id: 'b1',
        fromNodeId: 'n1',
        toNodeId: 'n2',
        flowerType: FlowerType.star,
        date: now,
        createdAt: now,
      );
      expect(bouquet.isRead, isFalse);
    });

    test('copyWith — flowerType 변경', () {
      final bouquet = Bouquet(
        id: 'b1',
        fromNodeId: 'n1',
        toNodeId: 'n2',
        flowerType: FlowerType.sparkleHeart,
        date: now,
        createdAt: now,
      );

      final copied = bouquet.copyWith(flowerType: FlowerType.fireHeart);
      expect(copied.flowerType, FlowerType.fireHeart);
      expect(copied.id, 'b1'); // 나머지 유지
    });

    test('copyWith — isRead 변경', () {
      final bouquet = Bouquet(
        id: 'b1',
        fromNodeId: 'n1',
        toNodeId: 'n2',
        flowerType: FlowerType.moon,
        date: now,
        createdAt: now,
      );

      final read = bouquet.copyWith(isRead: true);
      expect(read.isRead, isTrue);
    });

    test('copyWith — 변경 없이 호출 → 기존 값 유지', () {
      final bouquet = Bouquet(
        id: 'b1',
        fromNodeId: 'n1',
        toNodeId: 'n2',
        flowerType: FlowerType.clover,
        date: now,
        createdAt: now,
        isRead: true,
      );

      final copied = bouquet.copyWith();
      expect(copied.id, 'b1');
      expect(copied.flowerType, FlowerType.clover);
      expect(copied.isRead, isTrue);
    });
  });

  // ── Bouquet == / hashCode ─────────────────────────────────────────────────

  group('Bouquet == / hashCode', () {
    final now = DateTime(2026, 4, 3);

    test('같은 id → 동등', () {
      final a = Bouquet(
        id: 'same-id',
        fromNodeId: 'n1',
        toNodeId: 'n2',
        flowerType: FlowerType.sparkleHeart,
        date: now,
        createdAt: now,
      );
      final b = Bouquet(
        id: 'same-id',
        fromNodeId: 'n3',
        toNodeId: 'n4',
        flowerType: FlowerType.fireHeart,
        date: now,
        createdAt: now,
      );
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('다른 id → 불동등', () {
      final a = Bouquet(
        id: 'id-a',
        fromNodeId: 'n1',
        toNodeId: 'n2',
        flowerType: FlowerType.sparkleHeart,
        date: now,
        createdAt: now,
      );
      final b = Bouquet(
        id: 'id-b',
        fromNodeId: 'n1',
        toNodeId: 'n2',
        flowerType: FlowerType.sparkleHeart,
        date: now,
        createdAt: now,
      );
      expect(a, isNot(equals(b)));
    });

    test('Set에서 id 기반 중복 제거', () {
      final set = <Bouquet>{
        Bouquet(id: 'b1', fromNodeId: 'n1', toNodeId: 'n2', flowerType: FlowerType.sparkleHeart, date: now, createdAt: now),
        Bouquet(id: 'b1', fromNodeId: 'n3', toNodeId: 'n4', flowerType: FlowerType.fireHeart, date: now, createdAt: now),
        Bouquet(id: 'b2', fromNodeId: 'n1', toNodeId: 'n2', flowerType: FlowerType.star, date: now, createdAt: now),
      };
      expect(set.length, 2);
    });
  });
}
