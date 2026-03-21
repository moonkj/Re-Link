import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../shared/models/node_model.dart';
import '../../../design/tokens/app_colors.dart';
import 'node_card.dart';

/// 노드 간 관계선을 그리는 CustomPainter
/// Waypoint 기반 카드 회피 라우팅 + 레이블 후처리 렌더링
class EdgePainter extends CustomPainter {
  EdgePainter({
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

  /// 노드 센터 위치 캐시 — paint() 시작 시 구축, _centerOf()에서 O(1) 조회
  Map<String, Offset> _centerCache = {};

  @override
  void paint(Canvas canvas, Size size) {
    // 노드 센터 위치 캐시 구축 (O(1) 조회)
    _centerCache = <String, Offset>{};
    for (final node in nodes) {
      final id = node.id;
      if (id == draggingNodeId && draggingPosition != null) {
        _centerCache[id] = Offset(
          draggingPosition!.dx + kNodeCardWidth / 2,
          draggingPosition!.dy + kNodeCardHeight / 2,
        );
      } else {
        _centerCache[id] = Offset(
          node.positionX + kNodeCardWidth / 2,
          node.positionY + kNodeCardHeight / 2,
        );
      }
    }

    // 레이블 수집 리스트 — 선 그리기 후 일괄 렌더링
    final labels = <_LabelInfo>[];

    // ── 카드 영역 클리핑 (선이 카드 뒤로 가도록) ─────────────────────
    canvas.save();
    final clipPath = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    for (final node in nodes) {
      final center = _centerOf(node.id);
      if (center == null) continue;
      clipPath.addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center,
          width: kNodeCardWidth + 8,
          height: kNodeCardHeight + 8,
        ),
        const Radius.circular(16),
      ));
    }
    canvas.clipPath(clipPath);

    // ── 선 그리기 (카드 회피 라우팅) ────────────────────────────────────

    // 부부 엣지 수집
    final spouseEdges =
        edges.where((e) => e.relation == RelationType.spouse).toList();

    // 부모-자녀 엣지 정규화 (방향 통일: parentNodeId → childNodeId)
    final normalizedChildEdges = <_NormalizedChildEdge>[];
    for (final e in edges) {
      if (e.relation == RelationType.child) {
        normalizedChildEdges.add(_NormalizedChildEdge(
          edgeId: e.id,
          parentNodeId: e.fromNodeId,
          childNodeId: e.toNodeId,
        ));
      } else if (e.relation == RelationType.parent) {
        normalizedChildEdges.add(_NormalizedChildEdge(
          edgeId: e.id,
          parentNodeId: e.toNodeId,
          childNodeId: e.fromNodeId,
        ));
      }
    }

    final drawnChildEdgeIds = <String>{};
    final coupleChildSets = <Set<String>>[];

    // 각 부부 쌍에 대해 통합 자녀 선 처리
    for (final se in spouseEdges) {
      final p1 = _centerOf(se.fromNodeId);
      final p2 = _centerOf(se.toNodeId);
      if (p1 == null || p2 == null) continue;

      // 부부 선 그리기
      final p1Border = _borderPoint(p1, p2);
      final p2Border = _borderPoint(p2, p1);
      _drawSpouseLine(canvas, p1Border, p2Border, labels);

      // 부부 중앙점
      final spouseMidX = (p1Border.dx + p2Border.dx) / 2;
      final spouseMidY = (p1Border.dy + p2Border.dy) / 2;
      final coupleMid = Offset(spouseMidX, spouseMidY);

      // 이 부부의 자녀 찾기
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
      coupleChildSets.add(seenChildIds);

      // 부부→자녀 곡선 그리기
      _drawCoupleChildrenLine(canvas, coupleMid, childPositions, labels);
    }

    // 나머지 엣지 (통합 선으로 그려지지 않은 것들)
    for (final edge in edges) {
      if (edge.relation == RelationType.spouse) continue;
      if (drawnChildEdgeIds.contains(edge.id)) continue;

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
      _drawEdgeLine(canvas, from, to, edge.relation, labels);
    }

    // 연결 중인 임시 선
    if (connectingNodeId != null && pointerPosition != null) {
      final fromCenter = _centerOf(connectingNodeId!);
      if (fromCenter != null) {
        final from = _borderPoint(fromCenter, pointerPosition!);
        _drawDashedLine(canvas, from, pointerPosition!);
      }
    }

    canvas.restore();

    // ── 레이블 그리기 ──────────────────────────────────────────────────
    for (final label in labels) {
      _drawLabel(canvas, label.pos, label.text);
    }
  }

  // ── 선 그리기 메서드 (레이블은 수집만) ──────────────────────────────────

  /// 배우자 엣지 — 부드러운 아치형 곡선
  void _drawSpouseLine(
      Canvas canvas, Offset from, Offset to, List<_LabelInfo> labels) {
    final color = _edgeColor(RelationType.spouse);
    final paint = Paint()
      ..color = color.withAlpha(180)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final mid = _midPoint(from, to);
    final dist = (to - from).distance;
    final bow = dist * 0.15; // 거리의 15%만큼 위로 볼록
    final path = _curvePath(from, to);
    canvas.drawPath(path, paint);

    // 레이블: 아치 꼭대기 위쪽 (카드 사이가 아닌 아치 위)
    labels.add(_LabelInfo(
      pos: _safeLabelPos(Offset(mid.dx, mid.dy - bow - 10)),
      text: RelationType.spouse.label,
    ));
  }

  /// 일반 관계 엣지 — 베지어 곡선 + 노드 회피
  void _drawEdgeLine(Canvas canvas, Offset from, Offset to,
      RelationType relation, List<_LabelInfo> labels) {
    final color = _edgeColor(relation);
    final paint = Paint()
      ..color = color.withAlpha(180)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = _curvePath(from, to);
    canvas.drawPath(path, paint);

    // 레이블: 곡선 중간 (카드와 겹치지 않는 위치 탐색)
    final mid = _midPoint(from, to);
    labels.add(_LabelInfo(pos: _safeLabelPos(mid), text: relation.label));
  }

  /// 부부 중점에서 자녀들로 곡선 연결
  void _drawCoupleChildrenLine(
    Canvas canvas,
    Offset coupleMid,
    List<_ChildEdgeInfo> children,
    List<_LabelInfo> labels,
  ) {
    final color = _edgeColor(RelationType.child);
    final paint = Paint()
      ..color = color.withAlpha(180)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final childTopPositions = children
        .map((c) => _ChildEdgeInfo(
              pos: Offset(c.pos.dx, c.pos.dy - kNodeCardHeight / 2),
              edgeId: c.edgeId,
            ))
        .toList();

    bool labelCollected = false;
    for (final child in childTopPositions) {
      final to = child.pos;
      final path = _curvePath(coupleMid, to);
      canvas.drawPath(path, paint);

      if (!labelCollected) {
        final labelPos = Offset(
          (coupleMid.dx + to.dx) / 2,
          coupleMid.dy + (to.dy - coupleMid.dy) * 0.3,
        );
        labels.add(_LabelInfo(
          pos: _safeLabelPos(labelPos),
          text: RelationType.child.label,
        ));
        labelCollected = true;
      }
    }
  }

  // ── 유틸리티 ──────────────────────────────────────────────────────────

  /// 레이블 위치가 카드와 겹치면 위로 밀어서 안전한 위치 반환
  Offset _safeLabelPos(Offset pos) {
    for (final node in nodes) {
      final c = _centerOf(node.id);
      if (c == null) continue;
      final cardRect = Rect.fromCenter(
        center: c,
        width: kNodeCardWidth + 16,
        height: kNodeCardHeight + 16,
      );
      if (cardRect.contains(pos)) {
        // 카드 위쪽으로 밀기
        return Offset(pos.dx, cardRect.top - 12);
      }
    }
    return pos;
  }

  Offset? _centerOf(String nodeId) => _centerCache[nodeId];

  /// Waypoint 기반 경로 — 중간 카드 회피 라우팅
  Path _curvePath(Offset from, Offset to) {
    final lineVec = to - from;
    final lineLenSq = lineVec.dx * lineVec.dx + lineVec.dy * lineVec.dy;
    if (lineLenSq < 1) {
      return Path()..moveTo(from.dx, from.dy)..lineTo(to.dx, to.dy);
    }
    final lineLen = math.sqrt(lineLenSq);

    // 경로상 장애물(중간 카드) 탐색
    final obstacles = <_CardObstacle>[];
    for (final node in nodes) {
      final c = _centerOf(node.id);
      if (c == null) continue;

      // 출발/도착 노드 스킵
      if ((c - from).distance < kNodeCardWidth * 0.8) continue;
      if ((c - to).distance < kNodeCardWidth * 0.8) continue;

      // 카드 중심을 선분에 투영
      final toC = c - from;
      final t = (lineVec.dx * toC.dx + lineVec.dy * toC.dy) / lineLenSq;
      if (t < 0.02 || t > 0.98) continue;

      final proj = from + lineVec * t;
      final dxToCard = (proj.dx - c.dx).abs();
      final dyToCard = (proj.dy - c.dy).abs();

      // 카드 영역 + 여유(40px)에 걸리는지 확인
      const padX = kNodeCardWidth / 2 + 40;
      const padY = kNodeCardHeight / 2 + 40;
      if (dxToCard < padX && dyToCard < padY) {
        obstacles.add(_CardObstacle(center: c, projT: t));
      }
    }

    if (obstacles.isEmpty) {
      // 장애물 없음: 부드러운 S-커브
      final d = lineVec.dx * 0.3;
      return Path()
        ..moveTo(from.dx, from.dy)
        ..cubicTo(from.dx + d, from.dy, to.dx - d, to.dy, to.dx, to.dy);
    }

    // 투영 위치 순 정렬
    obstacles.sort((a, b) => a.projT.compareTo(b.projT));

    // 수직 단위 벡터
    final perpX = -lineVec.dy / lineLen;
    final perpY = lineVec.dx / lineLen;

    // 각 장애물마다 우회 웨이포인트 생성
    final waypoints = <Offset>[];
    for (final obs in obstacles) {
      final toC = obs.center - from;
      final cross = lineVec.dx * toC.dy - lineVec.dy * toC.dx;
      final sign = cross > 0 ? -1.0 : 1.0; // 카드 반대편으로 우회

      final proj = from + lineVec * obs.projT;
      final perpToCard = obs.center - proj;
      final perpDist = perpToCard.distance;
      // 카드 반대각선 절반 + 여유만큼 밀어냄
      final needed = math.max(110.0 - perpDist, 0.0) + 60.0;

      waypoints.add(Offset(
        proj.dx + perpX * needed * sign,
        proj.dy + perpY * needed * sign,
      ));
    }

    return _smoothPath([from, ...waypoints, to]);
  }

  /// 웨이포인트를 거치는 부드러운 베지어 경로
  Path _smoothPath(List<Offset> pts) {
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);

    if (pts.length == 2) {
      path.lineTo(pts.last.dx, pts.last.dy);
      return path;
    }
    if (pts.length == 3) {
      path.quadraticBezierTo(pts[1].dx, pts[1].dy, pts[2].dx, pts[2].dy);
      return path;
    }

    // 4+ 포인트: 중간점 연결 quadratic 체인
    var mid = _midPoint(pts[1], pts[2]);
    path.quadraticBezierTo(pts[1].dx, pts[1].dy, mid.dx, mid.dy);

    for (int i = 2; i < pts.length - 2; i++) {
      mid = _midPoint(pts[i], pts[i + 1]);
      path.quadraticBezierTo(pts[i].dx, pts[i].dy, mid.dx, mid.dy);
    }

    path.quadraticBezierTo(
      pts[pts.length - 2].dx, pts[pts.length - 2].dy,
      pts.last.dx, pts.last.dy,
    );
    return path;
  }

  void _drawDashedLine(Canvas canvas, Offset from, Offset to) {
    final paint = Paint()
      ..color = AppColors.primary.withAlpha(120)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashLen = 8.0;
    const gapLen = 5.0;
    final total = (to - from).distance;
    if (total < 1) return;
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
      !identical(oldDelegate.nodes, nodes) ||
      !identical(oldDelegate.edges, edges) ||
      oldDelegate.connectingNodeId != connectingNodeId ||
      oldDelegate.pointerPosition != pointerPosition ||
      oldDelegate.draggingNodeId != draggingNodeId ||
      oldDelegate.draggingPosition != draggingPosition;
}

// ── 헬퍼 클래스 ────────────────────────────────────────────────────────

/// 지연 렌더링용 레이블 정보
class _LabelInfo {
  const _LabelInfo({required this.pos, required this.text});
  final Offset pos;
  final String text;
}

/// 자녀 엣지 정보 (통합선 렌더링용)
class _ChildEdgeInfo {
  const _ChildEdgeInfo({required this.pos, required this.edgeId});
  final Offset pos;
  final String edgeId;
}

/// 경로상 장애물 카드 정보
class _CardObstacle {
  const _CardObstacle({required this.center, required this.projT});
  final Offset center;
  final double projT; // 선분 위 투영 위치 (0~1)
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
