import 'package:flutter/material.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../core/utils/path_utils.dart';
import '../../../design/motion/app_motion.dart';
import '../../../shared/models/node_model.dart';
import '../../../design/tokens/app_colors.dart';
import '../../badges/models/badge_definition.dart';
import '../utils/lod_utils.dart';

const double kNodeCardWidth = 110.0;
const double kNodeCardHeight = 130.0;

/// Ghost 노드 라벨을 연결된 관계 타입에 따라 결정
String resolveGhostLabel(NodeModel node, List<NodeEdge> edges) {
  if (!node.isGhost) return '';

  // 이 Ghost 노드와 연결된 edge 찾기
  final connectedEdges = edges.where(
    (e) => e.fromNodeId == node.id || e.toNodeId == node.id,
  );

  if (connectedEdges.isEmpty) return '?';

  // 연결된 관계 타입으로 라벨 결정
  for (final edge in connectedEdges) {
    switch (edge.relation) {
      case RelationType.parent:
      case RelationType.child:
        return '알 수 없는 조상';
      case RelationType.spouse:
        return '미확인 배우자';
      case RelationType.other:
        return '관계 미상';
      case RelationType.sibling:
        return '?';
    }
  }

  return '?';
}

/// 캔버스 위 인물 노드 카드
class NodeCard extends StatefulWidget {
  const NodeCard({
    super.key,
    required this.node,
    required this.isSelected,
    required this.isConnectSource,
    required this.isConnectMode,
    this.ghostLabel,
    this.earnedBadgeIds,
    this.showHolidayGlow = false,
    this.isMe = false,
    this.unreadBouquetCount = 0,
  });

  final NodeModel node;
  final bool isSelected;
  final bool isConnectSource;
  final bool isConnectMode;

  /// Ghost 노드에 표시할 라벨 (null이면 기본 '미확인')
  final String? ghostLabel;

  /// 이 노드에 연관된 획득 배지 ID 목록
  final List<String>? earnedBadgeIds;

  /// 명절 기간 조상 노드 glow 여부
  final bool showHolidayGlow;

  /// 이 노드가 "나"인지 여부
  final bool isMe;

  /// 읽지 않은 받은 마음 수 ("나" 노드에서 N 뱃지 표시용)
  final int unreadBouquetCount;

  @override
  State<NodeCard> createState() => _NodeCardState();
}

class _NodeCardState extends State<NodeCard>
    with TickerProviderStateMixin {
  // ── 연결 모드 pulse ──────────────────────────────────────────────────────
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  // ── Ghost → 실제 인물 전환 fill 애니메이션 ────────────────────────────────
  late AnimationController _fillController;
  late Animation<double> _fillScale;
  bool _wasGhost = false;

  @override
  void initState() {
    super.initState();
    _wasGhost = widget.node.isGhost;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    // 연결 모드 소스일 때만 pulse 시작
    if (widget.isConnectSource) {
      _pulseController.repeat(reverse: true);
    }
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fillController = AnimationController(
      vsync: this,
      duration: AppMotion.ghostFill,
    );
    // scale: 1.0 → 1.2 → 1.0
    _fillScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_fillController);
  }

  @override
  void didUpdateWidget(NodeCard old) {
    super.didUpdateWidget(old);
    // 연결 모드 pulse 시작/중지
    if (widget.isConnectSource && !old.isConnectSource) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isConnectSource && old.isConnectSource) {
      _pulseController.stop();
      _pulseController.value = 0;
    }
    // Ghost → 실제 인물 전환 감지
    if (_wasGhost && !widget.node.isGhost) {
      _fillController.forward(from: 0);
      HapticService.ghostFill();
    }
    _wasGhost = widget.node.isGhost;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final node = widget.node;
    final tempColor = AppColors.tempColor(node.temperature);

    final ghostLabelText = widget.ghostLabel ?? '미확인';
    final semanticsLabel = node.isGhost
        ? '$ghostLabelText${node.name.isNotEmpty ? " ${node.name}" : ""}'
        : !node.isAlive
            ? '${node.name}, 고인'
            : node.name;

    return Semantics(
      label: semanticsLabel,
      hint: '탭하면 상세 정보를 볼 수 있습니다',
      button: true,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseAnim, _fillScale]),
        builder: (context, child) {
          final pulseScale = widget.isConnectSource ? _pulseAnim.value : 1.0;
          final fillS = _fillScale.value;
          return Transform.scale(
            scale: pulseScale * fillS,
            child: child!,
          );
        },
        child: Opacity(
          opacity: (!node.isGhost && !node.isAlive) ? 0.7 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: kNodeCardWidth,
            height: kNodeCardHeight,
            decoration: _buildDecoration(node, tempColor),
            child: node.isGhost
                ? _GhostContent(node: node, ghostLabel: ghostLabelText)
                : Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _NormalContent(node: node, tempColor: tempColor),
                      if (!node.isAlive)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: AppColors.textSecondary.withAlpha(80),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              Icons.local_florist,
                              size: 16,
                              color: AppColors.textPrimary.withAlpha(180),
                            ),
                          ),
                        ),
                      // "나" 표시 (좌상단)
                      if (widget.isMe)
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '나',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      // 배지 아이콘 (첫 번째 배지만 표시)
                      if (widget.earnedBadgeIds != null &&
                          widget.earnedBadgeIds!.isNotEmpty)
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: _BadgeIcon(
                            badgeId: widget.earnedBadgeIds!.first,
                          ),
                        ),
                      // 읽지 않은 마음 N 뱃지 ("나" 노드 우상단)
                      if (widget.isMe && widget.unreadBouquetCount > 0)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.bgBase,
                                width: 1.5,
                              ),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 20,
                              minHeight: 20,
                            ),
                            child: Text(
                              '${widget.unreadBouquetCount}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration(NodeModel node, Color baseColor) {
    // 돌아가신 분은 회색 테두리로 존경의 의미 표현
    const deceasedBorderColor = Color(0xFF8E8E93);
    final tempColor = node.isAlive ? baseColor : deceasedBorderColor;

    if (node.isGhost) {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.glassSurface,
        border: Border.all(
          color: AppColors.glassBorder,
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x40000000), blurRadius: 8),
        ],
      );
    }

    // "나" 노드는 primary 테두리
    final borderColor = widget.isSelected
        ? AppColors.nodeSelected
        : widget.isMe
            ? AppColors.primary.withAlpha(200)
            : widget.isConnectMode && !widget.isConnectSource
                ? tempColor.withAlpha(200)
                : tempColor.withAlpha(200);
    final borderWidth = widget.isSelected ? 2.5 : widget.isMe ? 2.0 : 1.5;

    return BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: AppColors.glassSurface,
      border: Border.all(
        color: borderColor,
        width: borderWidth,
      ),
      boxShadow: widget.isSelected
          ? const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 10,
                spreadRadius: 0,
              ),
            ]
          : const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
    );
  }
}

/// 일반 노드 콘텐츠
class _NormalContent extends StatelessWidget {
  const _NormalContent({required this.node, required this.tempColor});

  final NodeModel node;
  final Color tempColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 아바타
          _NodeAvatar(node: node, size: 52),
          const SizedBox(height: 6),
          // 이름
          SizedBox(
            width: double.infinity,
            child: Text(
              node.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          if (node.birthDate != null) ...[
            const SizedBox(height: 2),
            SizedBox(
              width: double.infinity,
              child: Text(
                '${node.birthDate!.year}년생',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          const SizedBox(height: 4),
          // 온도 인디케이터 (돌아가신 분은 회색)
          Container(
            width: 28,
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: node.isAlive ? tempColor : const Color(0xFF8E8E93),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ghost Node 콘텐츠 (반투명, 관계 기반 라벨)
class _GhostContent extends StatelessWidget {
  const _GhostContent({required this.node, required this.ghostLabel});
  final NodeModel node;
  final String ghostLabel;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.70,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.glassBorder, width: 1.5),
                color: AppColors.glassSurface,
              ),
              child: Icon(Icons.help_outline, color: AppColors.textTertiary, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              node.name.isEmpty ? ghostLabel : node.name,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              ghostLabel,
              style: TextStyle(fontSize: 9, color: AppColors.textTertiary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// 노드 아바타 (사진 or 이니셜) — Hero 태그 포함
class _NodeAvatar extends StatelessWidget {
  const _NodeAvatar({required this.node, required this.size});

  final NodeModel node;
  final double size;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = node.photoPath != null;
    // 상대 경로를 절대 경로로 복원 (레거시 절대 경로도 호환)
    final resolvedFile = hasPhoto ? PathUtils.resolveFile(node.photoPath) : null;
    final fileExists = resolvedFile != null && resolvedFile.existsSync();
    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withAlpha(60),
        image: fileExists
            ? DecorationImage(
                image: FileImage(resolvedFile),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: fileExists
          ? null
          : Center(
              child: Icon(
                Icons.person,
                size: size * 0.5,
                color: AppColors.textPrimary,
              ),
            ),
    );
    return Hero(
      tag: 'node_avatar_${node.id}',
      flightShuttleBuilder: (context, animation, direction, from, to) => ScaleTransition(
        scale: animation,
        child: avatar,
      ),
      child: avatar,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOD 변형 위젯들
// ─────────────────────────────────────────────────────────────────────────────

/// 배지 아이콘 위젯 (노드 우하단 16px)
class _BadgeIcon extends StatelessWidget {
  const _BadgeIcon({required this.badgeId});
  final String badgeId;

  @override
  Widget build(BuildContext context) {
    final badge = BadgeDefinition.fromId(badgeId);
    if (badge == null) return const SizedBox.shrink();

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withAlpha(50),
        border: Border.all(color: AppColors.primary.withAlpha(100), width: 0.5),
      ),
      child: Icon(
        badge.icon,
        size: 12,
        color: AppColors.primary,
      ),
    );
  }
}

/// LOD 기반 노드 렌더러 — 줌 레벨에 따라 다른 표현 사용
class NodeCardLod extends StatelessWidget {
  const NodeCardLod({
    super.key,
    required this.node,
    required this.lodLevel,
    required this.isSelected,
    required this.isConnectSource,
    required this.isConnectMode,
    this.ghostLabel,
    this.earnedBadgeIds,
    this.showHolidayGlow = false,
    this.isMe = false,
    this.unreadBouquetCount = 0,
  });

  final NodeModel node;
  final LodLevel lodLevel;
  final bool isSelected;
  final bool isConnectSource;
  final bool isConnectMode;

  /// Ghost 노드에 표시할 라벨
  final String? ghostLabel;

  /// 이 노드에 연관된 획득 배지 ID 목록
  final List<String>? earnedBadgeIds;

  /// 명절 기간 조상 노드 glow 여부
  final bool showHolidayGlow;

  /// 이 노드가 "나"인지 여부
  final bool isMe;

  /// 읽지 않은 받은 마음 수 ("나" 노드에서 N 뱃지 표시용)
  final int unreadBouquetCount;

  @override
  Widget build(BuildContext context) {
    // 모든 줌 레벨에서 항상 풀 카드 표시 (LOD 점/아바타 모드 제거)
    return NodeCard(
      node: node,
      isSelected: isSelected,
      isConnectSource: isConnectSource,
      isConnectMode: isConnectMode,
      ghostLabel: ghostLabel,
      earnedBadgeIds: earnedBadgeIds,
      showHolidayGlow: showHolidayGlow,
      isMe: isMe,
      unreadBouquetCount: unreadBouquetCount,
    );
  }
}


/// Ghost Node 점선 테두리 (CustomPainter)
class GhostNodeBorder extends CustomPainter {
  const GhostNodeBorder();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.glassBorder
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    const radius = 16.0;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(radius),
      ));

    _drawDashedPath(canvas, path, paint, dashWidth, dashSpace);
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint,
    double dashWidth,
    double dashSpace,
  ) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
