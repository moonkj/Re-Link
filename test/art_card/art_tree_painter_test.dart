import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/shared/models/node_model.dart';
import 'package:re_link/features/art_card/models/art_card_config.dart';
import 'package:re_link/features/art_card/widgets/art_tree_painter.dart';

/// 테스트용 NodeModel 생성 헬퍼
NodeModel _makeNode(String id, String name) => NodeModel(
      id: id,
      name: name,
      createdAt: DateTime(2024),
    );

/// 테스트용 NodeEdge 생성 헬퍼
NodeEdge _makeEdge(String from, String to, RelationType rel) => NodeEdge(
      id: '${from}_${to}',
      fromNodeId: from,
      toNodeId: to,
      relation: rel,
      createdAt: DateTime(2024),
    );

void main() {
  group('ArtTreePainter — "나" 기준 4세대 레이아웃', () {
    // ── 기본 가족 구조 ────────────────────────────────────────────────────
    // 할아버지 ── 할머니
    //      |
    //   아버지 ── 어머니    삼촌
    //      |
    //    나 ── 배우자      형
    //      |
    //    아들
    //
    final nodes = [
      _makeNode('gf', '할아버지'),
      _makeNode('gm', '할머니'),
      _makeNode('dad', '아버지'),
      _makeNode('mom', '어머니'),
      _makeNode('uncle', '삼촌'),
      _makeNode('me', '나'),
      _makeNode('spouse', '배우자'),
      _makeNode('bro', '형'),
      _makeNode('son', '아들'),
    ];

    final edges = [
      // 조부모 부부
      _makeEdge('gf', 'gm', RelationType.spouse),
      // 조부모 → 아버지 (child)
      _makeEdge('gf', 'dad', RelationType.child),
      // 조부모 → 삼촌 (child)
      _makeEdge('gf', 'uncle', RelationType.child),
      // 아버지-삼촌 형제
      _makeEdge('dad', 'uncle', RelationType.sibling),
      // 부모 부부
      _makeEdge('dad', 'mom', RelationType.spouse),
      // 아버지 → 나 (child)
      _makeEdge('dad', 'me', RelationType.child),
      // 아버지 → 형 (child)
      _makeEdge('dad', 'bro', RelationType.child),
      // 나-형 형제
      _makeEdge('me', 'bro', RelationType.sibling),
      // 나-배우자
      _makeEdge('me', 'spouse', RelationType.spouse),
      // 나 → 아들 (child)
      _makeEdge('me', 'son', RelationType.child),
    ];

    test('painter를 오류 없이 생성하고 paint 호출', () {
      final painter = ArtTreePainter(
        nodes: nodes,
        edges: edges,
        style: ArtStyle.watercolor,
        palette: ArtPalette.forStyle(ArtStyle.watercolor),
        myNodeId: 'me',
      );

      // Painting on a PictureRecorder should not throw
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      expect(
        () => painter.paint(canvas, const Size(400, 400)),
        returnsNormally,
      );
      recorder.endRecording();
    });

    test('shouldRepaint 올바르게 동작', () {
      final p1 = ArtTreePainter(
        nodes: nodes,
        edges: edges,
        style: ArtStyle.watercolor,
        palette: ArtPalette.forStyle(ArtStyle.watercolor),
        myNodeId: 'me',
      );
      final p2 = ArtTreePainter(
        nodes: nodes,
        edges: edges,
        style: ArtStyle.watercolor,
        palette: ArtPalette.forStyle(ArtStyle.watercolor),
        myNodeId: 'me',
      );
      final p3 = ArtTreePainter(
        nodes: nodes,
        edges: edges,
        style: ArtStyle.minimal,
        palette: ArtPalette.forStyle(ArtStyle.minimal),
        myNodeId: 'me',
      );

      // Same params → no repaint needed
      expect(p1.shouldRepaint(p2), false);
      // Different style → repaint needed
      expect(p1.shouldRepaint(p3), true);
    });

    test('myNodeId 없으면 fallback 레이아웃으로 paint 성공', () {
      final painter = ArtTreePainter(
        nodes: nodes,
        edges: edges,
        style: ArtStyle.modern,
        palette: ArtPalette.forStyle(ArtStyle.modern),
        myNodeId: null,
      );

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      expect(
        () => painter.paint(canvas, const Size(400, 400)),
        returnsNormally,
      );
      recorder.endRecording();
    });

    test('빈 노드 목록으로 paint 호출 시 크래시 없음', () {
      final painter = ArtTreePainter(
        nodes: const [],
        edges: const [],
        style: ArtStyle.hanji,
        palette: ArtPalette.forStyle(ArtStyle.hanji),
        myNodeId: 'me',
      );

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      expect(
        () => painter.paint(canvas, const Size(400, 400)),
        returnsNormally,
      );
      recorder.endRecording();
    });

    test('4가지 스타일 모두 크래시 없이 렌더링', () {
      for (final artStyle in ArtStyle.values) {
        final painter = ArtTreePainter(
          nodes: nodes,
          edges: edges,
          style: artStyle,
          palette: ArtPalette.forStyle(artStyle),
          myNodeId: 'me',
        );

        final recorder = PictureRecorder();
        final canvas = Canvas(recorder);
        expect(
          () => painter.paint(canvas, const Size(400, 400)),
          returnsNormally,
          reason: '${artStyle.name} 스타일 렌더링 실패',
        );
        recorder.endRecording();
      }
    });

    test('워터마크 on/off 모두 정상', () {
      for (final wm in [true, false]) {
        final painter = ArtTreePainter(
          nodes: nodes,
          edges: edges,
          style: ArtStyle.watercolor,
          palette: ArtPalette.forStyle(ArtStyle.watercolor),
          myNodeId: 'me',
          showWatermark: wm,
        );

        final recorder = PictureRecorder();
        final canvas = Canvas(recorder);
        expect(
          () => painter.paint(canvas, const Size(400, 400)),
          returnsNormally,
        );
        recorder.endRecording();
      }
    });

    test('존재하지 않는 myNodeId로 paint 호출 시 크래시 없음', () {
      final painter = ArtTreePainter(
        nodes: nodes,
        edges: edges,
        style: ArtStyle.watercolor,
        palette: ArtPalette.forStyle(ArtStyle.watercolor),
        myNodeId: 'non_existent_id',
      );

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      expect(
        () => painter.paint(canvas, const Size(400, 400)),
        returnsNormally,
      );
      recorder.endRecording();
    });

    test('단독 노드(관계 없음)로 paint 성공', () {
      final singleNode = [_makeNode('only', '혼자')];
      final painter = ArtTreePainter(
        nodes: singleNode,
        edges: const [],
        style: ArtStyle.minimal,
        palette: ArtPalette.forStyle(ArtStyle.minimal),
        myNodeId: 'only',
      );

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      expect(
        () => painter.paint(canvas, const Size(400, 400)),
        returnsNormally,
      );
      recorder.endRecording();
    });
  });
}
