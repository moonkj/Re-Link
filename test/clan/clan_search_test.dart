import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/features/clan/models/clan_data.dart';

/// JSON에서 성씨 목록 로드 (테스트 환경: rootBundle 대신 dart:io)
List<ClanSurname> _loadClans() {
  final file = File('assets/data/korean_clans.json');
  final jsonStr = file.readAsStringSync();
  final list = jsonDecode(jsonStr) as List<dynamic>;
  return list
      .map((e) => ClanSurname.fromJson(e as Map<String, dynamic>))
      .toList();
}

/// ClanExplorerNotifier.search 로직을 순수 함수로 재현
List<ClanSurname> _search(List<ClanSurname> allClans, String query) {
  if (query.isEmpty) return allClans;
  final q = query.toLowerCase();
  return allClans.where((s) {
    if (s.surname.contains(query)) return true;
    if (s.romanized.toLowerCase().contains(q)) return true;
    if (s.clans.any((c) => c.origin.contains(query))) return true;
    if (s.clans.any((c) => c.founder.contains(query))) return true;
    if (s.clans.any(
        (c) => c.famousPeople.any((p) => p.contains(query)))) return true;
    return false;
  }).toList();
}

void main() {
  late List<ClanSurname> allClans;

  setUpAll(() {
    allClans = _loadClans();
  });

  group('JSON 데이터 파싱 검증', () {
    test('JSON 파일이 비어있지 않다', () {
      expect(allClans, isNotEmpty);
    });

    test('모든 항목에 surname, romanized, clans가 있다', () {
      for (final clan in allClans) {
        expect(clan.surname, isNotEmpty,
            reason: '${clan.romanized} surname이 비어있음');
        expect(clan.romanized, isNotEmpty,
            reason: '${clan.surname} romanized가 비어있음');
        expect(clan.clans, isNotEmpty,
            reason: '${clan.surname} clans가 비어있음');
      }
    });

    test('모든 본관에 origin, founder, description이 있다', () {
      for (final surname in allClans) {
        for (final clan in surname.clans) {
          expect(clan.origin, isNotEmpty,
              reason: '${surname.surname} 본관 origin이 비어있음');
          expect(clan.founder, isNotEmpty,
              reason: '${surname.surname} 본관 founder가 비어있음');
          expect(clan.description, isNotEmpty,
              reason: '${surname.surname} 본관 description이 비어있음');
        }
      }
    });

    test('famousPeople 리스트가 null이 아니다', () {
      for (final surname in allClans) {
        for (final clan in surname.clans) {
          expect(clan.famousPeople, isA<List<String>>());
        }
      }
    });

    test('복성(2글자 이상) 성씨가 포함되어 있다', () {
      final multiCharSurnames =
          allClans.where((s) => s.surname.length >= 2).toList();
      expect(multiCharSurnames, isNotEmpty);
      final names = multiCharSurnames.map((s) => s.surname).toList();
      expect(names, contains('제갈'));
    });
  });

  group('성씨 검색 (한글)', () {
    test('"김" 검색 → 김해 김씨 등 포함', () {
      final results = _search(allClans, '김');
      expect(results, isNotEmpty);
      expect(results.first.surname, '김');
      // 김해 본관이 포함되어야 한다
      final kimClans = results.first.clans.map((c) => c.origin).toList();
      expect(kimClans, contains('김해'));
    });

    test('"이" 검색 → 이씨 포함', () {
      final results = _search(allClans, '이');
      expect(results, isNotEmpty);
      final surnames = results.map((s) => s.surname).toList();
      expect(surnames, contains('이'));
    });

    test('"박" 검색 → 밀양 박씨 포함', () {
      final results = _search(allClans, '박');
      expect(results, isNotEmpty);
      final park = results.firstWhere((s) => s.surname == '박');
      final origins = park.clans.map((c) => c.origin).toList();
      expect(origins, contains('밀양'));
    });
  });

  group('로마자 검색', () {
    test('"Kim" 검색 → 김씨 포함', () {
      final results = _search(allClans, 'Kim');
      expect(results, isNotEmpty);
      final surnames = results.map((s) => s.surname).toList();
      expect(surnames, contains('김'));
    });

    test('"kim" 소문자 검색 → 김씨 포함 (대소문자 무시)', () {
      final results = _search(allClans, 'kim');
      expect(results, isNotEmpty);
      final surnames = results.map((s) => s.surname).toList();
      expect(surnames, contains('김'));
    });

    test('"Park" 검색 → 박씨 포함', () {
      final results = _search(allClans, 'Park');
      expect(results, isNotEmpty);
      final surnames = results.map((s) => s.surname).toList();
      expect(surnames, contains('박'));
    });

    test('"Choi" 검색 → 최씨 포함', () {
      final results = _search(allClans, 'Choi');
      expect(results, isNotEmpty);
      final surnames = results.map((s) => s.surname).toList();
      expect(surnames, contains('최'));
    });
  });

  group('본관 검색', () {
    test('"김해" 검색 → 김씨 포함', () {
      final results = _search(allClans, '김해');
      expect(results, isNotEmpty);
      final surnames = results.map((s) => s.surname).toList();
      expect(surnames, contains('김'));
    });

    test('"전주" 검색 → 이씨/최씨 포함', () {
      final results = _search(allClans, '전주');
      expect(results, isNotEmpty);
      final surnames = results.map((s) => s.surname).toList();
      expect(surnames, contains('이'));
      expect(surnames, contains('최'));
    });

    test('"경주" 검색 → 김/이/최/정 중 하나 이상 포함', () {
      final results = _search(allClans, '경주');
      expect(results.length, greaterThanOrEqualTo(2));
    });
  });

  group('시조 검색', () {
    test('"김수로왕" 검색 → 김씨 포함', () {
      final results = _search(allClans, '김수로왕');
      expect(results, isNotEmpty);
      expect(results.first.surname, '김');
    });

    test('"박혁거세" 검색 → 박씨 포함', () {
      final results = _search(allClans, '박혁거세');
      expect(results, isNotEmpty);
      final surnames = results.map((s) => s.surname).toList();
      expect(surnames, contains('박'));
    });
  });

  group('빈 쿼리 / 존재하지 않는 검색어', () {
    test('빈 쿼리 → 전체 목록 반환', () {
      final results = _search(allClans, '');
      expect(results.length, allClans.length);
    });

    test('존재하지 않는 검색어 → 빈 결과', () {
      final results = _search(allClans, 'ZZZZNOTEXIST');
      expect(results, isEmpty);
    });

    test('특수문자 검색 → 빈 결과', () {
      final results = _search(allClans, '@#\$%');
      expect(results, isEmpty);
    });
  });

  group('ClanInfo 모델 검증', () {
    test('populationFormatted — 만 단위', () {
      const info = ClanInfo(
        origin: '김해',
        founder: '김수로왕',
        foundedYear: 42,
        population: 4456700,
        famousPeople: [],
        description: '',
      );
      expect(info.populationFormatted, contains('만명'));
    });

    test('populationFormatted — 천 단위', () {
      const info = ClanInfo(
        origin: '낭야',
        founder: '제갈공명',
        population: 8853,
        famousPeople: [],
        description: '',
      );
      final formatted = info.populationFormatted;
      expect(formatted, startsWith('약 '));
      expect(formatted, endsWith('명'));
    });

    test('populationFormatted — null', () {
      const info = ClanInfo(
        origin: '테스트',
        founder: '테스트',
        population: null,
        famousPeople: [],
        description: '',
      );
      expect(info.populationFormatted, '인구 미상');
    });

    test('foundedYearFormatted — 양수', () {
      const info = ClanInfo(
        origin: '김해',
        founder: '김수로왕',
        foundedYear: 42,
        famousPeople: [],
        description: '',
      );
      expect(info.foundedYearFormatted, '42년');
    });

    test('foundedYearFormatted — 음수 (기원전)', () {
      const info = ClanInfo(
        origin: '밀양',
        founder: '박혁거세',
        foundedYear: -57,
        famousPeople: [],
        description: '',
      );
      expect(info.foundedYearFormatted, '기원전 57년');
    });

    test('foundedYearFormatted — null', () {
      const info = ClanInfo(
        origin: '테스트',
        founder: '테스트',
        foundedYear: null,
        famousPeople: [],
        description: '',
      );
      expect(info.foundedYearFormatted, isNull);
    });
  });
}
