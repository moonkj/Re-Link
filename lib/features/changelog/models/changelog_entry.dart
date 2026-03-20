/// 변경 로그 데이터 모델

/// 단일 변경 항목
class ChangeItem {
  const ChangeItem({
    required this.type,
    required this.text,
  });

  /// 변경 유형: feature / fix / improvement
  final String type;

  /// 변경 내용 텍스트
  final String text;

  factory ChangeItem.fromJson(Map<String, dynamic> json) {
    return ChangeItem(
      type: json['type'] as String? ?? 'feature',
      text: json['text'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'text': text,
      };
}

/// 기여자 정보
class Contributor {
  const Contributor({
    required this.name,
    this.nodeId,
  });

  /// 기여자 이름
  final String name;

  /// 연결된 노드 ID (nullable — 노드 미연결 기여자 가능)
  final String? nodeId;

  factory Contributor.fromJson(Map<String, dynamic> json) {
    return Contributor(
      name: json['name'] as String? ?? '',
      nodeId: json['nodeId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        if (nodeId != null) 'nodeId': nodeId,
      };
}

/// 버전별 변경 로그 엔트리
class ChangelogEntry {
  const ChangelogEntry({
    required this.version,
    required this.date,
    required this.title,
    required this.changes,
    required this.contributors,
  });

  /// 앱 버전 (예: "2.1.0")
  final String version;

  /// 출시 날짜 (예: "2026-03-20")
  final String date;

  /// 업데이트 제목 (예: "v2.1 — 감성 업데이트")
  final String title;

  /// 변경 항목 목록
  final List<ChangeItem> changes;

  /// 기여자 목록
  final List<Contributor> contributors;

  factory ChangelogEntry.fromJson(Map<String, dynamic> json) {
    return ChangelogEntry(
      version: json['version'] as String? ?? '',
      date: json['date'] as String? ?? '',
      title: json['title'] as String? ?? '',
      changes: (json['changes'] as List<dynamic>?)
              ?.map((e) => ChangeItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      contributors: (json['contributors'] as List<dynamic>?)
              ?.map((e) => Contributor.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'version': version,
        'date': date,
        'title': title,
        'changes': changes.map((c) => c.toJson()).toList(),
        'contributors': contributors.map((c) => c.toJson()).toList(),
      };
}
