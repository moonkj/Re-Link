/// BFS 세대 깊이 계산 + Pseudo-3D 변환값 유틸리티
library;

import '../../../shared/models/node_model.dart';

/// BFS로 각 노드의 세대 깊이를 계산한다.
/// 루트 노드(= 첫 번째 노드 or 지정 rootId)에서 몇 단계 떨어졌는지를 반환.
///
/// Returns: nodeId → depth (0 = root)
Map<String, int> computeGenerations({
  required List<NodeModel> nodes,
  required List<NodeEdge> edges,
  String? rootId,
}) {
  if (nodes.isEmpty) return {};

  final result = <String, int>{};
  final startId = rootId ?? nodes.first.id;

  // 무방향 인접 리스트 구성
  final adjacency = <String, List<String>>{
    for (final n in nodes) n.id: [],
  };
  for (final e in edges) {
    adjacency[e.fromNodeId]?.add(e.toNodeId);
    adjacency[e.toNodeId]?.add(e.fromNodeId);
  }

  // BFS
  final queue = <String>[startId];
  result[startId] = 0;
  while (queue.isNotEmpty) {
    final current = queue.removeAt(0);
    final depth = result[current]!;
    for (final neighbor in adjacency[current] ?? []) {
      if (!result.containsKey(neighbor)) {
        result[neighbor] = depth + 1;
        queue.add(neighbor);
      }
    }
  }

  // 연결되지 않은 노드 → depth 0
  for (final n in nodes) {
    result.putIfAbsent(n.id, () => 0);
  }

  return result;
}

/// 세대 깊이(depth) → Pseudo-3D 시각 변환값
/// depth 0(루트) → 가장 크고 불투명, depth 5+ → 작고 반투명
({double scale, double opacity, double translateY}) pseudo3dTransform(int depth) {
  final t = depth.clamp(0, 5) / 5.0; // 0.0 ~ 1.0
  return (
    scale: 1.0 - t * 0.10,      // 1.0 → 0.90
    opacity: 1.0 - t * 0.30,    // 1.0 → 0.70
    translateY: -t * 12.0,      // 0 → -12 (위로 물러남)
  );
}
