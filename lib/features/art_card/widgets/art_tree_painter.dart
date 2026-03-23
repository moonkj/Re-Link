import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../shared/models/node_model.dart';
import '../../../design/tokens/app_colors.dart';
import '../models/art_card_config.dart';

/// 4세대 가족트리 레이아웃 결과
class FamilyGenerationLayout {
  const FamilyGenerationLayout({
    required this.grandparents,
    required this.parents,
    required this.myGeneration,
    required this.children,
    required this.allIncludedIds,
    required this.relevantEdges,
  });

  /// 1줄: 조부모 (나의 부모의 부모)
  final List<String> grandparents;

  /// 2줄: 부모 세대 (나의 부모 + 부모의 형제)
  final List<String> parents;

  /// 3줄: 나 세대 (나, 배우자, 형제/자매, 사촌)
  final List<String> myGeneration;

  /// 4줄: 자녀 세대 (내 자녀들)
  final List<String> children;

  /// 표시 대상 전체 노드 ID
  final Set<String> allIncludedIds;

  /// 표시 대상 노드들 사이의 엣지만
  final List<NodeEdge> relevantEdges;

  int get totalCount =>
      grandparents.length +
      parents.length +
      myGeneration.length +
      children.length;
}

/// _computeLayout 결과 — 노드 좌표 + 커플 쌍
class _LayoutResult {
  const _LayoutResult({
    required this.positions,
    required this.couplePairs,
  });
  final Map<String, Offset> positions;
  final List<(String, String)> couplePairs;
}

/// 아트 카드용 가족트리 CustomPainter — "나" 기준 4세대 레이아웃
class ArtTreePainter extends CustomPainter {
  const ArtTreePainter({
    required this.nodes,
    required this.edges,
    required this.style,
    required this.palette,
    this.myNodeId,
    this.showWatermark = true,
    this.nodeImages = const {},
  });

  final List<NodeModel> nodes;
  final List<NodeEdge> edges;
  final ArtStyle style;
  final ArtPalette palette;
  final String? myNodeId;
  final bool showWatermark;

  /// 노드 ID → 미리 로드된 프로필 사진 (dart:ui.Image)
  final Map<String, ui.Image> nodeImages;

  /// 한 줄에 표시할 최대 노드 수
  static const int _maxPerRow = 6;

  /// 전체 최대 인원
  static const int _maxTotal = 20;

  @override
  void paint(Canvas canvas, Size size) {
    // 배경
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = palette.background,
    );

    // 스타일별 배경 데코
    _drawBackgroundDecoration(canvas, size);

    if (nodes.isEmpty) {
      _drawTitle(canvas, size, 0);
      if (showWatermark) _drawWatermark(canvas, size);
      return;
    }

    // "나" 기준 4세대 분류
    final familyLayout = _buildFamilyGenerations();

    // 노드 레이아웃 계산 (커플 그룹핑 포함)
    final layoutResult = _computeLayout(size, familyLayout);
    final layout = layoutResult.positions;

    // 엣지 그리기 (부모↔자녀 세로선만, 형제/배우자 제외)
    _drawEdges(canvas, size, layout, familyLayout.relevantEdges);

    // 커플 하트 그리기 (배우자 관계를 하트로 표현)
    _drawCoupleHearts(canvas, layout, layoutResult.couplePairs);

    // 노드 그리기
    _drawNodes(canvas, size, layout, familyLayout);

    // 타이틀
    _drawTitle(canvas, size, familyLayout.totalCount);

    // 세대 라벨
    _drawGenerationLabels(canvas, size, familyLayout);

    // 워터마크
    if (showWatermark) _drawWatermark(canvas, size);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ── "나" 기준 4세대 분류 ──────────────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════

  FamilyGenerationLayout _buildFamilyGenerations() {
    final nodeMap = {for (final n in nodes) n.id: n};

    // ── 관계 인덱스 구축 ─────────────────────────────────────────────────
    // parent → children
    final parentToChildren = <String, Set<String>>{};
    // child → parents
    final childToParents = <String, Set<String>>{};
    // spouse pairs
    final spouseOf = <String, Set<String>>{};
    // sibling pairs
    final siblingOf = <String, Set<String>>{};

    for (final e in edges) {
      switch (e.relation) {
        case RelationType.child:
          // fromNodeId is parent, toNodeId is child
          parentToChildren.putIfAbsent(e.fromNodeId, () => {}).add(e.toNodeId);
          childToParents.putIfAbsent(e.toNodeId, () => {}).add(e.fromNodeId);
        case RelationType.parent:
          // fromNodeId is child, toNodeId is parent
          childToParents.putIfAbsent(e.fromNodeId, () => {}).add(e.toNodeId);
          parentToChildren.putIfAbsent(e.toNodeId, () => {}).add(e.fromNodeId);
        case RelationType.spouse:
          spouseOf.putIfAbsent(e.fromNodeId, () => {}).add(e.toNodeId);
          spouseOf.putIfAbsent(e.toNodeId, () => {}).add(e.fromNodeId);
        case RelationType.sibling:
          siblingOf.putIfAbsent(e.fromNodeId, () => {}).add(e.toNodeId);
          siblingOf.putIfAbsent(e.toNodeId, () => {}).add(e.fromNodeId);
        case RelationType.other:
          break;
      }
    }

    final meId = myNodeId;
    if (meId == null || !nodeMap.containsKey(meId)) {
      // "나" 없으면 기존 전체 표시 (fallback)
      return _fallbackLayout();
    }

    // ── 3줄: 나 세대 ──────────────────────────────────────────────────────
    final myGen = <String>{meId};

    // 내 배우자
    for (final sid in spouseOf[meId] ?? <String>{}) {
      if (nodeMap.containsKey(sid)) myGen.add(sid);
    }

    // 내 형제/자매
    for (final sid in siblingOf[meId] ?? <String>{}) {
      if (nodeMap.containsKey(sid)) {
        myGen.add(sid);
        // 형제의 배우자도 포함
        for (final ssid in spouseOf[sid] ?? <String>{}) {
          if (nodeMap.containsKey(ssid)) myGen.add(ssid);
        }
      }
    }

    // ── 2줄: 부모 세대 ────────────────────────────────────────────────────
    final parentsGen = <String>{};
    final myParentIds = childToParents[meId] ?? <String>{};

    for (final pid in myParentIds) {
      if (nodeMap.containsKey(pid)) {
        parentsGen.add(pid);
        // 부모의 배우자 (다른 부/모)
        for (final sid in spouseOf[pid] ?? <String>{}) {
          if (nodeMap.containsKey(sid)) parentsGen.add(sid);
        }
        // 부모의 형제 (삼촌/이모)
        for (final sibId in siblingOf[pid] ?? <String>{}) {
          if (nodeMap.containsKey(sibId)) {
            parentsGen.add(sibId);
            // 삼촌/이모의 배우자
            for (final ssid in spouseOf[sibId] ?? <String>{}) {
              if (nodeMap.containsKey(ssid)) parentsGen.add(ssid);
            }
          }
        }
      }
    }

    // 부모 형제의 자녀 = 사촌 → 나 세대에 추가
    for (final pid in parentsGen) {
      // 부모 형제의 자녀 (내 부모 제외한 parentsGen 멤버의 자녀)
      if (!myParentIds.contains(pid)) {
        for (final cousinId in parentToChildren[pid] ?? <String>{}) {
          if (nodeMap.containsKey(cousinId) && !parentsGen.contains(cousinId)) {
            myGen.add(cousinId);
            // 사촌의 배우자
            for (final ssid in spouseOf[cousinId] ?? <String>{}) {
              if (nodeMap.containsKey(ssid)) myGen.add(ssid);
            }
          }
        }
      }
    }

    // ── 1줄: 조부모 세대 ──────────────────────────────────────────────────
    final grandparentsGen = <String>{};
    for (final pid in myParentIds) {
      for (final gpid in childToParents[pid] ?? <String>{}) {
        if (nodeMap.containsKey(gpid)) {
          grandparentsGen.add(gpid);
          // 조부모의 배우자
          for (final sid in spouseOf[gpid] ?? <String>{}) {
            if (nodeMap.containsKey(sid)) grandparentsGen.add(sid);
          }
        }
      }
    }

    // ── 4줄: 자녀 세대 ────────────────────────────────────────────────────
    final childrenGen = <String>{};
    for (final childId in parentToChildren[meId] ?? <String>{}) {
      if (nodeMap.containsKey(childId)) childrenGen.add(childId);
    }
    // 배우자의 자녀도 포함
    for (final sid in spouseOf[meId] ?? <String>{}) {
      for (final childId in parentToChildren[sid] ?? <String>{}) {
        if (nodeMap.containsKey(childId)) childrenGen.add(childId);
      }
    }

    // ── 세대 간 중복 제거 (우선순위: 나세대 > 부모 > 조부모 > 자녀) ──────
    // 나 세대에서 부모/조부모 제거
    myGen.removeAll(parentsGen);
    myGen.removeAll(grandparentsGen);
    // 자녀에서 나세대/부모 제거
    childrenGen.removeAll(myGen);
    childrenGen.removeAll(parentsGen);

    // ── 줄당 최대 수 제한 ─────────────────────────────────────────────────
    var gpList = _limitRow(grandparentsGen.toList(), meId, nodeMap);
    var pList = _limitRow(parentsGen.toList(), meId, nodeMap);
    final myList = _limitRow(myGen.toList(), meId, nodeMap, ensureId: meId);
    var cList = _limitRow(childrenGen.toList(), meId, nodeMap);

    // 총 10명 제한 (우선순위: 나세대 > 부모 > 자녀 > 조부모)
    var total = myList.length + pList.length + cList.length + gpList.length;
    if (total > _maxTotal) {
      final budget = _maxTotal - myList.length; // 나는 반드시 포함
      var pBudget = pList.length.clamp(0, budget);
      var cBudget = cList.length.clamp(0, (budget - pBudget));
      var gpBudget = gpList.length.clamp(0, (budget - pBudget - cBudget));
      gpList = gpList.take(gpBudget).toList();
      pList = pList.take(pBudget).toList();
      cList = cList.take(cBudget).toList();
    }

    final allIds = <String>{...gpList, ...pList, ...myList, ...cList};

    // 관련 엣지만 필터링
    final relevantEdges = edges
        .where((e) =>
            allIds.contains(e.fromNodeId) && allIds.contains(e.toNodeId))
        .toList();

    return FamilyGenerationLayout(
      grandparents: gpList,
      parents: pList,
      myGeneration: myList,
      children: cList,
      allIncludedIds: allIds,
      relevantEdges: relevantEdges,
    );
  }

  /// 줄당 최대 _maxPerRow 명으로 제한 (ensureId는 반드시 포함)
  List<String> _limitRow(
    List<String> ids,
    String meId,
    Map<String, NodeModel> nodeMap, {
    String? ensureId,
  }) {
    if (ids.length <= _maxPerRow) return ids;

    // ensureId가 있으면 반드시 포함
    if (ensureId != null && ids.contains(ensureId)) {
      ids.remove(ensureId);
      ids.insert(0, ensureId);
    }
    return ids.take(_maxPerRow).toList();
  }

  /// "나" 없을 때 폴백 — 전체 노드를 BFS로 세대 분류 (기존 로직 축소판)
  FamilyGenerationLayout _fallbackLayout() {
    // 모든 노드를 나 세대에 넣되, 최대 _maxPerRow * 4개만
    final limited = nodes.take(_maxPerRow * 4).toList();
    final ids = limited.map((n) => n.id).toSet();
    final relevantEdges = edges
        .where((e) => ids.contains(e.fromNodeId) && ids.contains(e.toNodeId))
        .toList();

    // 간단히 4줄로 나누기
    final perRow = (limited.length / 4).ceil().clamp(1, _maxPerRow);
    final rows = <List<String>>[];
    for (int i = 0; i < limited.length; i += perRow) {
      rows.add(limited
          .skip(i)
          .take(perRow)
          .map((n) => n.id)
          .toList());
    }

    return FamilyGenerationLayout(
      grandparents: rows.isNotEmpty ? rows[0] : [],
      parents: rows.length > 1 ? rows[1] : [],
      myGeneration: rows.length > 2 ? rows[2] : [],
      children: rows.length > 3 ? rows[3] : [],
      allIncludedIds: ids,
      relevantEdges: relevantEdges,
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ── 레이아웃 좌표 계산 ─────────────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════

  /// 같은 줄(row)에서 spouse 관계를 기반으로 커플 그룹을 감지한다.
  /// 반환: [[A, B], [C], [D, E]] 형태 — 커플은 함께, 싱글은 단독 그룹
  static List<List<String>> _groupCouplesBySpouse(
    List<String> row,
    Set<String> spousePairSet,
  ) {
    final visited = <String>{};
    final groups = <List<String>>[];

    for (final id in row) {
      if (visited.contains(id)) continue;
      visited.add(id);

      // 같은 줄에서 배우자 찾기
      String? spouseInRow;
      for (final otherId in row) {
        if (otherId == id || visited.contains(otherId)) continue;
        final pairKey1 = '$id|$otherId';
        final pairKey2 = '$otherId|$id';
        if (spousePairSet.contains(pairKey1) ||
            spousePairSet.contains(pairKey2)) {
          spouseInRow = otherId;
          break;
        }
      }

      if (spouseInRow != null) {
        visited.add(spouseInRow);
        groups.add([id, spouseInRow]);
      } else {
        groups.add([id]);
      }
    }
    return groups;
  }

  _LayoutResult _computeLayout(
    Size size,
    FamilyGenerationLayout family,
  ) {
    final positions = <String, Offset>{};
    final couplePairs = <(String, String)>[];

    // 실제 내용이 있는 줄만 수집
    final activeRows = <List<String>>[];
    if (family.grandparents.isNotEmpty) activeRows.add(family.grandparents);
    if (family.parents.isNotEmpty) activeRows.add(family.parents);
    if (family.myGeneration.isNotEmpty) activeRows.add(family.myGeneration);
    if (family.children.isNotEmpty) activeRows.add(family.children);

    if (activeRows.isEmpty) {
      return _LayoutResult(positions: positions, couplePairs: couplePairs);
    }

    // spouse 관계 쌍 빌드 (빠른 조회용)
    final spousePairSet = <String>{};
    for (final e in edges) {
      if (e.relation == RelationType.spouse) {
        spousePairSet.add('${e.fromNodeId}|${e.toNodeId}');
      }
    }

    const padding = 50.0;
    const titleReserved = 65.0;
    const bottomReserved = 40.0;
    final usableWidth = size.width - padding * 2;
    final usableHeight =
        size.height - padding * 2 - titleReserved - bottomReserved;
    final rowCount = activeRows.length;
    // 각 줄 높이: 노드(20) + 하이라이트(8) + 이름(15) + 여백 = 최소 80px
    final rowHeight = (usableHeight / rowCount).clamp(80.0, 140.0);
    final totalRowsHeight = rowHeight * rowCount;
    final startY = padding + titleReserved + (usableHeight - totalRowsHeight) / 2;

    // 인원 수에 따라 노드 크기 동적 계산 (간격 계산에 필요)
    final total = family.totalCount;
    final double nodeDiameter;
    if (total <= 7) {
      nodeDiameter = (style == ArtStyle.minimal ? 20.0 : 22.0) * 2;
    } else if (total <= 12) {
      nodeDiameter = (style == ArtStyle.minimal ? 16.0 : 18.0) * 2;
    } else {
      nodeDiameter = (style == ArtStyle.minimal ? 12.0 : 14.0) * 2;
    }

    for (int row = 0; row < rowCount; row++) {
      final rowIds = activeRows[row];
      if (rowIds.isEmpty) continue;

      final y = startY + rowHeight * row + rowHeight / 2;

      // 커플 그룹으로 분리
      final groups = _groupCouplesBySpouse(rowIds, spousePairSet);

      // 커플 쌍 기록
      for (final g in groups) {
        if (g.length == 2) {
          couplePairs.add((g[0], g[1]));
        }
      }

      // 그룹 내 간격(커플 사이): 좁게
      final coupleGap = nodeDiameter + 10;
      // 그룹 간 간격(다른 가족 단위): 넓게
      final groupGap = nodeDiameter * 2 + 30;

      // 전체 필요 너비 계산
      double totalWidth = 0;
      for (int gi = 0; gi < groups.length; gi++) {
        final g = groups[gi];
        // 그룹 내 너비: (멤버수 - 1) * coupleGap
        totalWidth += (g.length - 1) * coupleGap;
        // 그룹 간 간격
        if (gi < groups.length - 1) {
          totalWidth += groupGap;
        }
      }

      // 사용 가능 너비 내에서 중앙 배치 (스케일 적용)
      double scale = 1.0;
      if (totalWidth > usableWidth && totalWidth > 0) {
        scale = usableWidth / totalWidth;
      }

      final startX = padding + (usableWidth - totalWidth * scale) / 2;
      double curX = startX;

      for (int gi = 0; gi < groups.length; gi++) {
        final g = groups[gi];
        for (int mi = 0; mi < g.length; mi++) {
          positions[g[mi]] = Offset(curX, y);
          if (mi < g.length - 1) {
            curX += coupleGap * scale;
          }
        }
        if (gi < groups.length - 1) {
          curX += groupGap * scale;
        }
      }
    }

    return _LayoutResult(positions: positions, couplePairs: couplePairs);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ── 배경 장식 ──────────────────────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════

  void _drawBackgroundDecoration(Canvas canvas, Size size) {
    final rng = math.Random(42); // deterministic seed
    switch (style) {
      case ArtStyle.watercolor:
        // 수채화 얼룩 효과
        final paint = Paint()..style = PaintingStyle.fill;
        for (int i = 0; i < 6; i++) {
          paint.color = palette.accentColor.withAlpha(15 + rng.nextInt(15));
          final cx = rng.nextDouble() * size.width;
          final cy = rng.nextDouble() * size.height;
          final r = 40.0 + rng.nextDouble() * 80;
          canvas.drawCircle(Offset(cx, cy), r, paint);
        }
      case ArtStyle.hanji:
        // 한지 텍스처 — 미세한 가로 섬유선
        final paint = Paint()
          ..color = palette.nodeStroke.withAlpha(12)
          ..strokeWidth = 0.5;
        for (double y = 0;
            y < size.height;
            y += 3 + rng.nextDouble() * 4) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
        }
      case ArtStyle.modern:
        // 그리드 패턴
        final paint = Paint()
          ..color = const Color(0x0CFFFFFF)
          ..strokeWidth = 0.5;
        for (double x = 0; x < size.width; x += 30) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
        }
        for (double y = 0; y < size.height; y += 30) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
        }
      case ArtStyle.minimal:
        break; // 장식 없음
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ── 엣지(관계선) 그리기 ─────────────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════

  void _drawEdges(
    Canvas canvas,
    Size size,
    Map<String, Offset> layout,
    List<NodeEdge> relevantEdges,
  ) {
    final paint = Paint()
      ..color = palette.edgeColor
      ..strokeWidth = style == ArtStyle.minimal ? 1.0 : 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final edge in relevantEdges) {
      // 형제/자매 관계선 스킵
      if (edge.relation == RelationType.sibling) continue;
      // 배우자 관계선 스킵 (하트로 대체)
      if (edge.relation == RelationType.spouse) continue;

      final from = layout[edge.fromNodeId];
      final to = layout[edge.toNodeId];
      if (from == null || to == null) continue;

      switch (style) {
        case ArtStyle.watercolor:
          // 부드러운 베지어 곡선
          final dx = (to.dx - from.dx) * 0.3;
          final path = Path()
            ..moveTo(from.dx, from.dy)
            ..cubicTo(
                from.dx + dx, from.dy, to.dx - dx, to.dy, to.dx, to.dy);
          canvas.drawPath(path, paint);
        case ArtStyle.hanji:
          // 붓 터치 느낌 (두꺼운 선)
          paint.strokeWidth = 2.0;
          canvas.drawLine(from, to, paint);
          paint.strokeWidth = 1.5; // 복원
        case ArtStyle.modern:
          // 직교(orthogonal) 경로
          final midY = (from.dy + to.dy) / 2;
          final path = Path()
            ..moveTo(from.dx, from.dy)
            ..lineTo(from.dx, midY)
            ..lineTo(to.dx, midY)
            ..lineTo(to.dx, to.dy);
          canvas.drawPath(path, paint);
        case ArtStyle.minimal:
          canvas.drawLine(from, to, paint);
      }
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ── 커플 하트 그리기 (배우자 관계를 하트로 표현) ─────────────────────────
  // ══════════════════════════════════════════════════════════════════════════

  void _drawCoupleHearts(
    Canvas canvas,
    Map<String, Offset> layout,
    List<(String, String)> couplePairs,
  ) {
    for (final (idA, idB) in couplePairs) {
      final posA = layout[idA];
      final posB = layout[idB];
      if (posA == null || posB == null) continue;

      // 두 노드의 중간 지점
      final midX = (posA.dx + posB.dx) / 2;
      final midY = (posA.dy + posB.dy) / 2;

      final heartStyle = TextStyle(
        fontSize: 10,
        color: palette.accentColor.withAlpha(180),
      );
      final tp = TextPainter(
        text: TextSpan(text: '\u2665', style: heartStyle), // ♥
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(midX - tp.width / 2, midY - tp.height / 2),
      );
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ── 노드 그리기 ────────────────────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════

  void _drawNodes(
    Canvas canvas,
    Size size,
    Map<String, Offset> layout,
    FamilyGenerationLayout family,
  ) {
    // 인원 수에 따라 노드 크기 동적 조절
    final total = family.totalCount;
    final double nodeRadius;
    if (total <= 7) {
      nodeRadius = style == ArtStyle.minimal ? 20.0 : 22.0;
    } else if (total <= 12) {
      nodeRadius = style == ArtStyle.minimal ? 16.0 : 18.0;
    } else {
      nodeRadius = style == ArtStyle.minimal ? 12.0 : 14.0;
    }
    final nodeMap = {for (final n in nodes) n.id: n};
    final isMe = myNodeId;

    for (final entry in layout.entries) {
      final node = nodeMap[entry.key];
      if (node == null) continue;
      final pos = entry.value;
      final isMeNode = node.id == isMe;

      // 온도 기반 테두리 색상
      final tempColor = AppColors.tempColor(node.temperature);

      // "나" 노드 하이라이트 링
      if (isMeNode) {
        final highlightPaint = Paint()
          ..color = AppColors.primary.withAlpha(40)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, nodeRadius + 8, highlightPaint);

        final ringPaint = Paint()
          ..color = AppColors.primary.withAlpha(120)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawCircle(pos, nodeRadius + 5, ringPaint);
      }

      // 노드 배경
      final fillPaint = Paint()
        ..color = node.isGhost
            ? palette.nodeFill.withAlpha(80)
            : palette.nodeFill
        ..style = PaintingStyle.fill;

      // 테두리
      final strokePaint = Paint()
        ..color = node.isGhost
            ? palette.nodeStroke.withAlpha(100)
            : tempColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = isMeNode
            ? 2.5
            : (style == ArtStyle.minimal ? 1.5 : 2.0);

      // Ghost 노드 — 점선 효과
      if (node.isGhost) {
        strokePaint.strokeWidth = 1.5;
      }

      // 프로필 사진 존재 여부 확인
      final profileImage = nodeImages[node.id];

      switch (style) {
        case ArtStyle.watercolor:
          // 수채화 — 외곽 번짐 + 원
          canvas.drawCircle(
            pos,
            nodeRadius + 4,
            Paint()..color = tempColor.withAlpha(30),
          );
          canvas.drawCircle(pos, nodeRadius, fillPaint);
          if (profileImage != null) {
            _drawClippedImage(canvas, pos, nodeRadius, profileImage);
          }
          canvas.drawCircle(pos, nodeRadius, strokePaint);
        case ArtStyle.hanji:
          // 한지 — 원 + 두꺼운 붓 터치 테두리
          canvas.drawCircle(pos, nodeRadius, fillPaint);
          if (profileImage != null) {
            _drawClippedImage(canvas, pos, nodeRadius, profileImage);
          }
          strokePaint.strokeWidth = isMeNode ? 3.0 : 2.5;
          canvas.drawCircle(pos, nodeRadius, strokePaint);
        case ArtStyle.modern:
          // 모던 — 둥근 사각형
          final rect = RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: pos,
              width: nodeRadius * 2,
              height: nodeRadius * 2,
            ),
            const Radius.circular(8),
          );
          canvas.drawRRect(rect, fillPaint);
          if (profileImage != null) {
            _drawClippedImageRRect(canvas, pos, nodeRadius, 8.0, profileImage);
          }
          canvas.drawRRect(rect, strokePaint);
        case ArtStyle.minimal:
          // 미니멀 — 깔끔한 원
          canvas.drawCircle(pos, nodeRadius, fillPaint);
          if (profileImage != null) {
            _drawClippedImage(canvas, pos, nodeRadius, profileImage);
          }
          canvas.drawCircle(pos, nodeRadius, strokePaint);
      }

      // 이름 텍스트 (노드 아래)
      final nameText = isMeNode ? '${node.name} (나)' : node.name;
      final nameStyle = TextStyle(
        fontSize: style == ArtStyle.minimal ? 8 : 9,
        color: isMeNode
            ? palette.textColor
            : palette.textColor.withAlpha(200),
        fontWeight: isMeNode ? FontWeight.w700 : FontWeight.w500,
      );
      final tp = TextPainter(
        text: TextSpan(text: nameText, style: nameStyle),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '..',
      )..layout(maxWidth: nodeRadius * 3.5);
      tp.paint(
        canvas,
        Offset(pos.dx - tp.width / 2, pos.dy + nodeRadius + 3),
      );
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ── 프로필 사진 원형/RRect 클리핑 ─────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════

  /// 원형 클리핑으로 프로필 이미지를 그린다 (watercolor, hanji, minimal)
  void _drawClippedImage(
    Canvas canvas,
    Offset center,
    double radius,
    ui.Image image,
  ) {
    canvas.save();
    final clipPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.clipPath(clipPath);

    // 이미지를 정사각형 중앙 크롭하여 원 안에 맞춤
    final imgWidth = image.width.toDouble();
    final imgHeight = image.height.toDouble();
    final side = math.min(imgWidth, imgHeight);
    final srcRect = Rect.fromCenter(
      center: Offset(imgWidth / 2, imgHeight / 2),
      width: side,
      height: side,
    );
    final dstRect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawImageRect(
      image,
      srcRect,
      dstRect,
      Paint()..filterQuality = FilterQuality.medium,
    );
    canvas.restore();
  }

  /// 둥근 사각형 클리핑으로 프로필 이미지를 그린다 (modern 스타일)
  void _drawClippedImageRRect(
    Canvas canvas,
    Offset center,
    double radius,
    double cornerRadius,
    ui.Image image,
  ) {
    canvas.save();
    final rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: radius * 2,
        height: radius * 2,
      ),
      Radius.circular(cornerRadius),
    );
    canvas.clipRRect(rrect);

    final imgWidth = image.width.toDouble();
    final imgHeight = image.height.toDouble();
    final side = math.min(imgWidth, imgHeight);
    final srcRect = Rect.fromCenter(
      center: Offset(imgWidth / 2, imgHeight / 2),
      width: side,
      height: side,
    );
    final dstRect = Rect.fromCenter(
      center: center,
      width: radius * 2,
      height: radius * 2,
    );

    canvas.drawImageRect(
      image,
      srcRect,
      dstRect,
      Paint()..filterQuality = FilterQuality.medium,
    );
    canvas.restore();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ── 세대 라벨 ─────────────────────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════

  void _drawGenerationLabels(
    Canvas canvas,
    Size size,
    FamilyGenerationLayout family,
  ) {
    if (myNodeId == null) return;

    const padding = 50.0;
    const titleReserved = 65.0;
    const bottomReserved = 40.0;
    final usableHeight =
        size.height - padding * 2 - titleReserved - bottomReserved;

    final activeRows = <List<String>>[];
    final labels = <String>[];
    if (family.grandparents.isNotEmpty) {
      activeRows.add(family.grandparents);
      labels.add('조부모');
    }
    if (family.parents.isNotEmpty) {
      activeRows.add(family.parents);
      labels.add('부모');
    }
    if (family.myGeneration.isNotEmpty) {
      activeRows.add(family.myGeneration);
      labels.add('나');
    }
    if (family.children.isNotEmpty) {
      activeRows.add(family.children);
      labels.add('자녀');
    }

    if (activeRows.isEmpty) return;
    final rowHeight = (usableHeight / activeRows.length).clamp(80.0, 140.0);
    final totalRowsHeight = rowHeight * activeRows.length;
    final startY = padding + titleReserved + (usableHeight - totalRowsHeight) / 2;

    for (int i = 0; i < activeRows.length; i++) {
      final y = startY + rowHeight * i + rowHeight / 2;
      final labelStyle = TextStyle(
        fontSize: 8,
        color: palette.textColor.withAlpha(80),
        fontWeight: FontWeight.w400,
      );
      final tp = TextPainter(
        text: TextSpan(text: labels[i], style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(8, y - tp.height / 2));
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ── 타이틀 ─────────────────────────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════

  void _drawTitle(Canvas canvas, Size size, int count) {
    final titleStyle = TextStyle(
      fontSize: 18,
      color: palette.textColor,
      fontWeight: FontWeight.w700,
      letterSpacing: style == ArtStyle.hanji ? 3 : 0,
    );
    final tp = TextPainter(
      text: TextSpan(text: '우리 가족', style: titleStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset((size.width - tp.width) / 2, 20));

    // 노드 수 서브타이틀
    final subText = count > 0
        ? '$count명의 소중한 사람들'
        : '가족을 추가해보세요';
    final subStyle = TextStyle(
      fontSize: 11,
      color: palette.textColor.withAlpha(150),
    );
    final sub = TextPainter(
      text: TextSpan(text: subText, style: subStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    sub.paint(canvas, Offset((size.width - sub.width) / 2, 42));
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ── 워터마크 ───────────────────────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════

  void _drawWatermark(Canvas canvas, Size size) {
    final tp = TextPainter(
      text: TextSpan(
        text: 'Re-Link',
        style: TextStyle(
          fontSize: 12,
          color: palette.textColor.withAlpha(60),
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(size.width - tp.width - 16, size.height - tp.height - 12),
    );
  }

  @override
  bool shouldRepaint(ArtTreePainter oldDelegate) =>
      oldDelegate.nodes != nodes ||
      oldDelegate.edges != edges ||
      oldDelegate.style != style ||
      oldDelegate.myNodeId != myNodeId ||
      oldDelegate.showWatermark != showWatermark ||
      !_imagesEqual(oldDelegate.nodeImages, nodeImages);

  /// 두 이미지 맵이 같은 키와 같은 ui.Image 인스턴스를 갖는지 비교
  bool _imagesEqual(
    Map<String, ui.Image> a,
    Map<String, ui.Image> b,
  ) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || !identical(a[key], b[key])) return false;
    }
    return true;
  }
}
