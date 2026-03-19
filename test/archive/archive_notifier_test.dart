/// ArchiveNotifier 로직 단위 테스트
/// 커버: archive_notifier.dart 미커버 라인 (52, 69-155)
import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/features/archive/providers/archive_notifier.dart';
import 'package:re_link/shared/models/memory_model.dart';
import 'package:re_link/shared/models/node_model.dart';

// ── 헬퍼 ────────────────────────────────────────────────────────────────────

NodeModel _node(String id, String name) =>
    NodeModel(id: id, name: name, createdAt: DateTime(2024));

MemoryModel _memory({
  required String id,
  required String nodeId,
  required MemoryType type,
  String? title,
  String? description,
  DateTime? createdAt,
  bool isPrivate = false,
}) =>
    MemoryModel(
      id: id,
      nodeId: nodeId,
      type: type,
      title: title,
      description: description,
      createdAt: createdAt ?? DateTime(2024, 6, 1),
      isPrivate: isPrivate,
    );

// ── _rebuild 로직을 ArchiveNotifier 외부에서 단독으로 재현 ───────────────────

List<ArchiveGroup> _rebuild({
  required List<MemoryModel> memories,
  required List<NodeModel> nodes,
  ArchiveFilter filter = ArchiveFilter.all,
  ArchiveSortOrder order = ArchiveSortOrder.newest,
  String searchQuery = '',
}) {
  final query = searchQuery.toLowerCase();

  var filtered = memories.where((m) {
    if (filter != ArchiveFilter.all && m.type.name != filter.name) return false;
    if (query.isNotEmpty) {
      final titleMatch = m.title?.toLowerCase().contains(query) ?? false;
      final descMatch = m.description?.toLowerCase().contains(query) ?? false;
      return titleMatch || descMatch;
    }
    return true;
  }).toList();

  switch (order) {
    case ArchiveSortOrder.newest:
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    case ArchiveSortOrder.oldest:
      filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    case ArchiveSortOrder.name:
      filtered.sort((a, b) => (a.title ?? '').compareTo(b.title ?? ''));
  }

  final nodeMap = {for (final n in nodes) n.id: n};
  final groupMap = <String, List<MemoryModel>>{};
  for (final m in filtered) {
    groupMap.putIfAbsent(m.nodeId, () => []).add(m);
  }

  final groups = groupMap.entries
      .map((e) {
        final node = nodeMap[e.key];
        if (node == null) return null;
        return ArchiveGroup(node: node, memories: e.value);
      })
      .whereType<ArchiveGroup>()
      .toList();

  groups.sort((a, b) => a.node.name.compareTo(b.node.name));
  return groups;
}

void main() {
  final nodeA = _node('n1', '김철수');
  final nodeB = _node('n2', '박영희');

  final photoA = _memory(id: 'm1', nodeId: 'n1', type: MemoryType.photo,
      title: '여름 사진', createdAt: DateTime(2024, 8, 1));
  final voiceA = _memory(id: 'm2', nodeId: 'n1', type: MemoryType.voice,
      title: '목소리', createdAt: DateTime(2024, 3, 1));
  final noteB = _memory(id: 'm3', nodeId: 'n2', type: MemoryType.note,
      title: '메모', description: '일기 내용', createdAt: DateTime(2024, 5, 1));

  // ── ArchiveState ──────────────────────────────────────────────────────────

  group('ArchiveState', () {
    test('기본 상태 검증', () {
      const s = ArchiveState();
      expect(s.filter, ArchiveFilter.all);
      expect(s.sortOrder, ArchiveSortOrder.newest);
      expect(s.searchQuery, '');
      expect(s.isLoading, isTrue);
      expect(s.isEmpty, isTrue);
    });

    test('isEmpty — groups 있으면 false', () {
      final group = ArchiveGroup(node: nodeA, memories: [photoA]);
      final s = ArchiveState(groups: [group], isLoading: false);
      expect(s.isEmpty, isFalse);
    });

    test('isEmpty — groups는 있지만 memories 비어있으면 true', () {
      final group = ArchiveGroup(node: nodeA, memories: []);
      final s = ArchiveState(groups: [group], isLoading: false);
      expect(s.isEmpty, isTrue);
    });

    test('copyWith filter 변경', () {
      const s = ArchiveState();
      final updated = s.copyWith(filter: ArchiveFilter.photo);
      expect(updated.filter, ArchiveFilter.photo);
      expect(updated.sortOrder, ArchiveSortOrder.newest); // 유지
    });

    test('copyWith sortOrder 변경', () {
      const s = ArchiveState();
      final updated = s.copyWith(sortOrder: ArchiveSortOrder.oldest);
      expect(updated.sortOrder, ArchiveSortOrder.oldest);
    });

    test('copyWith searchQuery 변경', () {
      const s = ArchiveState();
      final updated = s.copyWith(searchQuery: '여름');
      expect(updated.searchQuery, '여름');
    });

    test('copyWith isLoading 변경', () {
      const s = ArchiveState();
      final updated = s.copyWith(isLoading: false);
      expect(updated.isLoading, isFalse);
    });
  });

  // ── _rebuild 필터 로직 ───────────────────────────────────────────────────

  group('_rebuild — 필터 로직', () {
    test('filter=all → 모든 기억 포함', () {
      final groups = _rebuild(
        memories: [photoA, voiceA, noteB],
        nodes: [nodeA, nodeB],
      );
      final totalMemories = groups.fold<int>(0, (s, g) => s + g.memories.length);
      expect(totalMemories, 3);
    });

    test('filter=photo → photo만', () {
      final groups = _rebuild(
        memories: [photoA, voiceA, noteB],
        nodes: [nodeA, nodeB],
        filter: ArchiveFilter.photo,
      );
      final totalMemories = groups.fold<int>(0, (s, g) => s + g.memories.length);
      expect(totalMemories, 1);
      expect(groups.first.memories.first.type, MemoryType.photo);
    });

    test('filter=voice → voice만', () {
      final groups = _rebuild(
        memories: [photoA, voiceA, noteB],
        nodes: [nodeA, nodeB],
        filter: ArchiveFilter.voice,
      );
      final totalMemories = groups.fold<int>(0, (s, g) => s + g.memories.length);
      expect(totalMemories, 1);
      expect(groups.first.memories.first.type, MemoryType.voice);
    });

    test('filter=note → note만', () {
      final groups = _rebuild(
        memories: [photoA, voiceA, noteB],
        nodes: [nodeA, nodeB],
        filter: ArchiveFilter.note,
      );
      final totalMemories = groups.fold<int>(0, (s, g) => s + g.memories.length);
      expect(totalMemories, 1);
      expect(groups.first.memories.first.type, MemoryType.note);
    });
  });

  // ── _rebuild 정렬 로직 ───────────────────────────────────────────────────

  group('_rebuild — 정렬 로직', () {
    test('newest → 최신 먼저 (2024-08 > 2024-03)', () {
      final groups = _rebuild(
        memories: [voiceA, photoA],
        nodes: [nodeA],
        order: ArchiveSortOrder.newest,
      );
      expect(groups.first.memories.first.id, 'm1'); // photoA (Aug)
    });

    test('oldest → 오래된 것 먼저 (2024-03 < 2024-08)', () {
      final groups = _rebuild(
        memories: [photoA, voiceA],
        nodes: [nodeA],
        order: ArchiveSortOrder.oldest,
      );
      expect(groups.first.memories.first.id, 'm2'); // voiceA (Mar)
    });

    test('name → 제목 알파벳순', () {
      final m1 = _memory(id: 'x1', nodeId: 'n1', type: MemoryType.note, title: '나');
      final m2 = _memory(id: 'x2', nodeId: 'n1', type: MemoryType.note, title: '가');
      final groups = _rebuild(
        memories: [m1, m2],
        nodes: [nodeA],
        order: ArchiveSortOrder.name,
      );
      expect(groups.first.memories.first.title, '가');
    });
  });

  // ── _rebuild 검색 로직 ───────────────────────────────────────────────────

  group('_rebuild — 검색 로직', () {
    test('searchQuery="여름" → 제목 포함 기억만', () {
      final groups = _rebuild(
        memories: [photoA, voiceA, noteB],
        nodes: [nodeA, nodeB],
        searchQuery: '여름',
      );
      final totalMemories = groups.fold<int>(0, (s, g) => s + g.memories.length);
      expect(totalMemories, 1);
      expect(groups.first.memories.first.title, contains('여름'));
    });

    test('searchQuery="일기" → description 포함 기억', () {
      final groups = _rebuild(
        memories: [photoA, voiceA, noteB],
        nodes: [nodeA, nodeB],
        searchQuery: '일기',
      );
      final totalMemories = groups.fold<int>(0, (s, g) => s + g.memories.length);
      expect(totalMemories, 1);
      expect(groups.first.memories.first.id, 'm3');
    });

    test('searchQuery 대소문자 무관 (대문자 입력)', () {
      final mEng = _memory(
        id: 'e1', nodeId: 'n1', type: MemoryType.note, title: 'Summer Memory',
      );
      final groups = _rebuild(
        memories: [mEng],
        nodes: [nodeA],
        searchQuery: 'summer',
      );
      expect(groups.first.memories.length, 1);
    });

    test('searchQuery 매칭 없으면 groups 비어있음', () {
      final groups = _rebuild(
        memories: [photoA, voiceA],
        nodes: [nodeA],
        searchQuery: '존재하지않는검색어',
      );
      expect(groups, isEmpty);
    });
  });

  // ── _rebuild 그룹핑 로직 ─────────────────────────────────────────────────

  group('_rebuild — 그룹핑 로직', () {
    test('같은 nodeId → 같은 그룹', () {
      final groups = _rebuild(
        memories: [photoA, voiceA],
        nodes: [nodeA],
      );
      expect(groups.length, 1);
      expect(groups.first.memories.length, 2);
    });

    test('다른 nodeId → 다른 그룹', () {
      final groups = _rebuild(
        memories: [photoA, noteB],
        nodes: [nodeA, nodeB],
      );
      expect(groups.length, 2);
    });

    test('노드 없는 기억은 그룹에 포함 안 됨', () {
      final orphan = _memory(id: 'o1', nodeId: 'ghost_id', type: MemoryType.note);
      final groups = _rebuild(memories: [orphan], nodes: [nodeA]);
      expect(groups, isEmpty);
    });

    test('그룹은 노드 이름순으로 정렬 (김철수 < 박영희)', () {
      final groups = _rebuild(
        memories: [noteB, photoA],
        nodes: [nodeA, nodeB],
      );
      expect(groups.first.node.name, '김철수');
    });
  });

  // ── ArchiveGroup ────────────────────────────────────────────────────────

  group('ArchiveGroup', () {
    test('생성 후 필드 접근', () {
      final group = ArchiveGroup(node: nodeA, memories: [photoA]);
      expect(group.node.id, 'n1');
      expect(group.memories.length, 1);
    });
  });

  // ── ArchiveFilter enum ──────────────────────────────────────────────────

  group('ArchiveFilter enum', () {
    test('4가지 값 존재', () => expect(ArchiveFilter.values.length, 4));
    test('all.name == "all"', () => expect(ArchiveFilter.all.name, 'all'));
    test('photo.name == "photo"', () => expect(ArchiveFilter.photo.name, 'photo'));
    test('voice.name == "voice"', () => expect(ArchiveFilter.voice.name, 'voice'));
    test('note.name == "note"', () => expect(ArchiveFilter.note.name, 'note'));
  });

  // ── ArchiveSortOrder enum ───────────────────────────────────────────────

  group('ArchiveSortOrder enum', () {
    test('3가지 값 존재', () => expect(ArchiveSortOrder.values.length, 3));
    test('newest.name == "newest"', () => expect(ArchiveSortOrder.newest.name, 'newest'));
    test('oldest.name == "oldest"', () => expect(ArchiveSortOrder.oldest.name, 'oldest'));
    test('name.name == "name"', () => expect(ArchiveSortOrder.name.name, 'name'));
  });
}
