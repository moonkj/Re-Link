/// 한국 성씨(Surname) 데이터 모델
class ClanSurname {
  final String surname;
  final String romanized;
  final List<ClanInfo> clans;

  const ClanSurname({
    required this.surname,
    required this.romanized,
    required this.clans,
  });

  factory ClanSurname.fromJson(Map<String, dynamic> json) {
    return ClanSurname(
      surname: json['surname'] as String,
      romanized: json['romanized'] as String,
      clans: (json['clans'] as List<dynamic>)
          .map((e) => ClanInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// 본관(Clan) 상세 정보
class ClanInfo {
  final String origin;
  final String founder;
  final int? foundedYear;
  final int? population;
  final List<String> famousPeople;
  final String description;

  const ClanInfo({
    required this.origin,
    required this.founder,
    this.foundedYear,
    this.population,
    required this.famousPeople,
    required this.description,
  });

  factory ClanInfo.fromJson(Map<String, dynamic> json) {
    return ClanInfo(
      origin: json['origin'] as String,
      founder: json['founder'] as String,
      foundedYear: json['foundedYear'] as int?,
      population: json['population'] as int?,
      famousPeople: (json['famousPeople'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      description: json['description'] as String,
    );
  }

  /// 인구 포맷: 약 445만명, 약 17만명, 약 8,853명
  String get populationFormatted {
    if (population == null) return '인구 미상';
    final p = population!;
    if (p >= 10000000) {
      final man = (p / 10000).round();
      return '약 ${(man / 100).toStringAsFixed(0)}만명';
    } else if (p >= 1000000) {
      final man = p / 10000;
      return '약 ${man.round()}만명';
    } else if (p >= 100000) {
      final man = p / 10000;
      return '약 ${man.toStringAsFixed(0)}만명';
    } else if (p >= 10000) {
      final man = p / 10000;
      return '약 ${man.toStringAsFixed(1)}만명';
    } else {
      return '약 ${_formatNumber(p)}명';
    }
  }

  /// 설립연도 포맷: "기원전 57년", "42년", "930년"
  String? get foundedYearFormatted {
    if (foundedYear == null) return null;
    if (foundedYear! < 0) return '기원전 ${-foundedYear!}년';
    return '${foundedYear!}년';
  }

  static String _formatNumber(int n) {
    final str = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buf.write(',');
      }
      buf.write(str[i]);
    }
    return buf.toString();
  }
}
