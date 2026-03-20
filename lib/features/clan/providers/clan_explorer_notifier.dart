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
    final q = query.toLowerCase();
    return _allClans.where((s) {
      if (s.surname.contains(query)) return true;
      if (s.romanized.toLowerCase().contains(q)) return true;
      if (s.clans.any((c) => c.origin.contains(query))) return true;
      if (s.clans.any((c) => c.founder.contains(query))) return true;
      if (s.clans.any(
          (c) => c.famousPeople.any((p) => p.contains(query)))) return true;
      return false;
    }).toList();
  }
}
