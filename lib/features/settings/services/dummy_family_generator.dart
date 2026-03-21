import 'dart:math';

import '../../../shared/models/node_model.dart';

/// 더미 가족 트리 데이터
class DummyNodeData {
  const DummyNodeData({
    required this.name,
    this.nickname,
    this.bio,
    this.birthDate,
    this.deathDate,
    required this.isGhost,
    required this.temperature,
    required this.positionX,
    required this.positionY,
    this.tags = const ['__ADMIN_DUMMY__'],
  });

  final String name;
  final String? nickname;
  final String? bio;
  final DateTime? birthDate;
  final DateTime? deathDate;
  final bool isGhost;
  final int temperature;
  final double positionX;
  final double positionY;
  final List<String> tags;
}

class DummyEdgeData {
  const DummyEdgeData({
    required this.fromIndex,
    required this.toIndex,
    required this.relation,
  });

  final int fromIndex;
  final int toIndex;
  final RelationType relation;
}

/// 50개 한국 가족 노드 + 관계 생성기
class DummyFamilyGenerator {
  DummyFamilyGenerator() : _rng = Random(42); // deterministic seed

  final Random _rng;
  final Set<String> _usedNames = {};

  // ── 이름 풀 ─────────────────────────────────────────────────────────────

  static const _surnames = [
    '김', '이', '박', '최', '정', '강', '조', '윤', '장', '임',
    '한', '신', '오', '배', '송', '홍', '문', '민', '류', '성',
  ];

  static const _maleNamesOld = [
    '영만', '태수', '성일', '충호', '재형', '일선', '만복', '기철',
    '영석', '태호', '정수', '영호', '상철', '동수', '순길', '명호',
    '광호', '병수', '용식', '종철', '원태', '덕수', '창호', '인수',
    '봉수', '석환', '진호', '갑수', '경호', '규태',
  ];

  static const _femaleNamesOld = [
    '영희', '순자', '옥분', '정자', '미자', '영자', '춘자', '말순',
    '복순', '귀순', '순옥', '정순', '길자', '말자', '봉자', '분옥',
    '옥자', '점순', '금자', '덕순', '계순', '향자', '연순', '막례',
    '순이', '임순', '정옥', '갑순', '용순', '석순',
  ];

  static const _maleNamesMid = [
    '준호', '성민', '지훈', '현우', '대호', '상현', '진수', '영진',
    '민수', '정환', '태영', '기현', '동훈', '승우', '재민', '형석',
    '용현', '세준', '광수', '진혁', '병철', '창민', '상우', '도현',
    '한솔', '우진', '종민', '승호', '경수', '시영',
  ];

  static const _femaleNamesMid = [
    '은지', '지영', '미영', '수진', '은영', '정현', '혜진', '유미',
    '소영', '다영', '미진', '선영', '현정', '혜영', '보미', '지혜',
    '은선', '가영', '주희', '세영', '경아', '수경', '미정', '정은',
    '영미', '순희', '유정', '은미', '세희', '정아',
  ];

  static const _maleNamesYoung = [
    '시우', '하준', '도윤', '서준', '주원', '지호', '예준', '건우',
    '현준', '민규', '유준', '준서', '연우', '지안', '승현', '태윤',
    '이준', '은우', '도현', '시윤', '이안', '윤호', '선우', '정우',
    '지율', '하율', '수호', '준혁', '민찬', '서진',
  ];

  static const _femaleNamesYoung = [
    '서윤', '서연', '지우', '하은', '수아', '하린', '지아', '채원',
    '예은', '소율', '리안', '유나', '민서', '하윤', '윤서', '다은',
    '이서', '소은', '채은', '시은', '지유', '예린', '수빈', '나은',
    '아린', '소희', '하영', '서현', '예원', '지민',
  ];

  // ── 생성 ────────────────────────────────────────────────────────────────

  ({List<DummyNodeData> nodes, List<DummyEdgeData> edges}) generate() {
    final familySurname = _surnames[_rng.nextInt(_surnames.length)];
    final nodes = <DummyNodeData>[];
    final edges = <DummyEdgeData>[];

    // 가족 트리 레이아웃 (세대별 Y좌표)
    const gen1Y = -600.0; // 증조부모
    const gen2Y = -300.0; // 조부모
    const gen3Y = 0.0;    // 부모
    const gen4Y = 300.0;  // 나 + 형제
    const gen5Y = 600.0;  // 자녀

    // ── 1세대: 증조부모 (4명, Ghost) ──────────────────────────────────

    // 친가 증조부모
    nodes.add(_node(familySurname, _maleNamesOld, '증조할아버지',
        1920, 1925, true, gen1Y, -200, deceased: true, deadYear: (1990, 2000)));
    nodes.add(_node(familySurname, _femaleNamesOld, '증조할머니',
        1922, 1928, true, gen1Y, 0, deceased: true, deadYear: (1995, 2005)));
    edges.add(DummyEdgeData(fromIndex: 0, toIndex: 1, relation: RelationType.spouse));

    // 외가 증조부모
    final extSurname = _surnames[(_rng.nextInt(_surnames.length - 1) + 1) % _surnames.length];
    nodes.add(_node(extSurname, _maleNamesOld, '외증조할아버지',
        1918, 1924, true, gen1Y, 400, deceased: true, deadYear: (1988, 1998)));
    nodes.add(_node(extSurname, _femaleNamesOld, '외증조할머니',
        1920, 1926, true, gen1Y, 600, deceased: true, deadYear: (1993, 2003)));
    edges.add(DummyEdgeData(fromIndex: 2, toIndex: 3, relation: RelationType.spouse));

    // ── 2세대: 조부모 (6명) ──────────────────────────────────────────

    // 친조부모
    nodes.add(_node(familySurname, _maleNamesOld, '할아버지',
        1942, 1948, false, gen2Y, -200, temp: 3, deceased: true, deadYear: (2015, 2020)));
    nodes.add(_node(_randomSurname(), _femaleNamesOld, '할머니',
        1945, 1950, false, gen2Y, 0, temp: 4));
    edges.add(DummyEdgeData(fromIndex: 4, toIndex: 5, relation: RelationType.spouse));
    // 증조→조부 연결
    edges.add(DummyEdgeData(fromIndex: 0, toIndex: 4, relation: RelationType.child));
    edges.add(DummyEdgeData(fromIndex: 1, toIndex: 4, relation: RelationType.child));

    // 외조부모
    nodes.add(_node(extSurname, _maleNamesOld, '외할아버지',
        1940, 1946, false, gen2Y, 400, temp: 3));
    nodes.add(_node(_randomSurname(), _femaleNamesOld, '외할머니',
        1943, 1948, false, gen2Y, 600, temp: 4));
    edges.add(DummyEdgeData(fromIndex: 6, toIndex: 7, relation: RelationType.spouse));
    edges.add(DummyEdgeData(fromIndex: 2, toIndex: 6, relation: RelationType.child));
    edges.add(DummyEdgeData(fromIndex: 3, toIndex: 6, relation: RelationType.child));

    // 큰할아버지 (친조부 형) + 배우자
    nodes.add(_node(familySurname, _maleNamesOld, '큰할아버지',
        1940, 1945, false, gen2Y, -500, temp: 2, deceased: true, deadYear: (2010, 2018)));
    nodes.add(_node(_randomSurname(), _femaleNamesOld, '큰할머니',
        1942, 1947, false, gen2Y, -700, temp: 2));
    edges.add(DummyEdgeData(fromIndex: 8, toIndex: 9, relation: RelationType.spouse));
    edges.add(DummyEdgeData(fromIndex: 4, toIndex: 8, relation: RelationType.sibling));

    // ── 3세대: 부모 + 삼촌/고모 (12명) ──────────────────────────────────

    // 아버지
    nodes.add(_node(familySurname, _maleNamesMid, '아버지',
        1968, 1973, false, gen3Y, -100, temp: 5)); // idx 10
    // 어머니
    nodes.add(_node(extSurname, _femaleNamesMid, '어머니',
        1970, 1975, false, gen3Y, 100, temp: 5)); // idx 11
    edges.add(DummyEdgeData(fromIndex: 10, toIndex: 11, relation: RelationType.spouse));
    // 조부모→아버지
    edges.add(DummyEdgeData(fromIndex: 4, toIndex: 10, relation: RelationType.child));
    edges.add(DummyEdgeData(fromIndex: 5, toIndex: 10, relation: RelationType.child));
    // 외조부모→어머니
    edges.add(DummyEdgeData(fromIndex: 6, toIndex: 11, relation: RelationType.child));
    edges.add(DummyEdgeData(fromIndex: 7, toIndex: 11, relation: RelationType.child));

    // 큰아버지 (아버지 형)
    nodes.add(_node(familySurname, _maleNamesMid, '큰아버지',
        1965, 1970, false, gen3Y, -400, temp: 3)); // idx 12
    nodes.add(_node(_randomSurname(), _femaleNamesMid, '큰어머니',
        1967, 1972, false, gen3Y, -600, temp: 2)); // idx 13
    edges.add(DummyEdgeData(fromIndex: 12, toIndex: 13, relation: RelationType.spouse));
    edges.add(DummyEdgeData(fromIndex: 10, toIndex: 12, relation: RelationType.sibling));
    edges.add(DummyEdgeData(fromIndex: 4, toIndex: 12, relation: RelationType.child));

    // 작은아버지 (아버지 동생)
    nodes.add(_node(familySurname, _maleNamesMid, '작은아버지',
        1972, 1977, false, gen3Y, -800, temp: 2)); // idx 14
    nodes.add(_node(_randomSurname(), _femaleNamesMid, '작은어머니',
        1974, 1979, false, gen3Y, -1000, temp: 1)); // idx 15
    edges.add(DummyEdgeData(fromIndex: 14, toIndex: 15, relation: RelationType.spouse));
    edges.add(DummyEdgeData(fromIndex: 10, toIndex: 14, relation: RelationType.sibling));
    edges.add(DummyEdgeData(fromIndex: 4, toIndex: 14, relation: RelationType.child));

    // 고모
    nodes.add(_node(familySurname, _femaleNamesMid, '고모',
        1970, 1975, false, gen3Y, 400, temp: 3)); // idx 16
    nodes.add(_node(_randomSurname(), _maleNamesMid, '고모부',
        1968, 1973, false, gen3Y, 600, temp: 2)); // idx 17
    edges.add(DummyEdgeData(fromIndex: 16, toIndex: 17, relation: RelationType.spouse));
    edges.add(DummyEdgeData(fromIndex: 10, toIndex: 16, relation: RelationType.sibling));
    edges.add(DummyEdgeData(fromIndex: 4, toIndex: 16, relation: RelationType.child));

    // 이모
    nodes.add(_node(extSurname, _femaleNamesMid, '이모',
        1973, 1978, false, gen3Y, 800, temp: 3)); // idx 18
    nodes.add(_node(_randomSurname(), _maleNamesMid, '이모부',
        1971, 1976, true, gen3Y, 1000, temp: 0)); // idx 19 (Ghost)
    edges.add(DummyEdgeData(fromIndex: 18, toIndex: 19, relation: RelationType.spouse));
    edges.add(DummyEdgeData(fromIndex: 11, toIndex: 18, relation: RelationType.sibling));
    edges.add(DummyEdgeData(fromIndex: 6, toIndex: 18, relation: RelationType.child));

    // 큰할아버지 아들 (사촌 아버지)
    nodes.add(_node(familySurname, _maleNamesMid, '큰아버지 아들',
        1966, 1971, false, gen3Y, -1200, temp: 1)); // idx 20
    edges.add(DummyEdgeData(fromIndex: 8, toIndex: 20, relation: RelationType.child));

    // ── 4세대: 나 + 형제 + 사촌 (16명) ──────────────────────────────────

    // 나 (idx 21)
    nodes.add(_node(familySurname, _maleNamesYoung, '나',
        1995, 2000, false, gen4Y, 0, temp: 5));
    edges.add(DummyEdgeData(fromIndex: 10, toIndex: 21, relation: RelationType.child));
    edges.add(DummyEdgeData(fromIndex: 11, toIndex: 21, relation: RelationType.child));

    // 배우자 (idx 22)
    nodes.add(_node(_randomSurname(), _femaleNamesYoung, '배우자',
        1997, 2001, false, gen4Y, 200, temp: 5));
    edges.add(DummyEdgeData(fromIndex: 21, toIndex: 22, relation: RelationType.spouse));

    // 형 (idx 23)
    nodes.add(_node(familySurname, _maleNamesMid, '형',
        1993, 1997, false, gen4Y, -300, temp: 4));
    edges.add(DummyEdgeData(fromIndex: 21, toIndex: 23, relation: RelationType.sibling));
    edges.add(DummyEdgeData(fromIndex: 10, toIndex: 23, relation: RelationType.child));

    // 형수 (idx 24)
    nodes.add(_node(_randomSurname(), _femaleNamesMid, '형수',
        1994, 1998, false, gen4Y, -500, temp: 3));
    edges.add(DummyEdgeData(fromIndex: 23, toIndex: 24, relation: RelationType.spouse));

    // 여동생 (idx 25)
    nodes.add(_node(familySurname, _femaleNamesYoung, '여동생',
        1999, 2003, false, gen4Y, 500, temp: 4));
    edges.add(DummyEdgeData(fromIndex: 21, toIndex: 25, relation: RelationType.sibling));
    edges.add(DummyEdgeData(fromIndex: 10, toIndex: 25, relation: RelationType.child));

    // 사촌 (큰아버지 자녀) 2명
    nodes.add(_node(familySurname, _maleNamesMid, '사촌 형',
        1992, 1996, false, gen4Y, -700, temp: 2)); // idx 26
    edges.add(DummyEdgeData(fromIndex: 12, toIndex: 26, relation: RelationType.child));

    nodes.add(_node(familySurname, _femaleNamesMid, '사촌 누나',
        1990, 1994, false, gen4Y, -900, temp: 2)); // idx 27
    edges.add(DummyEdgeData(fromIndex: 12, toIndex: 27, relation: RelationType.child));
    edges.add(DummyEdgeData(fromIndex: 26, toIndex: 27, relation: RelationType.sibling));

    // 사촌 (작은아버지 자녀) 1명
    nodes.add(_node(familySurname, _maleNamesYoung, '사촌 동생',
        2000, 2004, false, gen4Y, -1100, temp: 1)); // idx 28
    edges.add(DummyEdgeData(fromIndex: 14, toIndex: 28, relation: RelationType.child));

    // 고모 자녀 2명
    final gomoSurname = nodes[17].name.substring(0, 1); // 고모부 성
    nodes.add(_node(gomoSurname, _maleNamesMid, '고모 아들',
        1995, 1999, false, gen4Y, 700, temp: 2)); // idx 29
    edges.add(DummyEdgeData(fromIndex: 16, toIndex: 29, relation: RelationType.child));
    edges.add(DummyEdgeData(fromIndex: 17, toIndex: 29, relation: RelationType.child));

    nodes.add(_node(gomoSurname, _femaleNamesYoung, '고모 딸',
        1998, 2002, false, gen4Y, 900, temp: 2)); // idx 30
    edges.add(DummyEdgeData(fromIndex: 16, toIndex: 30, relation: RelationType.child));
    edges.add(DummyEdgeData(fromIndex: 29, toIndex: 30, relation: RelationType.sibling));

    // 이모 자녀 1명
    final imoSurname = nodes[19].name.substring(0, 1);
    nodes.add(_node(imoSurname, _femaleNamesYoung, '이모 딸',
        2001, 2005, false, gen4Y, 1100, temp: 2)); // idx 31
    edges.add(DummyEdgeData(fromIndex: 18, toIndex: 31, relation: RelationType.child));

    // 큰할아버지 손자 (먼 사촌)
    nodes.add(_node(familySurname, _maleNamesYoung, '먼 사촌',
        1993, 1997, false, gen4Y, -1300, temp: 1)); // idx 32
    edges.add(DummyEdgeData(fromIndex: 20, toIndex: 32, relation: RelationType.child));

    // Ghost 배우자 (사촌 형)
    nodes.add(_node(_randomSurname(), _femaleNamesYoung, '사촌 형 배우자',
        1993, 1997, true, gen4Y, -800, temp: 0)); // idx 33
    edges.add(DummyEdgeData(fromIndex: 26, toIndex: 33, relation: RelationType.spouse));

    // ── 5세대: 자녀 + 조카 (12명) ──────────────────────────────────────

    // 내 자녀
    nodes.add(_node(familySurname, _maleNamesYoung, '첫째 아들',
        2024, 2025, false, gen5Y, 0, temp: 5)); // idx 34
    edges.add(DummyEdgeData(fromIndex: 21, toIndex: 34, relation: RelationType.child));
    edges.add(DummyEdgeData(fromIndex: 22, toIndex: 34, relation: RelationType.child));

    nodes.add(_node(familySurname, _femaleNamesYoung, '둘째 딸',
        2026, 2026, false, gen5Y, 200, temp: 5)); // idx 35
    edges.add(DummyEdgeData(fromIndex: 21, toIndex: 35, relation: RelationType.child));
    edges.add(DummyEdgeData(fromIndex: 34, toIndex: 35, relation: RelationType.sibling));

    // 형 자녀
    nodes.add(_node(familySurname, _femaleNamesYoung, '조카 (형 딸)',
        2022, 2024, false, gen5Y, -300, temp: 4)); // idx 36
    edges.add(DummyEdgeData(fromIndex: 23, toIndex: 36, relation: RelationType.child));
    edges.add(DummyEdgeData(fromIndex: 24, toIndex: 36, relation: RelationType.child));

    nodes.add(_node(familySurname, _maleNamesYoung, '조카 (형 아들)',
        2024, 2026, false, gen5Y, -500, temp: 4)); // idx 37
    edges.add(DummyEdgeData(fromIndex: 23, toIndex: 37, relation: RelationType.child));
    edges.add(DummyEdgeData(fromIndex: 36, toIndex: 37, relation: RelationType.sibling));

    // 사촌 형 자녀
    nodes.add(_node(familySurname, _maleNamesYoung, '사촌 조카',
        2023, 2025, false, gen5Y, -700, temp: 1)); // idx 38
    edges.add(DummyEdgeData(fromIndex: 26, toIndex: 38, relation: RelationType.child));

    // 고모 아들 자녀
    nodes.add(_node(gomoSurname, _femaleNamesYoung, '고모 손녀',
        2024, 2026, false, gen5Y, 700, temp: 2)); // idx 39
    edges.add(DummyEdgeData(fromIndex: 29, toIndex: 39, relation: RelationType.child));

    // ── 추가 Ghost 노드 (원거리 조상 등) ──────────────────────────────

    nodes.add(_node(familySurname, _maleNamesOld, '고조할아버지',
        1890, 1895, true, -900, -200, deceased: true, deadYear: (1960, 1970))); // idx 40
    nodes.add(_node(_randomSurname(), _femaleNamesOld, '고조할머니',
        1892, 1897, true, -900, 0, deceased: true, deadYear: (1965, 1975))); // idx 41
    edges.add(DummyEdgeData(fromIndex: 40, toIndex: 41, relation: RelationType.spouse));
    edges.add(DummyEdgeData(fromIndex: 40, toIndex: 0, relation: RelationType.child));

    // Ghost 먼 친척들
    nodes.add(_node(familySurname, _maleNamesOld, '미확인 친척 1',
        1935, 1940, true, gen2Y, -1000, temp: 0)); // idx 42
    edges.add(DummyEdgeData(fromIndex: 8, toIndex: 42, relation: RelationType.sibling));

    nodes.add(_node(familySurname, _femaleNamesOld, '미확인 친척 2',
        1938, 1943, true, gen2Y, -1200, temp: 0)); // idx 43
    edges.add(DummyEdgeData(fromIndex: 42, toIndex: 43, relation: RelationType.spouse));

    nodes.add(_node(extSurname, _maleNamesOld, '외가 친척',
        1942, 1947, true, gen2Y, 800, temp: 0)); // idx 44
    edges.add(DummyEdgeData(fromIndex: 6, toIndex: 44, relation: RelationType.sibling));

    nodes.add(_node(extSurname, _femaleNamesMid, '외가 사촌',
        1975, 1980, true, gen3Y, 1200, temp: 0)); // idx 45
    edges.add(DummyEdgeData(fromIndex: 44, toIndex: 45, relation: RelationType.child));

    // 여동생 배우자 (Ghost)
    nodes.add(_node(_randomSurname(), _maleNamesYoung, '여동생 남자친구',
        1998, 2002, true, gen4Y, 600, temp: 0)); // idx 46
    edges.add(DummyEdgeData(fromIndex: 25, toIndex: 46, relation: RelationType.spouse));

    // 먼 사촌 배우자 (Ghost)
    nodes.add(_node(_randomSurname(), _femaleNamesYoung, '먼 사촌 배우자',
        1994, 1998, true, gen4Y, -1400, temp: 0)); // idx 47
    edges.add(DummyEdgeData(fromIndex: 32, toIndex: 47, relation: RelationType.spouse));

    // 추가 (50개 맞추기)
    nodes.add(_node(familySurname, _maleNamesMid, '재종형',
        1968, 1973, false, gen3Y, -1400, temp: 1)); // idx 48
    edges.add(DummyEdgeData(fromIndex: 42, toIndex: 48, relation: RelationType.child));

    nodes.add(_node(familySurname, _maleNamesYoung, '재종조카',
        1995, 2000, false, gen4Y, -1500, temp: 1)); // idx 49
    edges.add(DummyEdgeData(fromIndex: 48, toIndex: 49, relation: RelationType.child));

    return (nodes: nodes, edges: edges);
  }

  // ── 헬퍼 ────────────────────────────────────────────────────────────────

  DummyNodeData _node(
    String surname,
    List<String> namePool,
    String bio,
    int birthYearMin,
    int birthYearMax,
    bool isGhost,
    double y,
    double x, {
    int? temp,
    bool deceased = false,
    (int, int)? deadYear,
  }) {
    final name = _uniqueName(surname, namePool);
    final birthYear = birthYearMin + _rng.nextInt(birthYearMax - birthYearMin + 1);
    final birthDate = DateTime(birthYear, 1 + _rng.nextInt(12), 1 + _rng.nextInt(28));

    DateTime? deathDate;
    if (deceased && deadYear != null) {
      final dy = deadYear.$1 + _rng.nextInt(deadYear.$2 - deadYear.$1 + 1);
      deathDate = DateTime(dy, 1 + _rng.nextInt(12), 1 + _rng.nextInt(28));
    }

    final temperature = temp ?? _randomTemperature(isGhost);

    // QuadTree 범위(0-4000) 중앙으로 이동
    const kCanvasCenter = 2000.0;

    return DummyNodeData(
      name: name,
      bio: bio,
      birthDate: birthDate,
      deathDate: deathDate,
      isGhost: isGhost,
      temperature: temperature,
      positionX: (x + kCanvasCenter + (_rng.nextDouble() * 20 - 10)).clamp(100.0, 3800.0),
      positionY: (y + kCanvasCenter + (_rng.nextDouble() * 20 - 10)).clamp(100.0, 3800.0),
    );
  }

  int _randomTemperature(bool isGhost) {
    if (isGhost) return 0;
    // 가중 랜덤: 0(5%), 1(10%), 2(40%), 3(30%), 4(10%), 5(5%)
    final r = _rng.nextInt(100);
    if (r < 5) return 0;
    if (r < 15) return 1;
    if (r < 55) return 2;
    if (r < 85) return 3;
    if (r < 95) return 4;
    return 5;
  }

  String _randomSurname() => _surnames[_rng.nextInt(_surnames.length)];

  /// 중복 없는 이름 생성.
  /// 1차: 이름 풀에서 미사용 이름을 무작위 선택
  /// 2차: 풀 소진 시 다른 성씨로 조합 재시도
  /// 3차: 모두 소진 시 숫자 접미사 부여
  String _uniqueName(String surname, List<String> namePool) {
    // 셔플된 인덱스로 풀 전체를 순회하며 미사용 이름 탐색
    final indices = List.generate(namePool.length, (i) => i)..shuffle(_rng);
    for (final i in indices) {
      final candidate = '$surname${namePool[i]}';
      if (!_usedNames.contains(candidate)) {
        _usedNames.add(candidate);
        return candidate;
      }
    }

    // 풀 소진: 다른 성씨와 조합 시도
    final surnameIndices = List.generate(_surnames.length, (i) => i)
      ..shuffle(_rng);
    for (final si in surnameIndices) {
      final altSurname = _surnames[si];
      for (final i in indices) {
        final candidate = '$altSurname${namePool[i]}';
        if (!_usedNames.contains(candidate)) {
          _usedNames.add(candidate);
          return candidate;
        }
      }
    }

    // 최후 수단: 원래 이름 + 숫자 접미사
    final baseName = '$surname${namePool[_rng.nextInt(namePool.length)]}';
    var suffix = 2;
    var candidate = '$baseName($suffix)';
    while (_usedNames.contains(candidate)) {
      suffix++;
      candidate = '$baseName($suffix)';
    }
    _usedNames.add(candidate);
    return candidate;
  }
}
