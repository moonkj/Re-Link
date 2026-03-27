import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/router/app_router.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../design/glass/app_glass.dart';
import '../../../shared/models/node_model.dart';
import '../providers/canvas_notifier.dart';
import '../providers/node_notifier.dart';
import '../widgets/node_card.dart';
import '../widgets/edge_painter.dart';
import '../widgets/add_node_sheet.dart';
import '../widgets/node_detail_sheet.dart';
import '../widgets/relation_picker_sheet.dart';
import '../widgets/time_slider.dart';
import '../widgets/time_event_toast.dart';
import '../widgets/minimap_widget.dart';
import '../../../core/utils/haptic_service.dart';
import 'family_list_view.dart';
import '../../settings/providers/spouse_snap_notifier.dart';
import '../../streak/providers/streak_notifier.dart';
import '../../streak/widgets/streak_badge.dart';
import '../../prompt/widgets/daily_prompt_card.dart';
import '../../holiday/widgets/holiday_banner.dart';
import '../../holiday/providers/holiday_notifier.dart';
import '../../badges/providers/badge_notifier.dart';
import '../../badges/widgets/badge_earned_dialog.dart';
import '../providers/my_node_provider.dart';
import '../../bouquet/providers/bouquet_notifier.dart';
import '../../tree_growth/widgets/tree_growth_overlay.dart';
import '../utils/quad_tree.dart';
import '../utils/lod_utils.dart';
import '../utils/generation_utils.dart';
import '../../settings/providers/reduce_motion_notifier.dart';

/// 무한 캔버스 메인 화면
class CanvasScreen extends ConsumerStatefulWidget {
  const CanvasScreen({super.key});

  @override
  ConsumerState<CanvasScreen> createState() => _CanvasScreenState();
}

/// 뷰포트 여백 — 카드가 경계 근처에서 팝인되지 않도록 버퍼
const double _kViewportMargin = 200.0;

class _CanvasScreenState extends ConsumerState<CanvasScreen>
    with SingleTickerProviderStateMixin {
  final TransformationController _transformCtrl = TransformationController();

  /// 캔버스 내보내기용 RepaintBoundary 키
  final GlobalKey _canvasRepaintKey = GlobalKey();

  /// 내보내기 진행 중 상태
  bool _isExporting = false;

  /// FAB 브리딩 애니메이션 컨트롤러
  late final AnimationController _fabBreathCtrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  /// 드래그 중인 노드 ID
  String? _draggingId;

  /// 드래그 중인 노드의 실시간 좌표 (EdgePainter용)
  Offset? _draggingPos;

  /// 겹치는 노드 자동 분산 — 마지막으로 분산 처리한 노드 수
  int _lastSpreadNodeCount = 0;

  /// spread 디바운스 타이머 (일괄 삽입 시 연속 호출 방지)
  Timer? _spreadDebouncer;

  /// Time Slider 이벤트 토스트 메시지
  String? _timeEventMessage;

  /// 이전 Time Slider 연도 (변경 감지용)
  int? _prevTimeSliderYear;

  /// 목록 보기 모드 (false = 캔버스, true = 카드 목록)
  bool _isListView = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _resetZoom();
      // 스트릭 상태 확인 (앱 진입 시) — 에러 흡수하여 블랙 스크린 방지
      try {
        ref.read(streakNotifierProvider.notifier).checkStreak().catchError((_) {});
      } catch (_) {
        // provider 초기화 미완료 시 무시
      }
      // 배지 조건 확인 (앱 진입 시)
      try {
        ref.read(badgeNotifierProvider.notifier).checkAndAward().then((newBadges) {
          if (newBadges.isNotEmpty && mounted) {
            showDialog(
              context: context,
              builder: (_) => BadgeEarnedDialog(badge: newBadges.first),
            );
          }
        }).catchError((_) {});
      } catch (_) {}
    });
  }

  /// 연결 모드 포인터 위치 (캔버스 좌표)
  Offset? _connectPointer;

  /// 현재 뷰포트에 보이는 노드 (QuadTree 쿼리 결과)
  List<NodeModel> _visibleNodes = [];

  /// BFS 세대 깊이 캐시 (노드/엣지 변경 시 갱신)
  Map<String, int> _generations = {};

  /// computeGenerations 입력 캐시 (동일 입력이면 재계산 스킵)
  List<NodeModel>? _lastGenNodes;
  List<NodeEdge>? _lastGenEdges;

  @override
  void dispose() {
    _spreadDebouncer?.cancel();
    _fabBreathCtrl.dispose();
    _transformCtrl.dispose();
    super.dispose();
  }

  /// 노드 목록이 바뀔 때만 QuadTree를 재빌드 (캐시)
  List<NodeModel>? _qtSourceNodes;
  QuadTree<NodeModel>? _cachedQt;

  QuadTree<NodeModel> _getQuadTree(List<NodeModel> nodes) {
    if (_qtSourceNodes != nodes) {
      _qtSourceNodes = nodes;
      _cachedQt = QuadTree<NodeModel>(
        const QRect(left: 0, top: 0, right: 4000, bottom: 4000),
      );
      for (final node in nodes) {
        _cachedQt!.insert(node, node.positionX, node.positionY);
      }
    }
    return _cachedQt!;
  }

  /// 뷰포트 내 가시 노드를 QuadTree로 계산 (매 pan/zoom 프레임)
  void _updateVisibleNodes(
    List<NodeModel> nodes,
    Size screenSize,
  ) {
    final matrix = _transformCtrl.value;
    final scale = matrix.getMaxScaleOnAxis();
    final tx = matrix.getTranslation();

    final vpLeft = -tx.x / scale - _kViewportMargin;
    final vpTop = -tx.y / scale - _kViewportMargin;
    final vpRight = vpLeft + screenSize.width / scale + _kViewportMargin * 2;
    final vpBottom = vpTop + screenSize.height / scale + _kViewportMargin * 2;

    _visibleNodes = _getQuadTree(nodes).query(
      QRect(left: vpLeft, top: vpTop, right: vpRight, bottom: vpBottom),
    );
  }

  /// 겹치는 노드들을 쌍별(pair-wise) 감지 후 자동 분산
  /// 노드 추가/삭제 시마다 재실행됨
  Future<void> _spreadOverlappingNodes(List<NodeModel> nodes) async {
    if (nodes.length <= 1) return;

    // 카드 크기 + 최소 간격
    const minDx = 140.0; // kNodeCardWidth(110) + 30
    const minDy = 160.0; // kNodeCardHeight(130) + 30

    // 위치 복사
    final pos = {for (final n in nodes) n.id: Offset(n.positionX, n.positionY)};

    // 노드 수에 따라 라운드 제한 (성능 최적화)
    final maxRounds = nodes.length > 30 ? 5 : (nodes.length > 15 ? 10 : 20);
    bool changed = false;
    for (int round = 0; round < maxRounds; round++) {
      bool roundMoved = false;
      for (int i = 0; i < nodes.length; i++) {
        for (int j = i + 1; j < nodes.length; j++) {
          final a = pos[nodes[i].id]!;
          final b = pos[nodes[j].id]!;
          final dx = a.dx - b.dx;
          final dy = a.dy - b.dy;

          if (dx.abs() < minDx && dy.abs() < minDy) {
            // 수평 분리 (비례 마진)
            final pushX = (minDx - dx.abs()) / 2 * 1.15;
            final signX = dx.abs() < 1 ? (i.isEven ? 1.0 : -1.0) : (dx >= 0 ? 1.0 : -1.0);
            pos[nodes[i].id] = Offset(
              (a.dx + signX * pushX).clamp(100.0, 3800.0),
              a.dy,
            );
            pos[nodes[j].id] = Offset(
              (b.dx - signX * pushX).clamp(100.0, 3800.0),
              b.dy,
            );

            // 수직으로도 너무 가까우면 Y축도 분리
            if (dy.abs() < minDy / 2) {
              final pushY = (minDy - dy.abs()) / 4 * 1.15;
              final signY = dy.abs() < 1 ? 1.0 : (dy >= 0 ? 1.0 : -1.0);
              pos[nodes[i].id] = Offset(
                pos[nodes[i].id]!.dx,
                (a.dy + signY * pushY).clamp(100.0, 3800.0),
              );
              pos[nodes[j].id] = Offset(
                pos[nodes[j].id]!.dx,
                (b.dy - signY * pushY).clamp(100.0, 3800.0),
              );
            }

            roundMoved = true;
            changed = true;
          }
        }
      }
      if (!roundMoved) break;
    }

    if (!changed) return;

    // 일괄 저장 — 트랜잭션 1회로 리빌드 폭풍 방지
    final batchPos = <String, Offset>{};
    for (final n in nodes) {
      final p = pos[n.id]!;
      if ((p.dx - n.positionX).abs() > 1 || (p.dy - n.positionY).abs() > 1) {
        batchPos[n.id] = p;
      }
    }
    if (batchPos.isNotEmpty) {
      await ref.read(canvasNotifierProvider.notifier).batchSavePositions(batchPos);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canvasState = ref.watch(canvasNotifierProvider);
    final nodes = canvasState.nodes;
    final edges = canvasState.edges;
    final isConnectMode = canvasState.isConnectMode;

    // 배지 데이터 (획득 배지 ID 세트)
    final earnedBadges = ref.watch(badgeNotifierProvider).valueOrNull ?? [];
    final earnedBadgeIds = earnedBadges.map((b) => b.id).toList();

    // 명절 상태 — 오늘이 명절(또는 7일 이내)이면 조상 노드 glow 활성화
    final holidayState = ref.watch(holidayNotifierProvider).valueOrNull;
    final isHolidayActive = holidayState != null && holidayState.hasHoliday;

    // "나" 노드 ID
    final myNodeId = ref.watch(myNodeNotifierProvider).valueOrNull;

    // "나" 노드의 읽지 않은 마음 수
    final myUnreadCount = myNodeId != null
        ? ref.watch(unreadBouquetCountProvider(myNodeId)).valueOrNull ?? 0
        : 0;

    final reduceMotion = ref.watch(reduceMotionNotifierProvider).valueOrNull ?? false;

    // FAB 호흡 애니메이션 — 모션 줄이기 시 중단
    if (reduceMotion) {
      if (_fabBreathCtrl.isAnimating) _fabBreathCtrl.stop();
    } else {
      if (!_fabBreathCtrl.isAnimating) _fabBreathCtrl.repeat(reverse: true);
    }

    // 겹치는 노드 자동 분산 — 노드 수 변경 시 디바운스로 재실행
    if (nodes.length > 1 && nodes.length != _lastSpreadNodeCount) {
      _lastSpreadNodeCount = nodes.length;
      _spreadDebouncer?.cancel();
      _spreadDebouncer = Timer(const Duration(milliseconds: 500), () {
        if (mounted) {
          _spreadOverlappingNodes(ref.read(canvasNotifierProvider).nodes);
        }
      });
    }

    // 세대 깊이 갱신 (nodes/edges 변경 시만 재계산)
    if (!identical(nodes, _lastGenNodes) || !identical(edges, _lastGenEdges)) {
      _generations = computeGenerations(nodes: nodes, edges: edges);
      _lastGenNodes = nodes;
      _lastGenEdges = edges;
    }

    // Time Slider 연도 변경 감지 → 이벤트 토스트
    final currentSliderYear = canvasState.timeSliderYear;
    if (currentSliderYear != _prevTimeSliderYear) {
      _prevTimeSliderYear = currentSliderYear;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final msg = TimeEventToast.buildEventMessage(
          year: currentSliderYear,
          nodes: nodes,
        );
        if (msg != null) {
          setState(() => _timeEventMessage = msg);
        }
      });
    }

    // Time Slider: 연도 필터링된 노드 ID 세트 + 필터링된 엣지
    // EdgePainter와 노드 카드 모두에서 동일한 필터를 공유
    final Set<String> timeVisibleNodeIds;
    final List<NodeEdge> timeFilteredEdges;
    if (canvasState.timeSliderYear != null) {
      timeVisibleNodeIds = {
        for (final n in nodes)
          if (canvasState.nodeVisibleInTime(n)) n.id,
      };
      // 기간 설정 시 모든 선 숨김 — 카드만 표시
      timeFilteredEdges = const [];
    } else {
      timeVisibleNodeIds = {for (final n in nodes) n.id};
      timeFilteredEdges = edges;
    }

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: Stack(
        children: [
          // ── 배경 ────────────────────────────────────────────────────────
          _CanvasBackground(),

          // ── 목록 보기 또는 무한 캔버스 ──────────────────────────────────
          if (_isListView)
            const Positioned.fill(child: FamilyListView()),

          if (!_isListView)
          InteractiveViewer(
            transformationController: _transformCtrl,
            constrained: false,
            clipBehavior: Clip.none,
            minScale: 0.3,
            maxScale: 3.0,
            boundaryMargin: const EdgeInsets.all(double.infinity),
            // 드래그 중에는 캔버스 팬 비활성화
            panEnabled: _draggingId == null && !isConnectMode,
            child: RepaintBoundary(
              key: _canvasRepaintKey,
              child: SizedBox(
              width: 4000,
              height: 4000,
              child: Stack(
                children: [
                  // 가족 나무 성장 배경 (캔버스 하단 중앙, 최하위 레이어)
                  const Positioned(
                    bottom: 200,
                    left: 0,
                    right: 0,
                    child: Center(child: TreeGrowthOverlay()),
                  ),

                  // 관계선 레이어 — 데이터 변경 시만 재페인트 (RepaintBoundary 분리)
                  // Time Slider 활성 시, 필터링된 노드의 엣지만 표시
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: CustomPaint(
                        painter: EdgePainter(
                          nodes: nodes,
                          edges: timeFilteredEdges,
                          connectingNodeId: canvasState.connectingNodeId,
                          pointerPosition: _connectPointer,
                          draggingNodeId: _draggingId,
                          draggingPosition: _draggingPos,
                        ),
                      ),
                    ),
                  ),

                  // 빈 상태 안내
                  if (nodes.isEmpty) const _EmptyHint(),

                  // 노드 카드들 — AnimatedBuilder로 뷰포트 컬링 + LOD 적용
                  AnimatedBuilder(
                    animation: _transformCtrl,
                    builder: (context, _) {
                      final scale =
                          _transformCtrl.value.getMaxScaleOnAxis();
                      final lod = lodFromScale(scale);
                      final screenSize = MediaQuery.of(context).size;

                      _updateVisibleNodes(nodes, screenSize);

                      final timeFiltered = _visibleNodes
                          .where(canvasState.nodeVisibleInTime)
                          .toList();

                      // 명절 glow 대상 노드 ID 계산
                      final holidayGlowIds = isHolidayActive
                          ? computeHolidayGlowNodeIds(
                              nodes: nodes,
                              generations: _generations,
                            )
                          : <String>{};

                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // 사이즈 앵커: Stack이 0×0으로 축소되지 않도록
                          const SizedBox(width: 4000, height: 4000),
                          ...timeFiltered.map((node) {
                          final depth = _generations[node.id] ?? 0;
                          return _DraggableNodeCard(
                            key: ValueKey(node.id),
                            node: node,
                            canvasState: canvasState,
                            focusOpacity: canvasState.nodeOpacity(node.id),
                            lodLevel: lod,
                            generationDepth: depth,
                            transformCtrl: _transformCtrl,
                            earnedBadgeIds: earnedBadgeIds.isNotEmpty
                                ? earnedBadgeIds
                                : null,
                            showHolidayGlow: holidayGlowIds.contains(node.id),
                            isMe: myNodeId == node.id,
                            unreadBouquetCount: myNodeId == node.id ? myUnreadCount : 0,
                            onDragStarted: () =>
                                setState(() {
                                  _draggingId = node.id;
                                  _draggingPos = Offset(node.positionX, node.positionY);
                                }),
                            onDragUpdate: (dx, dy) =>
                                setState(() => _draggingPos = Offset(dx, dy)),
                            onDragEnded: (dx, dy) async {
                              setState(() {
                                _draggingId = null;
                                _draggingPos = null;
                              });
                              final snapOn = ref.read(spouseSnapNotifierProvider).valueOrNull ?? true;
                              final pos = snapOn ? _spouseSnap(node.id, dx, dy, canvasState) : Offset(dx, dy);

                              // snap이 발생했으면 배우자는 겹침 검사에서 제외
                              String? snapSpouseId;
                              if (snapOn && (pos.dx != dx || pos.dy != dy)) {
                                final spouseEdge = canvasState.edges.where((e) =>
                                    e.relation == RelationType.spouse &&
                                    (e.fromNodeId == node.id || e.toNodeId == node.id),
                                ).firstOrNull;
                                if (spouseEdge != null) {
                                  snapSpouseId = spouseEdge.fromNodeId == node.id
                                      ? spouseEdge.toNodeId
                                      : spouseEdge.fromNodeId;
                                }
                              }

                              // 겹침 감지 → 자동 밀어내기 (배우자 제외)
                              final resolved = _resolveDropOverlap(
                                node.id, pos.dx, pos.dy, nodes,
                                skipNodeId: snapSpouseId,
                              );
                              await ref.read(canvasNotifierProvider.notifier).saveNodePosition(node.id, resolved.dx, resolved.dy);
                            },
                            onTap: () => _onNodeTap(node, canvasState),
                            onDoubleTap: () => _onNodeDoubleTap(node),
                            onLongPress: () => _onNodeLongPress(node),
                          );
                        }),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            ),
          ),

          // ── 연결 모드 포인터 추적 (InteractiveViewer 위에 배치) ───────────
          if (isConnectMode && !_isListView)
            Positioned.fill(
              child: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerMove: (e) {
                  final matrix = _transformCtrl.value;
                  final scale = matrix.getMaxScaleOnAxis();
                  final tx = matrix.getTranslation();
                  setState(() {
                    _connectPointer = Offset(
                      (e.position.dx - tx.x) / scale,
                      (e.position.dy - tx.y) / scale,
                    );
                  });
                },
                onPointerUp: (_) => setState(() => _connectPointer = null),
                child: const SizedBox.expand(),
              ),
            ),

          // ── 상단 앱바 ────────────────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    GlassCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg, vertical: AppSpacing.sm,
                      ),
                      child: Text(
                        'Re-Link',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // 노드 수 표시
                    if (nodes.isNotEmpty)
                      GlassCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: AppSpacing.sm,
                        ),
                        child: Text(
                          '${nodes.length}명',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    const SizedBox(width: AppSpacing.sm),
                    // 캔버스/목록 보기 전환
                    Tooltip(
                      message: _isListView ? '트리 보기' : '목록 보기',
                      child: GlassCard(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        onTap: () => setState(() => _isListView = !_isListView),
                        child: Icon(
                          _isListView
                              ? Icons.account_tree_outlined
                              : Icons.grid_view_rounded,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    // 스트릭 배지
                    const StreakBadge(),
                    const SizedBox(width: AppSpacing.sm),
                    Tooltip(
                      message: '검색',
                      child: GlassCard(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        onTap: () async {
                          final nodeId = await context.push<String>(AppRoutes.search);
                          if (nodeId != null && mounted) {
                            final state = ref.read(canvasNotifierProvider);
                            final node = state.nodes.where((n) => n.id == nodeId).firstOrNull;
                            if (node != null) _animateCameraToNode(node);
                          }
                        },
                        child: Icon(
                          Icons.search,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                    ),
                    if (!_isListView) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Tooltip(
                      message: '타임라인 필터',
                      child: GlassCard(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        onTap: () {
                          HapticService.light();
                          ref.read(canvasNotifierProvider.notifier).toggleTimeSlider();
                        },
                        child: Icon(
                          Icons.timeline,
                          color: canvasState.timeSliderVisible
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Tooltip(
                      message: '캔버스 중앙으로',
                      child: GlassCard(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        onTap: _resetZoom,
                        child: Icon(
                          Icons.center_focus_strong,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                    ),
                    if (nodes.isNotEmpty) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Tooltip(
                      message: '전체 족보 내보내기',
                      child: GlassCard(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        onTap: _isExporting ? null : _exportCanvas,
                        child: _isExporting
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              )
                            : Icon(
                                Icons.ios_share,
                                color: AppColors.textSecondary,
                                size: 20,
                              ),
                      ),
                    ),
                    ],
                    ],
                  ],
                ),
              ),
            ),
          ),

          // ── 명절/기념일 배너 ─────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 62, left: AppSpacing.lg, right: AppSpacing.lg,
            child: const HolidayBanner(),
          ),

          // ── 데일리 프롬프트 카드 (캔버스 모드에서만, 배너 아래 56px 오프셋) ──
          if (!_isListView)
            Positioned(
              top: MediaQuery.of(context).padding.top + 62 + 56, left: AppSpacing.lg, right: AppSpacing.lg,
              child: const DailyPromptCard(),
            ),

          // ── 연결 모드 배너 ───────────────────────────────────────────────
          if (isConnectMode && !_isListView)
            Positioned(
              top: MediaQuery.of(context).padding.top + 62, left: AppSpacing.lg, right: AppSpacing.lg,
              child: GlassCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    Icon(Icons.link, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        '연결할 인물을 탭하세요',
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => ref.read(canvasNotifierProvider.notifier).cancelConnectMode(),
                      child: Icon(Icons.close, color: AppColors.textSecondary, size: 20),
                    ),
                  ],
                ),
              ),
            ),

          // ── Time Slider ─────────────────────────────────────────────────
          if (!_isListView) const TimeSliderWidget(),

          // ── Time Slider 이벤트 토스트 ──────────────────────────────────
          if (!_isListView) TimeEventToast(message: _timeEventMessage),

          // ── Minimap (좌하단) ────────────────────────────────────────────────
          // body는 이미 bottomNav + 광고 배너 위에 위치하므로 bottomNavHeight 불필요
          if (!_isListView)
            Positioned(
              bottom: AppSpacing.lg,
              left: AppSpacing.lg,
              child: nodes.isEmpty
                  ? const SizedBox.shrink()
                  : MinimapWidget(
                      nodes: nodes,
                      transformationController: _transformCtrl,
                      screenSize: MediaQuery.sizeOf(context),
                    ),
            ),

          // ── Focus Mode 정보 패널 ─────────────────────────────────────────
          if (canvasState.focusedNodeId != null && !_isListView)
            _FocusInfoPanel(
              node: canvasState.nodes
                  .where((n) => n.id == canvasState.focusedNodeId)
                  .firstOrNull,
              edgeCount: canvasState.edges
                  .where((e) =>
                      e.fromNodeId == canvasState.focusedNodeId ||
                      e.toNodeId == canvasState.focusedNodeId)
                  .length,
              onClose: () => ref.read(canvasNotifierProvider.notifier).clearFocus(),
              onDetail: () {
                final node = canvasState.nodes
                    .where((n) => n.id == canvasState.focusedNodeId)
                    .firstOrNull;
                if (node != null) _onNodeTap(node, canvasState);
              },
            ),

          // ── FAB (노드 추가) ──────────────────────────────────────────────
          // body는 이미 bottomNav + 광고 배너 위에 위치하므로 bottomNavHeight 불필요
          // 미니맵(높이 120)과 같은 높이, 우하단에 배치
          Positioned(
            bottom: AppSpacing.lg,
            right: AppSpacing.lg,
            child: GestureDetector(
              onTap: isConnectMode ? null : _showAddNodeSheet,
              child: AnimatedOpacity(
                opacity: isConnectMode ? 0.3 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: AnimatedBuilder(
                  animation: _fabBreathCtrl,
                  builder: (context, child) {
                    final t = _fabBreathCtrl.value;
                    final scale = 1.0 + 0.12 * t;
                    final shadowOpacity = 0.35 + 0.35 * t;
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: AppSpacing.fabSize,
                        height: AppSpacing.fabSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6EC6CA), Color(0xFF4A9EBF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, shadowOpacity),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: child,
                      ),
                    );
                  },
                  child: Icon(Icons.add, color: AppColors.onPrimary, size: 28),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 이벤트 ─────────────────────────────────────────────────────────────────

  void _onNodeTap(NodeModel node, CanvasState state) {
    if (state.isConnectMode) {
      _handleConnectTap(node, state);
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => NodeDetailSheet(nodeId: node.id),
    );
  }

  Future<void> _handleConnectTap(NodeModel toNode, CanvasState state) async {
    final fromId = state.connectingNodeId!;
    if (toNode.id == fromId) return;

    final fromNode = state.nodes.where((n) => n.id == fromId).firstOrNull;
    if (fromNode == null) return;

    // 기존 관계 확인
    final existingEdge = await ref
        .read(nodeNotifierProvider.notifier)
        .findEdge(fromNodeId: fromId, toNodeId: toNode.id);

    if (!mounted) return;

    // 관계 타입 선택 (기존 관계 있으면 삭제 옵션 포함)
    final result = await showModalBottomSheet<RelationPickerResult>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => RelationPickerSheet(
        fromNode: fromNode,
        toNode: toNode,
        existingRelation: existingEdge?.relation,
      ),
    );

    if (!mounted) return;
    ref.read(canvasNotifierProvider.notifier).cancelConnectMode();

    if (result is RelationSelected) {
      final edge = await ref.read(nodeNotifierProvider.notifier).addEdge(
            fromNodeId: fromId,
            toNodeId: toNode.id,
            relation: result.type,
          );
      if (edge != null && mounted) {
        HapticService.connectionMade();
        // 관계 추가 후 배지 조건 재확인
        final newBadges = await ref.read(badgeNotifierProvider.notifier).checkAndAward();
        if (newBadges.isNotEmpty && mounted) {
          showDialog(
            context: context,
            builder: (_) => BadgeEarnedDialog(badge: newBadges.first),
          );
        }
      }
    } else if (result is RelationDeleted && existingEdge != null) {
      await ref.read(nodeNotifierProvider.notifier).deleteEdge(existingEdge.id);
      if (mounted) HapticService.light();
    }
  }

  void _onNodeLongPress(NodeModel node) {
    HapticService.medium();
    ref.read(canvasNotifierProvider.notifier).startConnectMode(node.id);
  }

  void _onNodeDoubleTap(NodeModel node) {
    HapticService.light();
    final notifier = ref.read(canvasNotifierProvider.notifier);
    final current = ref.read(canvasNotifierProvider).focusedNodeId;
    if (current == node.id) {
      notifier.clearFocus();
    } else {
      notifier.setFocus(node.id);
      // Focus Mode 진입 시 카메라를 포커스 노드 중앙으로 이동
      _animateCameraToNode(node);
    }
  }

  /// 카메라를 특정 노드 중앙으로 이동
  void _animateCameraToNode(NodeModel node) {
    final screenSize = MediaQuery.of(context).size;
    final nodeCenter = Offset(
      node.positionX + kNodeCardWidth / 2,
      node.positionY + kNodeCardHeight / 2,
    );
    final dx = -(nodeCenter.dx - screenSize.width / 2);
    final dy = -(nodeCenter.dy - screenSize.height / 2);
    _transformCtrl.value = Matrix4.translationValues(dx, dy, 0);
  }

  /// 부부 자석 스냅: 배우자가 가까우면 옆에 자동 정렬
  Offset _spouseSnap(
    String nodeId, double x, double y, CanvasState state,
  ) {
    const snapDistance = 200.0;
    const snapGap = 160.0; // 노드 가로 폭(110) + 50px 간격 (레이블 공간 확보)

    // 이 노드의 배우자 엣지 찾기
    final spouseEdge = state.edges.where((e) =>
        e.relation == RelationType.spouse &&
        (e.fromNodeId == nodeId || e.toNodeId == nodeId),
    ).firstOrNull;
    if (spouseEdge == null) return Offset(x, y);

    final spouseId = spouseEdge.fromNodeId == nodeId
        ? spouseEdge.toNodeId
        : spouseEdge.fromNodeId;
    final spouse = state.nodes.where((n) => n.id == spouseId).firstOrNull;
    if (spouse == null) return Offset(x, y);

    final dx = x - spouse.positionX;
    final dy = y - spouse.positionY;
    final dist = (Offset(dx, dy)).distance;

    // 스냅 범위 내이면 배우자 옆으로 정렬
    if (dist < snapDistance) {
      final side = dx >= 0 ? 1.0 : -1.0;
      return Offset(
        spouse.positionX + side * snapGap,
        spouse.positionY, // 같은 Y 높이
      );
    }

    return Offset(x, y);
  }

  /// 드래그 드롭 후 겹침 감지 → 가장 가까운 빈 자리로 밀어내기
  /// [skipNodeId]: 자석 스냅으로 의도적으로 붙인 배우자 등 겹침 검사 제외 대상
  Offset _resolveDropOverlap(
    String droppedId, double x, double y, List<NodeModel> nodes,
    {String? skipNodeId}
  ) {
    const minDx = 140.0;
    const minDy = 160.0;

    double newX = x;
    double newY = y;

    // 최대 20회 시도
    for (int attempt = 0; attempt < 20; attempt++) {
      final overlap = nodes.any((n) =>
          n.id != droppedId &&
          n.id != skipNodeId &&
          (n.positionX - newX).abs() < minDx &&
          (n.positionY - newY).abs() < minDy);
      if (!overlap) return Offset(newX, newY);

      // 겹치는 노드 중 가장 가까운 것을 찾아 반대 방향으로 밀기
      double bestDist = double.infinity;
      double pushDx = minDx;
      double pushDy = 0;
      for (final n in nodes) {
        if (n.id == droppedId || n.id == skipNodeId) continue;
        final dx = newX - n.positionX;
        final dy = newY - n.positionY;
        if (dx.abs() < minDx && dy.abs() < minDy) {
          final dist = dx * dx + dy * dy;
          if (dist < bestDist) {
            bestDist = dist;
            // 겹침이 적은 축 방향으로 밀어내기
            final overlapX = minDx - dx.abs();
            final overlapY = minDy - dy.abs();
            if (overlapX <= overlapY) {
              pushDx = (dx >= 0 ? overlapX : -overlapX) + (dx >= 0 ? 5 : -5);
              pushDy = 0;
            } else {
              pushDx = 0;
              pushDy = (dy >= 0 ? overlapY : -overlapY) + (dy >= 0 ? 5 : -5);
            }
          }
        }
      }
      newX = (newX + pushDx).clamp(100.0, 3800.0);
      newY = (newY + pushDy).clamp(100.0, 3800.0);
    }

    return Offset(newX, newY);
  }

  Future<void> _showAddNodeSheet() async {
    // 캔버스 중심 좌표 계산
    final matrix = _transformCtrl.value;
    final scale = matrix.getMaxScaleOnAxis();
    final tx = matrix.getTranslation();
    final screenSize = MediaQuery.of(context).size;
    double newX = (screenSize.width / 2 - tx.x) / scale;
    double newY = (screenSize.height / 2 - tx.y) / scale;

    // 기존 노드와 겹침 방지
    final nodes = ref.read(canvasNotifierProvider).nodes;
    for (int i = 0; i < 20; i++) {
      final overlap = nodes.any((n) =>
          (n.positionX - newX).abs() < 130 &&
          (n.positionY - newY).abs() < 150);
      if (!overlap) break;
      newX += 140;
      if (newX > 3800) {
        newX = (screenSize.width / 2 - tx.x) / scale;
        newY += 160;
      }
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddNodeSheet(
        initialPositionX: newX.clamp(100, 3800),
        initialPositionY: newY.clamp(100, 3800),
      ),
    );
    // 노드 추가 후 배지 조건 재확인
    if (mounted) {
      final newBadges = await ref.read(badgeNotifierProvider.notifier).checkAndAward();
      if (newBadges.isNotEmpty && mounted) {
        showDialog(
          context: context,
          builder: (_) => BadgeEarnedDialog(badge: newBadges.first),
        );
      }
    }
  }


  /// 내보내기 형식 선택 바텀시트 표시
  Future<void> _exportCanvas() async {
    final format = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: AppColors.bgBase,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withAlpha(80),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '내보내기 형식',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.image_outlined, color: AppColors.primary),
              title: const Text('고화질 PNG 이미지'),
              subtitle: const Text('사진으로 저장 · 공유하기'),
              onTap: () => Navigator.pop(ctx, 'png'),
            ),
            ListTile(
              leading: Icon(Icons.picture_as_pdf_outlined, color: const Color(0xFFE53935)),
              title: const Text('PDF 문서'),
              subtitle: const Text('인쇄용 · 문서로 보관'),
              onTap: () => Navigator.pop(ctx, 'pdf'),
            ),
          ],
        ),
      ),
    );
    if (format == null || !mounted) return;

    setState(() => _isExporting = true);
    HapticService.medium();
    try {
      // 한 프레임 대기 — RepaintBoundary 렌더링 완료
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;

      final boundary = _canvasRepaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('캔버스를 캡처할 수 없습니다')),
          );
        }
        return;
      }

      // 고해상도 캡처 — 4000x4000 캔버스 전체 (나무 포함)
      final exportImage = await boundary.toImage(pixelRatio: 3.0);

      final byteData =
          await exportImage.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final pngBytes = byteData.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      File exportFile;
      String mimeType;

      if (format == 'pdf') {
        // PNG → PDF 변환
        final pdfDoc = pw.Document();
        final pdfImage = pw.MemoryImage(pngBytes);
        pdfDoc.addPage(
          pw.Page(
            pageFormat: PdfPageFormat(
              exportImage.width.toDouble(),
              exportImage.height.toDouble(),
            ),
            margin: pw.EdgeInsets.zero,
            build: (pw.Context ctx) => pw.Center(
              child: pw.Image(pdfImage, fit: pw.BoxFit.contain),
            ),
          ),
        );
        final pdfBytes = await pdfDoc.save();
        exportFile = File(p.join(dir.path, 'relink_canvas_$timestamp.pdf'));
        await exportFile.writeAsBytes(pdfBytes);
        mimeType = 'application/pdf';
      } else {
        exportFile = File(p.join(dir.path, 'relink_canvas_$timestamp.png'));
        await exportFile.writeAsBytes(pngBytes);
        mimeType = 'image/png';
      }

      if (!mounted) return;

      // iPad 지원 공유
      final box = context.findRenderObject() as RenderBox?;
      final shareOrigin = box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : null;

      await Share.shareXFiles(
        [XFile(exportFile.path, mimeType: mimeType)],
        subject: 'Re-Link 전체 가족 트리',
        sharePositionOrigin: shareOrigin,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('내보내기 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  void _resetZoom() {
    final screenSize = MediaQuery.of(context).size;
    final nodes = ref.read(canvasNotifierProvider).nodes;

    if (nodes.isEmpty) {
      // 노드 없으면 캔버스 중앙
      final dx = -(2000.0 - screenSize.width / 2);
      final dy = -(2000.0 - screenSize.height / 2);
      _transformCtrl.value = Matrix4.translationValues(dx, dy, 0);
      return;
    }

    // 바운딩 박스 계산
    double minX = double.infinity, maxX = double.negativeInfinity;
    double minY = double.infinity, maxY = double.negativeInfinity;
    for (final node in nodes) {
      if (node.positionX < minX) minX = node.positionX;
      if (node.positionX + kNodeCardWidth > maxX) maxX = node.positionX + kNodeCardWidth;
      if (node.positionY < minY) minY = node.positionY;
      if (node.positionY + kNodeCardHeight > maxY) maxY = node.positionY + kNodeCardHeight;
    }

    // 패딩 추가 (상단 앱바 + 하단 네비)
    const padH = 100.0;
    const padTop = 140.0;
    const padBottom = 120.0;
    minX -= padH;
    maxX += padH;
    minY -= padTop;
    maxY += padBottom;

    final contentW = maxX - minX;
    final contentH = maxY - minY;

    // 전체 노드가 화면에 들어오는 줌 레벨 계산
    final scaleX = screenSize.width / contentW;
    final scaleY = screenSize.height / contentH;
    final scale = (scaleX < scaleY ? scaleX : scaleY).clamp(0.3, 1.0);

    // 콘텐츠 중심 → 화면 중심
    final centerX = (minX + maxX) / 2;
    final centerY = (minY + maxY) / 2;
    final dx = -centerX * scale + screenSize.width / 2;
    final dy = -centerY * scale + screenSize.height / 2;

    final m = Matrix4.identity();
    m.storage[0] = scale;   // scaleX
    m.storage[5] = scale;   // scaleY
    m.storage[10] = scale;  // scaleZ
    m.storage[12] = dx;     // translateX
    m.storage[13] = dy;     // translateY
    _transformCtrl.value = m;
  }
}

/// 드래그 가능한 노드 카드 래퍼 (LOD + Pseudo-3D 적용)
/// Listener 기반 제스처 — GestureDetector 아레나 우회
class _DraggableNodeCard extends StatefulWidget {
  const _DraggableNodeCard({
    super.key,
    required this.node,
    required this.canvasState,
    required this.focusOpacity,
    required this.lodLevel,
    required this.generationDepth,
    required this.transformCtrl,
    required this.onTap,
    required this.onDoubleTap,
    required this.onLongPress,
    required this.onDragStarted,
    required this.onDragUpdate,
    required this.onDragEnded,
    this.earnedBadgeIds,
    this.showHolidayGlow = false,
    this.isMe = false,
    this.unreadBouquetCount = 0,
  });

  final NodeModel node;
  final CanvasState canvasState;
  final double focusOpacity;
  final LodLevel lodLevel;
  final int generationDepth;
  final TransformationController transformCtrl;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;
  final VoidCallback onLongPress;
  final VoidCallback onDragStarted;
  final void Function(double dx, double dy) onDragUpdate;
  final void Function(double dx, double dy) onDragEnded;

  /// 이 노드에 연관된 획득 배지 ID 목록
  final List<String>? earnedBadgeIds;

  /// 명절 기간 조상 노드 glow 여부
  final bool showHolidayGlow;

  /// 이 노드가 "나"인지 여부
  final bool isMe;

  /// 읽지 않은 받은 마음 수 ("나" 노드에서 N 뱃지 표시용)
  final int unreadBouquetCount;

  @override
  State<_DraggableNodeCard> createState() => _DraggableNodeCardState();
}

class _DraggableNodeCardState extends State<_DraggableNodeCard> {
  late double _x;
  late double _y;

  // Listener 기반 제스처 상태
  Offset? _pointerDownPos;
  DateTime? _pointerDownTime;
  bool _isLongPress = false;
  bool _isDragging = false;
  Timer? _longPressTimer;

  // 더블탭 감지
  DateTime? _lastTapTime;

  @override
  void initState() {
    super.initState();
    _x = widget.node.positionX;
    _y = widget.node.positionY;
  }

  @override
  void didUpdateWidget(_DraggableNodeCard old) {
    super.didUpdateWidget(old);
    if (!_isDragging) {
      _x = widget.node.positionX;
      _y = widget.node.positionY;
    }
  }

  @override
  void dispose() {
    _longPressTimer?.cancel();
    super.dispose();
  }

  // ── Listener 콜백 ──────────────────────────────────────────────────────

  void _onPointerDown(PointerDownEvent e) {
    _pointerDownPos = e.position;
    _pointerDownTime = DateTime.now();
    _isLongPress = false;
    _isDragging = false;

    // 400ms 후 롱프레스 감지
    _longPressTimer = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      _isLongPress = true;
      HapticService.medium();
      setState(() {}); // 롱프레스 시각 피드백 (스케일 업)
    });
  }

  void _onPointerMove(PointerMoveEvent e) {
    if (_pointerDownPos == null) return;
    final distance = (e.position - _pointerDownPos!).distance;

    if (!_isLongPress) {
      // 롱프레스 전 이동 → 캔버스 팬 (InteractiveViewer에 위임)
      if (distance > 10) _longPressTimer?.cancel();
      return;
    }

    // 롱프레스 후 이동 → 노드 드래그
    if (!_isDragging && distance > 5) {
      _isDragging = true;
      widget.onDragStarted(); // _draggingId 설정 → panEnabled: false
    }

    if (_isDragging) {
      final scale = widget.transformCtrl.value.getMaxScaleOnAxis();
      final delta = e.position - _pointerDownPos!;
      setState(() {
        _x = (widget.node.positionX + delta.dx / scale).clamp(0.0, 3900.0);
        _y = (widget.node.positionY + delta.dy / scale).clamp(0.0, 3900.0);
      });
      widget.onDragUpdate(_x, _y);
    }
  }

  void _onPointerUp(PointerUpEvent e) {
    _longPressTimer?.cancel();

    if (_isDragging) {
      // 드래그 종료 → 위치 저장
      widget.onDragEnded(_x, _y);
    } else if (_isLongPress) {
      // 롱프레스 후 이동 없이 떼기 → 연결 모드
      widget.onLongPress();
    } else if (_pointerDownPos != null && _pointerDownTime != null) {
      // 탭 판정: 짧은 시간 + 적은 이동
      final now = DateTime.now();
      final duration = now.difference(_pointerDownTime!);
      final distance = (e.position - _pointerDownPos!).distance;
      if (duration.inMilliseconds < 300 && distance < 20) {
        // 더블탭 판정: 이전 탭으로부터 300ms 이내
        if (_lastTapTime != null &&
            now.difference(_lastTapTime!).inMilliseconds < 300) {
          _lastTapTime = null;
          widget.onDoubleTap();
        } else {
          _lastTapTime = now;
          widget.onTap();
        }
      }
    }

    _pointerDownPos = null;
    _pointerDownTime = null;
    _isLongPress = false;
    _isDragging = false;
  }

  void _onPointerCancel(PointerCancelEvent e) {
    _longPressTimer?.cancel();
    if (_isDragging) widget.onDragEnded(_x, _y);
    _pointerDownPos = null;
    _pointerDownTime = null;
    _isLongPress = false;
    _isDragging = false;
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.canvasState;
    final p3d = pseudo3dTransform(widget.generationDepth);
    final combinedOpacity = (widget.focusOpacity * p3d.opacity).clamp(0.0, 1.0);

    // 롱프레스/드래그 중 scale 1.08, Focus Mode 포커스 노드 scale 1.2
    final isLifted = _isLongPress || _isDragging;
    final isFocusTarget = state.focusedNodeId == widget.node.id;
    final double scaleMultiplier;
    if (isLifted) {
      scaleMultiplier = 1.08;
    } else if (isFocusTarget) {
      scaleMultiplier = 1.15; // Focus Mode 포커스 노드 확대
    } else {
      scaleMultiplier = 1.0;
    }
    final visualScale = p3d.scale * scaleMultiplier;

    return Positioned(
      left: _isDragging ? _x : widget.node.positionX,
      top: _isDragging ? _y : widget.node.positionY,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerCancel,
        child: Transform.translate(
          offset: Offset(0, p3d.translateY + (isLifted ? -4.0 : 0.0)),
          child: AnimatedScale(
            scale: visualScale,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            child: AnimatedOpacity(
              opacity: combinedOpacity,
              duration: const Duration(milliseconds: 200),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: isFocusTarget
                    ? const BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x40000000),
                            blurRadius: 10,
                            spreadRadius: 0,
                          ),
                        ],
                      )
                    : null,
                child: NodeCardLod(
                  node: widget.node,
                  lodLevel: widget.lodLevel,
                  isSelected: state.selectedNodeId == widget.node.id,
                  isConnectSource: state.connectingNodeId == widget.node.id,
                  isConnectMode: state.isConnectMode,
                  ghostLabel: widget.node.isGhost
                      ? resolveGhostLabel(widget.node, state.edges)
                      : null,
                  earnedBadgeIds: widget.earnedBadgeIds,
                  showHolidayGlow: widget.showHolidayGlow,
                  isMe: widget.isMe,
                  unreadBouquetCount: widget.unreadBouquetCount,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 빈 캔버스 안내
class _EmptyHint extends StatelessWidget {
  const _EmptyHint();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 1800,
      left: 1600,
      child: SizedBox(
        width: 800,
        child: Column(
          children: [
            Icon(Icons.account_tree_outlined, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              '가족 트리를 시작해 보세요',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '+ 버튼으로 첫 번째 인물을 추가하세요',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// 배경 (오로라 그라디언트 + 그리드 점) — RepaintBoundary로 캔버스 재페인트와 분리
class _CanvasBackground extends StatefulWidget {
  @override
  State<_CanvasBackground> createState() => _CanvasBackgroundState();
}

class _CanvasBackgroundState extends State<_CanvasBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Alignment> _center1;
  late final Animation<Alignment> _center2;
  late final Animation<Alignment> _center3;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);

    _center1 = AlignmentTween(
      begin: const Alignment(-0.8, -0.6),
      end: const Alignment(-0.3, 0.2),
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

    _center2 = AlignmentTween(
      begin: const Alignment(0.6, -0.4),
      end: const Alignment(0.2, 0.5),
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.1, 0.9, curve: Curves.easeInOut),
    ));

    _center3 = AlignmentTween(
      begin: const Alignment(0.0, 0.8),
      end: const Alignment(-0.5, -0.3),
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.2, 1.0, curve: Curves.easeInOut),
    ));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        children: [
          _StaticBackground(),
          AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) {
              return CustomPaint(
                painter: _AuroraPainter(
                  center1: _center1.value,
                  center2: _center2.value,
                  center3: _center3.value,
                  isDark: Theme.of(context).brightness == Brightness.dark,
                ),
                child: const SizedBox.expand(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StaticBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return CustomPaint(
      painter: _GridPainter(isDark: isDark),
      child: Container(
        color: AppColors.bgBase,
      ),
    );
  }
}

/// Focus Mode 정보 패널 — 하단에서 슬라이드업 (AnimatedSlide)
class _FocusInfoPanel extends StatelessWidget {
  const _FocusInfoPanel({
    required this.node,
    required this.edgeCount,
    required this.onClose,
    required this.onDetail,
  });

  final NodeModel? node;
  final int edgeCount;
  final VoidCallback onClose;
  final VoidCallback onDetail;

  static const _tempLabels = ['냉담', '쌀쌀', '보통', '따뜻', '뜨거움', '열정'];
  static const _tempColors = [
    Color(0xFF4FC3F7),
    Color(0xFF81C784),
    Color(0xFFFFD54F),
    Color(0xFFFFB74D),
    Color(0xFFFF7043),
    Color(0xFFE53935),
  ];

  @override
  Widget build(BuildContext context) {
    if (node == null) return const SizedBox.shrink();
    final n = node!;
    final tempIdx = n.temperature.clamp(0, 5);
    final tempColor = _tempColors[tempIdx];
    final tempLabel = _tempLabels[tempIdx];

    // body는 이미 bottomNav + 광고 위에 위치하므로 bottomNavHeight 불필요
    // 미니맵(높이 120) 위, FAB 우측 여백 확보
    return Positioned(
      bottom: AppSpacing.lg + 120 + AppSpacing.sm,
      left: AppSpacing.lg,
      right: AppSpacing.lg + AppSpacing.fabSize + AppSpacing.md,
      child: TweenAnimationBuilder<Offset>(
        tween: Tween(begin: const Offset(0, 1), end: Offset.zero),
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        builder: (_, offset, child) => FractionalTranslation(
          translation: offset,
          child: child,
        ),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              // 아바타 (미니)
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tempColor.withAlpha(40),
                  border: Border.all(color: tempColor, width: 1.5),
                ),
                child: n.isGhost
                    ? Icon(Icons.help_outline, color: AppColors.textTertiary, size: 18)
                    : Icon(Icons.person, color: AppColors.textSecondary, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              // 이름 + 관계수 + 온도
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      n.name,
                      style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.people_outline, size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 3),
                        Text(
                          '연결 $edgeCount명',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 8, height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle, color: tempColor,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          tempLabel,
                          style: TextStyle(fontSize: 11, color: tempColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 상세보기 버튼
              GestureDetector(
                onTap: onDetail,
                child: Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.sm),
              // 닫기
              GestureDetector(
                onTap: onClose,
                child: Icon(Icons.close, size: 16, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 오로라 배경 — 3개의 RadialGradient가 느리게 드리프트
class _AuroraPainter extends CustomPainter {
  const _AuroraPainter({
    required this.center1,
    required this.center2,
    required this.center3,
    required this.isDark,
  });

  final Alignment center1;
  final Alignment center2;
  final Alignment center3;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Bloom 1: Mint — 부드러운 민트빛 (alpha 축소: 어두워짐 방지)
    final paint1 = Paint()
      ..shader = RadialGradient(
        center: center1,
        radius: 0.9,
        colors: isDark
            ? [const Color(0x4420B2AA), const Color(0x001B3A4A)]
            : [const Color(0x5596D4D6), const Color(0x00B8E6E8)],
        stops: const [0.0, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, paint1);

    // Bloom 2: Violet — 부드러운 보라빛
    final paint2 = Paint()
      ..shader = RadialGradient(
        center: center2,
        radius: 0.85,
        colors: isDark
            ? [const Color(0x3D7B68EE), const Color(0x002A1F40)]
            : [const Color(0x44B8A9E8), const Color(0x00E0D4F0)],
        stops: const [0.0, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, paint2);

    // Bloom 3: Warm coral — 부드러운 코랄빛
    final paint3 = Paint()
      ..shader = RadialGradient(
        center: center3,
        radius: 0.8,
        colors: isDark
            ? [const Color(0x33E8825A), const Color(0x003A2218)]
            : [const Color(0x3DF0B4A0), const Color(0x00F0D4C8)],
        stops: const [0.0, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, paint3);
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter old) =>
      old.center1 != center1 || old.center2 != center2 || old.center3 != center3 || old.isDark != isDark;
}

/// 배경 그리드 점
class _GridPainter extends CustomPainter {
  const _GridPainter({required this.isDark});
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? const Color(0x1AFFFFFF) : const Color(0x1A000000)
      ..strokeWidth = 1;
    const spacing = 32.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
