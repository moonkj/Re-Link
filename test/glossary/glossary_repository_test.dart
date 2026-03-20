import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/core/database/app_database.dart';

void main() {
  group('GlossaryTableData creation', () {
    test('required fields are set correctly', () {
      final entry = GlossaryTableData(
        id: 'gl-001',
        word: '한입만',
        meaning: '전부 다 먹겠다는 뜻',
        createdAt: DateTime(2026, 3, 21),
      );

      expect(entry.id, 'gl-001');
      expect(entry.word, '한입만');
      expect(entry.meaning, '전부 다 먹겠다는 뜻');
      expect(entry.createdAt, DateTime(2026, 3, 21));
    });

    test('nullable fields default to null', () {
      final entry = GlossaryTableData(
        id: 'gl-002',
        word: '테스트',
        meaning: '테스트 뜻',
        createdAt: DateTime(2026, 3, 21),
      );

      expect(entry.example, isNull);
      expect(entry.voicePath, isNull);
      expect(entry.nodeId, isNull);
    });

    test('all optional fields can be set', () {
      final entry = GlossaryTableData(
        id: 'gl-003',
        word: '쪼꼼만',
        meaning: '아주 조금',
        example: '"쪼꼼만 줘" — 할머니가 과자 줄 때',
        voicePath: '/audio/grandma_jjokkoman.m4a',
        nodeId: 'node-grandma',
        createdAt: DateTime(2026, 3, 21),
      );

      expect(entry.example, '"쪼꼼만 줘" — 할머니가 과자 줄 때');
      expect(entry.voicePath, '/audio/grandma_jjokkoman.m4a');
      expect(entry.nodeId, 'node-grandma');
    });
  });

  group('GlossaryTableData voicePath nullable handling', () {
    test('entry without voicePath has null voicePath', () {
      final entry = GlossaryTableData(
        id: 'gl-no-voice',
        word: '밥 먹었니',
        meaning: '안녕하세요의 가족 버전',
        createdAt: DateTime(2026, 3, 21),
      );

      expect(entry.voicePath, isNull);
    });

    test('entry with voicePath has non-null voicePath', () {
      final entry = GlossaryTableData(
        id: 'gl-with-voice',
        word: '밥 먹었니',
        meaning: '안녕하세요의 가족 버전',
        voicePath: '/audio/bab.m4a',
        createdAt: DateTime(2026, 3, 21),
      );

      expect(entry.voicePath, isNotNull);
      expect(entry.voicePath, '/audio/bab.m4a');
    });

    test('copyWith can set voicePath from null to value', () {
      final entry = GlossaryTableData(
        id: 'gl-voice-add',
        word: '테스트',
        meaning: '뜻',
        createdAt: DateTime(2026, 3, 21),
      );

      expect(entry.voicePath, isNull);

      final withVoice =
          entry.copyWith(voicePath: const Value('/audio/test.m4a'));
      expect(withVoice.voicePath, '/audio/test.m4a');
    });

    test('copyWith can set voicePath from value to null', () {
      final entry = GlossaryTableData(
        id: 'gl-voice-remove',
        word: '테스트',
        meaning: '뜻',
        voicePath: '/audio/old.m4a',
        createdAt: DateTime(2026, 3, 21),
      );

      final noVoice = entry.copyWith(voicePath: const Value(null));
      expect(noVoice.voicePath, isNull);
    });
  });

  group('GlossaryTableData search logic (word/meaning matching)', () {
    final entries = [
      GlossaryTableData(
        id: 'gl-s1',
        word: '한입만',
        meaning: '전부 다 먹겠다는 뜻',
        createdAt: DateTime(2026, 1, 1),
      ),
      GlossaryTableData(
        id: 'gl-s2',
        word: '쪼꼼만',
        meaning: '아주 조금이라는 뜻',
        createdAt: DateTime(2026, 1, 2),
      ),
      GlossaryTableData(
        id: 'gl-s3',
        word: '밥 먹었니',
        meaning: '안부 인사 (밥은 중요)',
        createdAt: DateTime(2026, 1, 3),
      ),
      GlossaryTableData(
        id: 'gl-s4',
        word: '우리 막내',
        meaning: '가족 중 가장 어린 사람',
        createdAt: DateTime(2026, 1, 4),
      ),
    ];

    /// DB의 LIKE '%query%' 검색을 순수 Dart로 재현
    List<GlossaryTableData> searchLocal(
        List<GlossaryTableData> list, String query) {
      final q = query.toLowerCase();
      return list
          .where((e) =>
              e.word.toLowerCase().contains(q) ||
              e.meaning.toLowerCase().contains(q))
          .toList();
    }

    test('search by exact word match', () {
      final results = searchLocal(entries, '한입만');
      expect(results.length, 1);
      expect(results.first.id, 'gl-s1');
    });

    test('search by partial word match', () {
      final results = searchLocal(entries, '만');
      // '한입만', '쪼꼼만' 두 개 매칭
      expect(results.length, 2);
      expect(results.map((e) => e.id), containsAll(['gl-s1', 'gl-s2']));
    });

    test('search by meaning match', () {
      final results = searchLocal(entries, '밥은 중요');
      expect(results.length, 1);
      expect(results.first.id, 'gl-s3');
    });

    test('search by partial meaning match', () {
      final results = searchLocal(entries, '뜻');
      // '전부 다 먹겠다는 뜻', '아주 조금이라는 뜻' 두 개 매칭
      expect(results.length, 2);
    });

    test('search with no match returns empty', () {
      final results = searchLocal(entries, '존재하지않는단어');
      expect(results, isEmpty);
    });

    test('search is case-insensitive for Korean', () {
      // Korean does not have case, but verify the logic handles it
      final results = searchLocal(entries, '밥');
      expect(results.length, 1);
      expect(results.first.word, '밥 먹었니');
    });

    test('search matches across word and meaning simultaneously', () {
      // '가족' appears in meaning of gl-s4
      final results = searchLocal(entries, '가족');
      expect(results.length, 1);
      expect(results.first.id, 'gl-s4');
    });
  });

  group('GlossaryTableData sorting (가나다 순)', () {
    test('entries sort by word ascending (가나다순)', () {
      final entries = [
        GlossaryTableData(
          id: 'gl-3',
          word: '하하',
          meaning: '웃음',
          createdAt: DateTime(2026, 1, 1),
        ),
        GlossaryTableData(
          id: 'gl-1',
          word: '가나다',
          meaning: '기본',
          createdAt: DateTime(2026, 1, 2),
        ),
        GlossaryTableData(
          id: 'gl-2',
          word: '다라마',
          meaning: '중간',
          createdAt: DateTime(2026, 1, 3),
        ),
      ];

      entries.sort((a, b) => a.word.compareTo(b.word));

      expect(entries[0].word, '가나다');
      expect(entries[1].word, '다라마');
      expect(entries[2].word, '하하');
    });

    test('entries with same starting character sort correctly', () {
      final entries = [
        GlossaryTableData(
          id: 'gl-a2',
          word: '가을',
          meaning: '계절',
          createdAt: DateTime(2026, 1, 1),
        ),
        GlossaryTableData(
          id: 'gl-a1',
          word: '가방',
          meaning: '물건',
          createdAt: DateTime(2026, 1, 2),
        ),
        GlossaryTableData(
          id: 'gl-a3',
          word: '가족',
          meaning: '핵심',
          createdAt: DateTime(2026, 1, 3),
        ),
      ];

      entries.sort((a, b) => a.word.compareTo(b.word));

      expect(entries[0].word, '가방');
      expect(entries[1].word, '가을');
      expect(entries[2].word, '가족');
    });

    test('empty list sorts without error', () {
      final entries = <GlossaryTableData>[];
      entries.sort((a, b) => a.word.compareTo(b.word));
      expect(entries, isEmpty);
    });

    test('single entry list sorts without error', () {
      final entries = [
        GlossaryTableData(
          id: 'gl-solo',
          word: '단독',
          meaning: '혼자',
          createdAt: DateTime(2026, 1, 1),
        ),
      ];

      entries.sort((a, b) => a.word.compareTo(b.word));
      expect(entries.length, 1);
      expect(entries.first.word, '단독');
    });
  });

  group('GlossaryTableData copyWith', () {
    final original = GlossaryTableData(
      id: 'gl-copy',
      word: '원본',
      meaning: '원래 뜻',
      example: '원본 예시',
      voicePath: '/audio/original.m4a',
      nodeId: 'node-1',
      createdAt: DateTime(2026, 3, 21),
    );

    test('copyWith preserves all fields when not overridden', () {
      final copy = original.copyWith();

      expect(copy.id, original.id);
      expect(copy.word, original.word);
      expect(copy.meaning, original.meaning);
      expect(copy.example, original.example);
      expect(copy.voicePath, original.voicePath);
      expect(copy.nodeId, original.nodeId);
      expect(copy.createdAt, original.createdAt);
    });

    test('copyWith changes word and meaning', () {
      final updated = original.copyWith(word: '수정', meaning: '바뀐 뜻');

      expect(updated.word, '수정');
      expect(updated.meaning, '바뀐 뜻');
      expect(updated.id, original.id);
      expect(updated.example, original.example);
    });
  });

  group('GlossaryTableData JSON serialization', () {
    test('toJson produces correct keys', () {
      final entry = GlossaryTableData(
        id: 'gl-json',
        word: 'JSON 단어',
        meaning: 'JSON 뜻',
        createdAt: DateTime(2026, 3, 21),
      );

      final json = entry.toJson();
      expect(json.containsKey('id'), true);
      expect(json.containsKey('word'), true);
      expect(json.containsKey('meaning'), true);
      expect(json.containsKey('example'), true);
      expect(json.containsKey('voicePath'), true);
      expect(json.containsKey('nodeId'), true);
      expect(json.containsKey('createdAt'), true);
    });

    test('toJson round-trips via fromJson', () {
      final original = GlossaryTableData(
        id: 'gl-rt',
        word: '왕복',
        meaning: '왕복 뜻',
        example: '예시',
        voicePath: '/audio/rt.m4a',
        nodeId: 'node-rt',
        createdAt: DateTime(2026, 3, 21),
      );

      final json = original.toJson();
      final restored = GlossaryTableData.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.word, original.word);
      expect(restored.meaning, original.meaning);
      expect(restored.example, original.example);
      expect(restored.voicePath, original.voicePath);
      expect(restored.nodeId, original.nodeId);
      expect(restored.createdAt, original.createdAt);
    });

    test('fromJson handles all nullable fields as null', () {
      final json = {
        'id': 'gl-all-null',
        'word': '널',
        'meaning': '전부 널',
        'example': null,
        'voicePath': null,
        'nodeId': null,
        'createdAt': DateTime(2026, 3, 21).toIso8601String(),
      };

      final entry = GlossaryTableData.fromJson(json);
      expect(entry.example, isNull);
      expect(entry.voicePath, isNull);
      expect(entry.nodeId, isNull);
    });
  });

  group('GlossaryTableData equality', () {
    test('two entries with same fields are equal', () {
      final a = GlossaryTableData(
        id: 'gl-eq',
        word: '동일',
        meaning: '같은',
        createdAt: DateTime(2026, 3, 21),
      );
      final b = GlossaryTableData(
        id: 'gl-eq',
        word: '동일',
        meaning: '같은',
        createdAt: DateTime(2026, 3, 21),
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('two entries with different ids are not equal', () {
      final a = GlossaryTableData(
        id: 'gl-a',
        word: '동일',
        meaning: '같은',
        createdAt: DateTime(2026, 3, 21),
      );
      final b = GlossaryTableData(
        id: 'gl-b',
        word: '동일',
        meaning: '같은',
        createdAt: DateTime(2026, 3, 21),
      );

      expect(a, isNot(equals(b)));
    });
  });
}
