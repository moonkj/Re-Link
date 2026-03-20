import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../shared/models/node_model.dart';
import '../../../design/tokens/app_colors.dart';
import '../models/art_card_config.dart';

/// 아트 카드용 가족트리 CustomPainter
class ArtTreePainter extends CustomPainter {
  const ArtTreePainter({
    required this.nodes,
    required this.edges,
    required this.style,
    required this.palette,
    this.showWatermark = true,
  });

  final List<NodeModel> nodes;
  final List<NodeEdge> edges;
  final ArtStyle style;
  final ArtPalette palette;
  final bool showWatermark;

  @override
  void paint(Canvas canvas, Size size) {
    if (nodes.isEmpty) return;

    // 배경
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = palette.background,
    );

    // 스타일별 배경 데코
    _drawBackgroundDecoration(canvas, size);

    // 노드 레이아웃 계산 (compact centered tree)
    final layout = _computeLayout(size);

    // 엣지 그리기
    _drawEdges(canvas, size, layout);

    // 노드 그리기
    _drawNodes(canvas, size, layout);

    // 타이틀
    _drawTitle(canvas, size);

    // 워터마크
    if (showWatermark) _drawWatermark(canvas, size);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ── 컴팩트 트리 레이아웃 계산 ──────────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════

  /// 노드들을 세대(generation) 기반으로 행/열 배치
  /// 캔버스 positionX/Y 무시 — 카드 사이즈에 맞춰 재계산
  Map<String, Offset> _computeLayout(Size size) {
    final positions = <String, Offset>{};
    if (nodes.isEmpty) return positions;

    // ── 1) 부부 쌍 찾기 ──────────────────────────────────────────────────
    final spousePairs = <String, String>{};
    for (final e in edges) {
      if (e.relation == RelationType.spouse) {
        spousePairs[e.fromNodeId] = e.toNodeId;
        spousePairs[e.toNodeId] = e.fromNodeId;
      }
    }

    // ── 2) 부모→자녀 인접 리스트 구성 ────────────────────────────────────
    final parentToChildren = <String, List<String>>{};
    for (final e in edges) {
      if (e.relation == RelationType.child ||
          e.relation == RelationType.parent) {
        final parentId =
            e.relation == RelationType.child ? e.fromNodeId : e.toNodeId;
        final childId =
            e.relation == RelationType.child ? e.toNodeId : e.fromNodeId;
        parentToChildren.putIfAbsent(parentId, () => []).add(childId);
      }
    }

    // ── 3) 루트 노드 찾기 (부모가 없는 노드) ────────────────────────────
    final allChildIds =
        parentToChildren.values.expand((v) => v).toSet();
    final rootIds = nodes
        .where((n) => !allChildIds.contains(n.id))
        .map((n) => n.id)
        .toList();
    if (rootIds.isEmpty) {
      // 순환 관계 — 첫 번째 노드를 루트로 사용
      rootIds.add(nodes.first.id);
    }

    // ── 4) BFS로 세대 할당 ───────────────────────────────────────────────
    final generations = <String, int>{};
    final queue = <String>[...rootIds];
    for (final id in rootIds) {
      generations[id] = 0;
    }
    final visited = <String>{...rootIds};

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      final gen = generations[current]!;

      // 자녀 → 다음 세대
      for (final childId in parentToChildren[current] ?? <String>[]) {
        if (!visited.contains(childId)) {
          generations[childId] = gen + 1;
          visited.add(childId);
          queue.add(childId);
        }
      }

      // 배우자 → 같은 세대
      final spouseId = spousePairs[current];
      if (spouseId != null && !visited.contains(spouseId)) {
        generations[spouseId] = gen;
        visited.add(spouseId);
        queue.add(spouseId);
      }
    }

    // 세대에 할당되지 않은 고립 노드
    for (final node in nodes) {
      if (!generations.containsKey(node.id)) {
        generations[node.id] = 0;
      }
    }

    // ── 5) 세대별 그룹핑 ─────────────────────────────────────────────────
    final genGroups = <int, List<String>>{};
    for (final entry in generations.entries) {
      genGroups.putIfAbsent(entry.value, () => []).add(entry.key);
    }

    // ── 6) 좌표 계산 ────────────────────────────────────────────────────
    final maxGen =
        genGroups.keys.isEmpty ? 0 : genGroups.keys.reduce(math.max);
    const padding = 60.0;
    const titleReserved = 60.0;
    final usableWidth = size.width - padding * 2;
    final usableHeight = size.height - padding * 2 - titleReserved;
    final rowHeight =
        maxGen > 0 ? usableHeight / (maxGen + 1) : usableHeight;

    for (int gen = 0; gen <= maxGen; gen++) {
      final group = genGroups[gen] ?? [];
      if (group.isEmpty) continue;
      final colWidth = usableWidth / group.length;
      for (int i = 0; i < group.length; i++) {
        positions[group[i]] = Offset(
          padding + colWidth * i + colWidth / 2,
          padding + titleReserved + rowHeight * gen + rowHeight / 2,
        );
      }
    }

    return positions;
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

  void _drawEdges(Canvas canvas, Size size, Map<String, Offset> layout) {
    final paint = Paint()
      ..color = palette.edgeColor
      ..strokeWidth = style == ArtStyle.minimal ? 1.0 : 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final edge in edges) {
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
  // ── 노드 그리기 ────────────────────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════

  void _drawNodes(Canvas canvas, Size size, Map<String, Offset> layout) {
    final nodeRadius = style == ArtStyle.minimal ? 22.0 : 26.0;
    final nodeMap = {for (final n in nodes) n.id: n};

    for (final entry in layout.entries) {
      final node = nodeMap[entry.key];
      if (node == null) continue;
      final pos = entry.value;

      // 온도 기반 테두리 색상
      final tempColor = AppColors.tempColor(node.temperature);

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
        ..strokeWidth = style == ArtStyle.minimal ? 1.5 : 2.0;

      // Ghost 노드 — 점선 효과
      if (node.isGhost) {
        strokePaint.strokeWidth = 1.5;
      }

      switch (style) {
        case ArtStyle.watercolor:
          // 수채화 — 외곽 번짐 + 원
          canvas.drawCircle(
            pos,
            nodeRadius + 4,
            Paint()..color = tempColor.withAlpha(30),
          );
          canvas.drawCircle(pos, nodeRadius, fillPaint);
          canvas.drawCircle(pos, nodeRadius, strokePaint);
        case ArtStyle.hanji:
          // 한지 — 원 + 두꺼운 붓 터치 테두리
          canvas.drawCircle(pos, nodeRadius, fillPaint);
          strokePaint.strokeWidth = 2.5;
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
          canvas.drawRRect(rect, strokePaint);
        case ArtStyle.minimal:
          // 미니멀 — 깔끔한 원
          canvas.drawCircle(pos, nodeRadius, fillPaint);
          canvas.drawCircle(pos, nodeRadius, strokePaint);
      }

      // 이름 텍스트 (노드 아래)
      final nameStyle = TextStyle(
        fontSize: style == ArtStyle.minimal ? 9 : 10,
        color: palette.textColor,
        fontWeight: FontWeight.w600,
      );
      final tp = TextPainter(
        text: TextSpan(text: node.name, style: nameStyle),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '..',
      )..layout(maxWidth: nodeRadius * 3);
      tp.paint(
        canvas,
        Offset(pos.dx - tp.width / 2, pos.dy + nodeRadius + 4),
      );
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ── 타이틀 ─────────────────────────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════

  void _drawTitle(Canvas canvas, Size size) {
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
    final subStyle = TextStyle(
      fontSize: 11,
      color: palette.textColor.withAlpha(150),
    );
    final sub = TextPainter(
      text: TextSpan(
        text: '${nodes.length}명의 소중한 사람들',
        style: subStyle,
      ),
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
      oldDelegate.showWatermark != showWatermark;
}
