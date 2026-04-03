import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/clan_data.dart';

part 'clan_explorer_notifier.g.dart';

/// 한국 성씨 탐색기 — JSON 로드 + 검색
@riverpod
class ClanExplorerNotifier extends _$ClanExplorerNotifier {
  List<ClanSurname> _allClans = [];

  @override
  Future<List<ClanSurname>> build() async {
    final jsonStr =
        await rootBundle.loadString('assets/data/korean_clans.json');
    final list = jsonDecode(jsonStr) as List<dynamic>;
    _allClans = list
        .map((e) => ClanSurname.fromJson(e as Map<String, dynamic>))
        .toList();
    return _allClans;
  }

  /// 성씨, 로마자, 본관으로 검색
  List<ClanSurname> search(String query) {
    if (query.isEmpty) return _allClans;
    // "김씨" → "김", "이씨" → "이" 등 "씨" 접미사 제거
    final cleaned =
        query.endsWith('씨') ? query.substring(0, query.length - 1) : query;
    if (cleaned.isEmpty) return _allClans;
    final q = cleaned.toLowerCase();

    // 1글자: 성씨 + 로마자만 매칭
    if (cleaned.length == 1) {
      return _allClans.where((s) {
        if (s.surname == cleaned) return true;
        if (s.romanized.toLowerCase().startsWith(q)) return true;
        return false;
      }).toList();
    }

    // 2글자 이상: 성씨 + 로마자 + 본관 검색 (예: "밀양", "경주")
    return _allClans.where((s) {
      if (s.surname.contains(cleaned)) return true;
      if (s.romanized.toLowerCase().contains(q)) return true;
      if (s.clans.any((c) => c.origin.contains(cleaned))) return true;
      if (s.clans.any((c) => c.founder.contains(cleaned))) return true;
      if (s.clans.any(
          (c) => c.famousPeople.any((p) => p.contains(cleaned)))) return true;
      return false;
    }).toList();
  }
}
