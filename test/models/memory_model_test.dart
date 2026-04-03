/// MemoryModel / MemoryType 단위 테스트
/// 커버: memory_model.dart — MemoryType.label, formattedDuration, copyWith, ==
import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/shared/models/memory_model.dart';

final _epoch = DateTime.utc(2024);

void main() {
  // ── MemoryType ─────────────────────────────────────────────────────────────

  group('MemoryType.label', () {
    test('photo → "사진"', () => expect(MemoryType.photo.label, '사진'));
    test('voice → "음성"', () => expect(MemoryType.voice.label, '음성'));
    test('note → "메모"', () => expect(MemoryType.note.label, '메모'));
    test('4가지 값 존재', () => expect(MemoryType.values.length, 4));
  });

  // ── MemoryModel.formattedDuration ─────────────────────────────────────────

  group('MemoryModel.formattedDuration', () {
    test('durationSeconds=null → null 반환', () {
      final m = MemoryModel(id: 'm1', nodeId: 'n1', type: MemoryType.voice, createdAt: _epoch);
      expect(m.formattedDuration, isNull);
    });

    test('durationSeconds=0 → "00:00"', () {
      final m = MemoryModel(
        id: 'm1', nodeId: 'n1', type: MemoryType.voice,
        durationSeconds: 0, createdAt: _epoch,
      );
      expect(m.formattedDuration, '00:00');
    });

    test('durationSeconds=65 → "01:05"', () {
      final m = MemoryModel(
        id: 'm1', nodeId: 'n1', type: MemoryType.voice,
        durationSeconds: 65, createdAt: _epoch,
      );
      expect(m.formattedDuration, '01:05');
    });

    test('durationSeconds=3600 → "60:00"', () {
      final m = MemoryModel(
        id: 'm1', nodeId: 'n1', type: MemoryType.voice,
        durationSeconds: 3600, createdAt: _epoch,
      );
      expect(m.formattedDuration, '60:00');
    });

    test('durationSeconds=9 → "00:09"', () {
      final m = MemoryModel(
        id: 'm1', nodeId: 'n1', type: MemoryType.voice,
        durationSeconds: 9, createdAt: _epoch,
      );
      expect(m.formattedDuration, '00:09');
    });
  });

  // ── MemoryModel.copyWith ──────────────────────────────────────────────────

  group('MemoryModel copyWith', () {
    late MemoryModel base;
    setUp(() {
      base = MemoryModel(
        id: 'm1', nodeId: 'n1', type: MemoryType.note, createdAt: _epoch,
      );
    });

    test('type 변경', () {
      expect(base.copyWith(type: MemoryType.photo).type, MemoryType.photo);
    });

    test('title 변경', () {
      expect(base.copyWith(title: '여름 사진').title, '여름 사진');
    });

    test('description 변경', () {
      expect(base.copyWith(description: '일기').description, '일기');
    });

    test('isPrivate 변경', () {
      expect(base.copyWith(isPrivate: true).isPrivate, isTrue);
    });

    test('tags 변경', () {
      final m = base.copyWith(tags: ['가족']);
      expect(m.tags, ['가족']);
    });

    test('filePath + thumbnailPath 변경', () {
      final m = base.copyWith(
        filePath: '/img/photo.jpg',
        thumbnailPath: '/img/thumb.jpg',
      );
      expect(m.filePath, '/img/photo.jpg');
      expect(m.thumbnailPath, '/img/thumb.jpg');
    });

    test('durationSeconds + dateTaken 변경', () {
      final dt = DateTime(2024, 6, 1);
      final m = base.copyWith(durationSeconds: 120, dateTaken: dt);
      expect(m.durationSeconds, 120);
      expect(m.dateTaken, dt);
    });

    test('변경 없으면 원래 값 유지', () {
      final m = base.copyWith();
      expect(m.id, base.id);
      expect(m.nodeId, base.nodeId);
      expect(m.type, base.type);
    });
  });

  // ── MemoryModel == / hashCode ─────────────────────────────────────────────

  group('MemoryModel == / hashCode', () {
    test('같은 id → 동등', () {
      final a = MemoryModel(id: 'm1', nodeId: 'n1', type: MemoryType.photo, createdAt: _epoch);
      final b = MemoryModel(id: 'm1', nodeId: 'n2', type: MemoryType.note, createdAt: _epoch);
      expect(a, equals(b));
    });

    test('다른 id → 불동등', () {
      final a = MemoryModel(id: 'm1', nodeId: 'n1', type: MemoryType.photo, createdAt: _epoch);
      final b = MemoryModel(id: 'm2', nodeId: 'n1', type: MemoryType.photo, createdAt: _epoch);
      expect(a, isNot(equals(b)));
    });

    test('hashCode는 id 기반', () {
      final m = MemoryModel(id: 'm1', nodeId: 'n1', type: MemoryType.note, createdAt: _epoch);
      expect(m.hashCode, 'm1'.hashCode);
    });
  });

  // ── MemoryModel 기본값 ────────────────────────────────────────────────────

  group('MemoryModel 기본값', () {
    test('isPrivate 기본 false', () {
      final m = MemoryModel(id: 'm1', nodeId: 'n1', type: MemoryType.note, createdAt: _epoch);
      expect(m.isPrivate, isFalse);
    });

    test('tags 기본 빈 리스트', () {
      final m = MemoryModel(id: 'm1', nodeId: 'n1', type: MemoryType.note, createdAt: _epoch);
      expect(m.tags, isEmpty);
    });

    test('filePath/thumbnailPath/title/description null 허용', () {
      final m = MemoryModel(id: 'm1', nodeId: 'n1', type: MemoryType.note, createdAt: _epoch);
      expect(m.filePath, isNull);
      expect(m.thumbnailPath, isNull);
      expect(m.title, isNull);
      expect(m.description, isNull);
    });
  });
}
