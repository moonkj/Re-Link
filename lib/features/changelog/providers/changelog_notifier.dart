import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/tables/settings_table.dart';
import '../../../shared/repositories/settings_repository.dart';
import '../models/changelog_entry.dart';

part 'changelog_notifier.g.dart';

/// 변경 로그 상태 관리
///
/// changelog.json 로드 + 최신 버전과 lastSeenVersion 비교
@riverpod
class ChangelogNotifier extends _$ChangelogNotifier {
  @override
  Future<List<ChangelogEntry>> build() async {
    final jsonStr = await rootBundle.loadString('assets/data/changelog.json');
    final data = json.decode(jsonStr) as Map<String, dynamic>;
    final entries = (data['entries'] as List<dynamic>?)
            ?.map((e) => ChangelogEntry.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return entries;
  }

  /// 변경 로그를 표시해야 하는지 판단
  ///
  /// changelog.json의 최신 버전이 설정에 저장된 lastSeenVersion보다
  /// 새로운 경우 true 반환
  Future<bool> shouldShowChangelog() async {
    final settings = ref.read(settingsRepositoryProvider);
    final lastSeen = await settings.get(SettingsKey.lastSeenVersion);

    final entries = state.valueOrNull;
    if (entries == null || entries.isEmpty) return false;

    // 최신 엔트리의 버전
    final latestVersion = entries.first.version;

    // 한 번도 본 적 없거나, 저장된 버전이 최신과 다르면 표시
    if (lastSeen == null || lastSeen.isEmpty) return true;
    return _compareVersions(latestVersion, lastSeen) > 0;
  }

  /// 변경 로그를 확인했음을 기록
  Future<void> markAsSeen(String version) async {
    final settings = ref.read(settingsRepositoryProvider);
    await settings.set(SettingsKey.lastSeenVersion, version);
  }

  /// 최신 변경 로그 엔트리 반환 (없으면 null)
  ChangelogEntry? get latestEntry {
    final entries = state.valueOrNull;
    if (entries == null || entries.isEmpty) return null;
    return entries.first;
  }

  /// 시맨틱 버전 비교: a > b → 양수, a == b → 0, a < b → 음수
  static int _compareVersions(String a, String b) {
    final aParts = a.split('.').map((s) => int.tryParse(s) ?? 0).toList();
    final bParts = b.split('.').map((s) => int.tryParse(s) ?? 0).toList();

    final maxLen = aParts.length > bParts.length ? aParts.length : bParts.length;
    for (int i = 0; i < maxLen; i++) {
      final av = i < aParts.length ? aParts[i] : 0;
      final bv = i < bParts.length ? bParts[i] : 0;
      if (av != bv) return av - bv;
    }
    return 0;
  }
}
