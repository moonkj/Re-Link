import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../shared/models/node_model.dart';
import '../../../design/tokens/app_colors.dart';
import 'node_card.dart';

/// 노드 간 관계선을 그리는 CustomPainter
class EdgePainter extends CustomPainter {
  const EdgePainter({
    required this.nodes,
    required this.edges,
    this.connectingNodeId,
    this.pointerPosition,
    this.draggingNodeId,
    this.draggingPosition,
  });

  final List<NodeModel> nodes;
  final List<NodeEdge> edges;

  /// 연결 모드 중인 노드 (현재 드래그 중)
  final String? connectingNodeId;

  /// 연결 모드에서 포인터 위치 (임시 선)
  final Offset? pointerPosition;

  /// 드래그 중인 노드 ID와 실시간 좌표 (엣지 실시간 추적)
  final String? draggingNodeId;
  final Offset? draggingPosition;

  @override
  void paint(Canvas canvas, Size size) {
    // 부부 엣지 수집
    final spouseEdges =
        edges.where((e) => e.relation == RelationType.spouse).toList();

    // 부모-자녀 엣지 정규화 (방향 통일: parentNodeId → childNodeId)
    // child 타입: fromNodeId=parent, toNodeId=child (관례)
    // parent 타입: fromNodeId=child, toNodeId=parent (역방향)
    final normalizedChildEdges = <_NormalizedChildEdge>[];
    for (final e in edges) {
      if (e.relation == RelationType.child) {
        // 양방향 대응: coupleIds에 포함된 쪽이 parent
        normalizedChildEdges.add(_NormalizedChildEdge(
          edgeId: e.id,
          parentNodeId: e.fromNodeId,
          childNodeId: e.toNodeId,
        ));
      } else if (e.relation == RelationType.parent) {
        // parent 타입: fromNodeId=child, toNodeId=parent → 방향 스왑
        normalizedChildEdges.add(_NormalizedChildEdge(
          edgeId: e.id,
          parentNodeId: e.toNodeId,
          childNodeId: e.fromNodeId,
        ));
      }
    }

    final drawnChildEdgeIds = <String>{};

    // 부부별 자녀 ID 세트 (같은 부모 밑 형제/자매 sibling 중복선 방지용)
    final coupleChildSets = <Set<String>>[];

    // 각 부부 쌍에 대해 통합 자녀 선 처리
    for (final se in spouseEdges) {
      final p1 = _centerOf(se.fromNodeId);
      final p2 = _centerOf(se.toNodeId);
      if (p1 == null || p2 == null) continue;

      // 부부 선 그리기 — 카드 외곽 간 직선
      final p1Border = _borderPoint(p1, p2);
      final p2Border = _borderPoint(p2, p1);
      _drawStraightEdge(canvas, p1Border, p2Border, RelationType.spouse);

      // 부부 중앙점 — 배우자 경계선의 중간점에서 아래로 내림
      final spouseMidX = (p1Border.dx + p2Border.dx) / 2;
      final spouseMidY = (p1Border.dy + p2Border.dy) / 2;
      final coupleMid = Offset(spouseMidX, spouseMidY);

      // 이 부부의 자녀 찾기 (양방향 + parent 타입 포함)
      final coupleIds = {se.fromNodeId, se.toNodeId};
      final coupleChildren = normalizedChildEdges
          .where((ce) => coupleIds.contains(ce.parentNodeId))
          .toList();

      if (coupleChildren.isEmpty) continue;

      // 자녀 위치 수집 (동일 자녀 중복 방지)
      final childPositions = <_ChildEdgeInfo>[];
      final seenChildIds = <String>{};
      for (final ce in coupleChildren) {
        if (seenChildIds.contains(ce.childNodeId)) {
          // 동일 자녀의 중복 엣지 (양쪽 부모 각각) → 처리 완료 표시만
          drawnChildEdgeIds.add(ce.edgeId);
          continue;
        }
        final childPos = _centerOf(ce.childNodeId);
        if (childPos == null) continue;
        drawnChildEdgeIds.add(ce.edgeId);
        seenChildIds.add(ce.childNodeId);
        childPositions.add(_ChildEdgeInfo(pos: childPos, edgeId: ce.edgeId));
      }

      if (childPositions.isEmpty) continue;

      // 이 부부의 자녀 ID 세트 저장 (sibling 중복선 판별용)
      coupleChildSets.add(seenChildIds);

      // T-shape 통합 관계선 그리기
      _drawCoupleChildrenLine(canvas, coupleMid, childPositions);
    }

    // 나머지 엣지 (통합 선으로 그려지지 않은 것들)
    for (final edge in edges) {
      if (edge.relation == RelationType.spouse) continue; // 이미 그림
      if (drawnChildEdgeIds.contains(edge.id)) continue; // 통합 선으로 그림

      // 같은 부부의 자녀끼리 sibling 엣지는 skip
      // (T-shape 통합선이 이미 형제 관계를 시각적으로 표현하므로 중복 방지)
      if (edge.relation == RelationType.sibling) {
        final isSameCoupleSiblings = coupleChildSets.any((childSet) =>
            childSet.contains(edge.fromNodeId) &&
            childSet.contains(edge.toNodeId));
        if (isSameCoupleSiblings) continue;
      }

      final fromCenter = _centerOf(edge.fromNodeId);
      final toCenter = _centerOf(edge.toNodeId);
      if (fromCenter == null || toCenter == null) continue;
      final from = _borderPoint(fromCenter, toCenter);
      final to = _borderPoint(toCenter, fromCenter);
      _drawEdge(canvas, from, to, edge.relation);
    }

    // 연결 중인 임시 선 (카드 외곽에서 출발)
    if (connectingNodeId != null && pointerPosition != null) {
      final fromCenter = _centerOf(connectingNodeId!);
      if (fromCenter != null) {
        final from = _borderPoint(fromCenter, pointerPosition!);
        _drawDashedLine(canvas, from, pointerPosition!);
      }
    }
  }

  /// 부부 중점에서 자녀들로 T-shape 통합선 그리기
  ///
  /// 구조:
  /// ```
  ///   [부모A] ---- coupleMid ---- [부모B]
  ///                    |
  ///                    | (수직 하강선)
  ///                    |
  ///          +---------+---------+  (수평 분기선)
  ///          |         |         |
  ///       [자녀1]   [자녀2]   [자녀3]
  /// ```
  void _drawCoupleChildrenLine(
    Canvas canvas,
    Offset coupleMid,
    List<_ChildEdgeInfo> children,
  ) {
    final color = _edgeColor(RelationType.child);
    final paint = Paint()
      ..color = color.withAlpha(180)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 자녀 카드 상단 좌표로 변환
    final childTopPositions = children
        .map((c) => _ChildEdgeInfo(
              pos: Offset(c.pos.dx, c.pos.dy - kNodeCardHeight / 2),
              edgeId: c.edgeId,
            ))
        .toList();

    if (childTopPositions.length == 1) {
      // 자녀가 1명: 직선 경로 (수직 → 수평 → 수직)
      final childTop = childTopPositions.first.pos;
      final midY = coupleMid.dy + (childTop.dy - coupleMid.dy) * 0.5;
      // 수직 하강
      canvas.drawLine(coupleMid, Offset(coupleMid.dx, midY), paint);
      // 수평 이동
      canvas.drawLine(
          Offset(coupleMid.dx, midY), Offset(childTop.dx, midY), paint);
      // 수직 하강
      canvas.drawLine(Offset(childTop.dx, midY), childTop, paint);
      final labelY = (coupleMid.dy + midY) / 2;
      _drawLabel(canvas, Offset(coupleMid.dx, labelY), RelationType.child.label);
      return;
    }

    // 자녀가 2명 이상: T-shape 구조
    // 자녀 카드 상단 중 가장 위에 있는 Y 좌표
    final childMinY =
        childTopPositions.map((c) => c.pos.dy).reduce(math.min);

    // 수직 하강 높이: 부부 중점과 자녀 사이의 중간 지점
    final branchY = coupleMid.dy + (childMinY - coupleMid.dy) * 0.5;

    // 1) 부부 중점에서 수직 하강
    canvas.drawLine(coupleMid, Offset(coupleMid.dx, branchY), paint);

    // 2) 수평 분기선 (coupleMid.dx 포함하여 좌측~우측 범위)
    final allXs = [
      ...childTopPositions.map((c) => c.pos.dx),
      coupleMid.dx,
    ];
    allXs.sort();
    final leftX = allXs.first;
    final rightX = allXs.last;
    canvas.drawLine(Offset(leftX, branchY), Offset(rightX, branchY), paint);

    // 3) 수평 분기선에서 각 자녀 카드 상단으로 수직 하강
    for (final child in childTopPositions) {
      canvas.drawLine(
        Offset(child.pos.dx, branchY),
        child.pos,
        paint,
      );
    }

    // 레이블: 수직선 중간에 한 번만
    final labelPos = Offset(coupleMid.dx, (coupleMid.dy + branchY) / 2);
    _drawLabel(canvas, labelPos, RelationType.child.label);
  }

  Offset? _centerOf(String nodeId) {
    final node = nodes.where((n) => n.id == nodeId).firstOrNull;
    if (node == null) return null;

    // 드래그 중인 노드는 실시간 좌표 사용
    if (nodeId == draggingNodeId && draggingPosition != null) {
      return Offset(
        draggingPosition!.dx + kNodeCardWidth / 2,
        draggingPosition!.dy + kNodeCardHeight / 2,
      );
    }

    return Offset(
      node.positionX + kNodeCardWidth / 2,
      node.positionY + kNodeCardHeight / 2,
    );
  }

  /// 직선 엣지 (배우자/구조선용 — 끊김 없음)
  void _drawStraightEdge(
      Canvas canvas, Offset from, Offset to, RelationType relation) {
    final color = _edgeColor(relation);
    final paint = Paint()
      ..color = color.withAlpha(180)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(from, to, paint);
    final mid = _midPoint(from, to);
    _drawLabel(canvas, mid, relation.label);
  }

  void _drawEdge(
      Canvas canvas, Offset from, Offset to, RelationType relation) {
    final color = _edgeColor(relation);
    final paint = Paint()
      ..color = color.withAlpha(180)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = _curvePath(from, to);
    canvas.drawPath(path, paint);

    // 관계 레이블 (중앙)
    final mid = _midPoint(from, to);
    _drawLabel(canvas, mid, relation.label);
  }

  /// 베지어 곡선 경로
  Path _curvePath(Offset from, Offset to) {
    final dx = (to.dx - from.dx) * 0.4;
    final cp1 = Offset(from.dx + dx, from.dy);
    final cp2 = Offset(to.dx - dx, to.dy);
    return Path()
      ..moveTo(from.dx, from.dy)
      ..cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, to.dx, to.dy);
  }

  void _drawDashedLine(Canvas canvas, Offset from, Offset to) {
    final paint = Paint()
      ..color = AppColors.primary.withAlpha(120)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashLen = 8.0;
    const gapLen = 5.0;
    final total = (to - from).distance;
    final dir = (to - from) / total;
    double d = 0;
    while (d < total) {
      final start = from + dir * d;
      final end = from + dir * (d + dashLen).clamp(0, total);
      canvas.drawLine(start, end, paint);
      d += dashLen + gapLen;
    }
  }

  void _drawLabel(Canvas canvas, Offset pos, String label) {
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: 10,
          color: AppColors.isDark ? Colors.white60 : Colors.black54,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // 배경
    final bgRect = Rect.fromCenter(
      center: pos,
      width: tp.width + 8,
      height: tp.height + 4,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(4)),
      Paint()
        ..color =
            AppColors.isDark ? const Color(0xCC0D1117) : const Color(0xCCFFFFFF),
    );

    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  /// 카드 중심에서 대상 방향으로의 카드 외곽 교차점 계산
  /// center: 노드 카드의 중심, target: 연결 대상 위치
  /// → 카드 사각형 외곽선의 교차점 반환
  Offset _borderPoint(Offset center, Offset target) {
    final dx = target.dx - center.dx;
    final dy = target.dy - center.dy;
    if (dx == 0 && dy == 0) return center;

    const halfW = kNodeCardWidth / 2;
    const halfH = kNodeCardHeight / 2;

    final scaleX = dx != 0 ? halfW / dx.abs() : double.infinity;
    final scaleY = dy != 0 ? halfH / dy.abs() : double.infinity;
    final scale = math.min(scaleX, scaleY);

    return Offset(center.dx + dx * scale, center.dy + dy * scale);
  }

  Offset _midPoint(Offset a, Offset b) =>
      Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);

  Color _edgeColor(RelationType relation) => switch (relation) {
        RelationType.parent => AppColors.secondary,
        RelationType.child => AppColors.secondary,
        RelationType.spouse => AppColors.accent,
        RelationType.sibling => AppColors.primary,
        RelationType.other =>
          AppColors.isDark ? Colors.white38 : Colors.black38,
      };

  @override
  bool shouldRepaint(EdgePainter oldDelegate) =>
      oldDelegate.nodes != nodes ||
      oldDelegate.edges != edges ||
      oldDelegate.connectingNodeId != connectingNodeId ||
      oldDelegate.pointerPosition != pointerPosition ||
      oldDelegate.draggingNodeId != draggingNodeId ||
      oldDelegate.draggingPosition != draggingPosition;
}

/// 자녀 엣지 정보 (통합선 렌더링용)
class _ChildEdgeInfo {
  const _ChildEdgeInfo({required this.pos, required this.edgeId});
  final Offset pos;
  final String edgeId;
}

/// 정규화된 부모-자녀 엣지 (방향 통일: parent → child)
class _NormalizedChildEdge {
  const _NormalizedChildEdge({
    required this.edgeId,
    required this.parentNodeId,
    required this.childNodeId,
  });
  final String edgeId;
  final String parentNodeId;
  final String childNodeId;
}
