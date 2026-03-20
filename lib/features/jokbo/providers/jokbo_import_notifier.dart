import 'dart:ui';
import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/repositories/db_provider.dart';
import '../services/jokbo_layout_service.dart';

part 'jokbo_import_notifier.g.dart';

// ── 데이터 모델 ─────────────────────────────────────────────────────────────

/// 족보 입력 항목 (임시 — DB 커밋 전)
class JokboEntry {
  const JokboEntry({
    required this.tempId,
    required this.name,
    required this.generation,
    this.gender,
    this.parentTempId,
    this.spouseTempId,
  });

  final String tempId;
  final String name;
  final int generation;
  final String? gender; // '남' / '여'
  final String? parentTempId;
  final String? spouseTempId;

  JokboEntry copyWith({
    String? tempId,
    String? name,
    int? generation,
    String? gender,
    String? parentTempId,
    String? spouseTempId,
    bool clearParent = false,
    bool clearSpouse = false,
  }) {
    return JokboEntry(
      tempId: tempId ?? this.tempId,
      name: name ?? this.name,
      generation: generation ?? this.generation,
      gender: gender ?? this.gender,
      parentTempId: clearParent ? null : (parentTempId ?? this.parentTempId),
      spouseTempId: clearSpouse ? null : (spouseTempId ?? this.spouseTempId),
    );
  }
}

/// 족보 가져오기 마법사 상태
class JokboImportState {
  const JokboImportState({
    this.currentGeneration = 1,
    this.maxGeneration = 4,
    this.entries = const [],
    this.isComplete = false,
  });

  /// 현재 입력 중인 세대 (1-based)
  final int currentGeneration;

  /// 사용자가 선택한 총 세대 수 (1~8)
  final int maxGeneration;

  /// 입력된 모든 항목
  final List<JokboEntry> entries;

  /// 마법사 완료 여부
  final bool isComplete;

  /// 현재 세대의 항목만 반환
  List<JokboEntry> get currentEntries =>
      entries.where((e) => e.generation == currentGeneration).toList();

  /// 이전 세대의 항목 (부모 선택용)
  List<JokboEntry> get previousGenEntries => currentGeneration > 1
      ? entries.where((e) => e.generation == currentGeneration - 1).toList()
      : [];

  /// 전체 인원 수
  int get totalCount => entries.length;

  /// 현재 세대가 첫 번째 세대인지
  bool get isFirstGeneration => currentGeneration == 1;

  /// 현재 세대가 마지막 세대인지
  bool get isLastGeneration => currentGeneration == maxGeneration;

  /// 마지막 확인 단계인지 (세대 입력 후)
  bool get isPreviewStep => currentGeneration > maxGeneration;

  JokboImportState copyWith({
    int? currentGeneration,
    int? maxGeneration,
    List<JokboEntry>? entries,
    bool? isComplete,
  }) {
    return JokboImportState(
      currentGeneration: currentGeneration ?? this.currentGeneration,
      maxGeneration: maxGeneration ?? this.maxGeneration,
      entries: entries ?? this.entries,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}

// ── Notifier ────────────────────────────────────────────────────────────────

@riverpod
class JokboImportNotifier extends _$JokboImportNotifier {
  static const _uuid = Uuid();

  @override
  JokboImportState build() => const JokboImportState();

  /// 총 세대 수 설정
  void setMaxGeneration(int gen) {
    // 이미 입력된 세대보다 작아지면 해당 세대 이후 항목 제거
    final filtered = state.entries.where((e) => e.generation <= gen).toList();
    state = state.copyWith(
      maxGeneration: gen,
      entries: filtered,
    );
  }

  /// 항목 추가
  void addEntry({
    required String name,
    required int generation,
    String? gender,
    String? parentTempId,
    String? spouseTempId,
  }) {
    final entry = JokboEntry(
      tempId: _uuid.v4(),
      name: name,
      generation: generation,
      gender: gender,
      parentTempId: parentTempId,
      spouseTempId: spouseTempId,
    );
    state = state.copyWith(entries: [...state.entries, entry]);
  }

  /// 항목 제거
  void removeEntry(String tempId) {
    // 삭제 대상을 부모/배우자로 참조하는 다른 항목도 링크 정리
    final updated = state.entries
        .where((e) => e.tempId != tempId)
        .map((e) {
          var entry = e;
          if (entry.parentTempId == tempId) {
            entry = entry.copyWith(clearParent: true);
          }
          if (entry.spouseTempId == tempId) {
            entry = entry.copyWith(clearSpouse: true);
          }
          return entry;
        })
        .toList();
    state = state.copyWith(entries: updated);
  }

  /// 항목 수정
  void updateEntry(String tempId, {
    String? name,
    String? gender,
    String? parentTempId,
    String? spouseTempId,
    bool clearParent = false,
    bool clearSpouse = false,
  }) {
    final updated = state.entries.map((e) {
      if (e.tempId != tempId) return e;
      return e.copyWith(
        name: name,
        gender: gender,
        parentTempId: parentTempId,
        spouseTempId: spouseTempId,
        clearParent: clearParent,
        clearSpouse: clearSpouse,
      );
    }).toList();
    state = state.copyWith(entries: updated);
  }

  /// 다음 세대로 이동
  void nextGeneration() {
    if (state.currentGeneration <= state.maxGeneration) {
      state = state.copyWith(
        currentGeneration: state.currentGeneration + 1,
      );
    }
  }

  /// 이전 세대로 이동
  void prevGeneration() {
    if (state.currentGeneration > 1) {
      state = state.copyWith(
        currentGeneration: state.currentGeneration - 1,
      );
    }
  }

  /// 세대 선택 단계로 리셋 (처음으로)
  void reset() {
    state = const JokboImportState();
  }

  /// 전체 항목을 DB에 커밋 (노드 + 엣지 생성)
  /// 반환: 생성된 노드 수
  Future<int> commitToDatabase() async {
    final db = ref.read(appDatabaseProvider);
    final tempToReal = <String, String>{};

    // 세대별 맵 구성 (레이아웃 계산용)
    final genMap = <int, List<String>>{};
    for (final e in state.entries) {
      genMap.putIfAbsent(e.generation, () => []).add(e.tempId);
    }
    final positions = JokboLayoutService.calculateLayout(genMap);

    // 1) 노드 생성
    for (final entry in state.entries) {
      final realId = _uuid.v4();
      tempToReal[entry.tempId] = realId;
      final pos = positions[entry.tempId] ?? const Offset(2000, 2000);

      await db.upsertNode(NodesTableCompanion.insert(
        id: realId,
        name: entry.name,
        bio: Value(entry.gender != null ? '${entry.gender} / ${entry.generation}세대' : '${entry.generation}세대'),
        isGhost: const Value(false),
        temperature: const Value(3),
        positionX: Value(pos.dx),
        positionY: Value(pos.dy),
        tagsJson: Value('["jokbo", "${entry.generation}세대"]'),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ));
    }

    // 2) 부모-자녀 엣지 생성
    final createdSpouseEdges = <String>{};
    for (final entry in state.entries) {
      // parent-child
      if (entry.parentTempId != null) {
        final fromId = tempToReal[entry.parentTempId];
        final toId = tempToReal[entry.tempId];
        if (fromId != null && toId != null) {
          await db.upsertEdge(NodeEdgesTableCompanion.insert(
            id: _uuid.v4(),
            fromNodeId: fromId,
            toNodeId: toId,
            relation: 'parent',
          ));
        }
      }

      // spouse (양방향이므로 한 번만 생성)
      if (entry.spouseTempId != null) {
        final pairKey = _spouseKey(entry.tempId, entry.spouseTempId!);
        if (!createdSpouseEdges.contains(pairKey)) {
          final fromId = tempToReal[entry.tempId];
          final toId = tempToReal[entry.spouseTempId];
          if (fromId != null && toId != null) {
            await db.upsertEdge(NodeEdgesTableCompanion.insert(
              id: _uuid.v4(),
              fromNodeId: fromId,
              toNodeId: toId,
              relation: 'spouse',
            ));
            createdSpouseEdges.add(pairKey);
          }
        }
      }
    }

    state = state.copyWith(isComplete: true);
    return state.entries.length;
  }

  /// 배우자 쌍의 고유 키 (순서 무관)
  String _spouseKey(String a, String b) {
    final sorted = [a, b]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }
}
