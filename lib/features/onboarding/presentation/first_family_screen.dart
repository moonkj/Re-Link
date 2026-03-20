import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../features/canvas/providers/node_notifier.dart';
import '../../../shared/models/node_model.dart';
import '../../../shared/repositories/profile_repository.dart';

/// 온보딩 Step 2 — 첫 가족 연결 화면
/// 프로필 설정 후, 캔버스 진입 전에 최초 가족 구성원을 빠르게 추가
class FirstFamilyScreen extends ConsumerStatefulWidget {
  const FirstFamilyScreen({super.key});

  @override
  ConsumerState<FirstFamilyScreen> createState() => _FirstFamilyScreenState();
}

class _FirstFamilyScreenState extends ConsumerState<FirstFamilyScreen>
    with TickerProviderStateMixin {
  NodeModel? _selfNode;
  final List<_FamilyEntry> _entries = [];
  final _nameController = TextEditingController();
  RelationType? _pendingRelation;
  bool _isAdding = false;

  late AnimationController _lineAnimCtrl;
  late Animation<double> _lineAnim;

  @override
  void initState() {
    super.initState();
    _lineAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _lineAnim = CurvedAnimation(
      parent: _lineAnimCtrl,
      curve: Curves.easeOutCubic,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _createSelfNode());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lineAnimCtrl.dispose();
    super.dispose();
  }

  /// 프로필 데이터에서 "나" 노드 자동 생성
  Future<void> _createSelfNode() async {
    final profile = await ref.read(profileRepositoryProvider).getProfile();
    if (profile == null || !mounted) return;

    final node = await ref.read(nodeNotifierProvider.notifier).createNode(
          name: profile.name,
          photoPath: profile.photoPath,
          positionX: 2000,
          positionY: 2000,
        );

    if (mounted && node != null) {
      setState(() => _selfNode = node);
    }
  }

  void _startAdd(RelationType relation) {
    setState(() {
      _pendingRelation = relation;
      _isAdding = true;
      _nameController.clear();
    });
  }

  Future<void> _confirmAdd() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _selfNode == null || _pendingRelation == null) return;

    final offset = _positionOffset(_pendingRelation!, _entries.length);

    final node = await ref.read(nodeNotifierProvider.notifier).createNode(
          name: name,
          positionX: _selfNode!.positionX + offset.dx,
          positionY: _selfNode!.positionY + offset.dy,
        );
    if (node == null || !mounted) return;

    await ref.read(nodeNotifierProvider.notifier).addEdge(
          fromNodeId: _selfNode!.id,
          toNodeId: node.id,
          relation: _pendingRelation!,
        );

    setState(() {
      _entries.add(_FamilyEntry(node: node, relation: _pendingRelation!));
      _pendingRelation = null;
      _isAdding = false;
    });

    // 관계선 그리기 애니메이션 + 햅틱
    _lineAnimCtrl.reset();
    _lineAnimCtrl.forward();
    HapticService.connectionMade();
  }

  void _cancelAdd() {
    setState(() {
      _pendingRelation = null;
      _isAdding = false;
    });
  }

  Offset _positionOffset(RelationType relation, int idx) => switch (relation) {
        RelationType.parent => Offset(idx.isEven ? -150 : 150, -220),
        RelationType.spouse => const Offset(220, 0),
        RelationType.child => Offset(idx * 160.0 - 80, 220),
        RelationType.sibling => Offset(250 + idx * 140.0, 0),
        _ => Offset(200 + idx * 120.0, 0),
      };

  void _finish() {
    if (_entries.isNotEmpty) {
      HapticService.heavy();
    }
    context.go(AppRoutes.canvas);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.2,
            colors: [AppColors.bgSurface, AppColors.bgBase],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 건너뛰기
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: TextButton(
                    onPressed: () => context.go(AppRoutes.canvas),
                    child: Text(
                      '건너뛰기',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 14),
                    ),
                  ),
                ),
              ),

              // 타이틀
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  children: [
                    Text(
                      '첫 가족을\n연결해 보세요',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '나중에 캔버스에서 더 추가할 수 있어요',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // 미니 캔버스 프리뷰
              Expanded(
                child: AnimatedBuilder(
                  animation: _lineAnim,
                  builder: (context, _) {
                    final isDark = Theme.of(context).brightness == Brightness.dark;
                    return CustomPaint(
                      painter: _MiniCanvasPainter(
                        selfName: _selfNode?.name,
                        entries: _entries,
                        lineProgress: _lineAnim.value,
                        isDark: isDark,
                      ),
                      child: const SizedBox.expand(),
                    );
                  },
                ),
              ),

              // 하단 — 관계 버튼 or 이름 입력
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isAdding && _pendingRelation != null)
                      _NameInputCard(
                        relation: _pendingRelation!,
                        controller: _nameController,
                        onConfirm: _confirmAdd,
                        onCancel: _cancelAdd,
                      )
                    else
                      _RelationButtonRow(
                        entries: _entries,
                        onTap: _startAdd,
                      ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      child: PrimaryGlassButton(
                        label: _entries.isEmpty
                            ? '나중에 하기'
                            : '가족 트리 시작하기',
                        onPressed: _finish,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 이름 입력 카드 ─────────────────────────────────────────────────────────────

class _NameInputCard extends StatelessWidget {
  const _NameInputCard({
    required this.relation,
    required this.controller,
    required this.onConfirm,
    required this.onCancel,
  });

  final RelationType relation;
  final TextEditingController controller;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${relation.label} 이름',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: controller,
            autofocus: true,
            style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
            decoration: InputDecoration(
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.glassBorder),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF6EC6CA), width: 2),
              ),
              hintText: '이름을 입력하세요',
              hintStyle: TextStyle(color: AppColors.textTertiary),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onConfirm(),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: onCancel,
                  child: Text('취소',
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: PrimaryGlassButton(
                  label: '연결하기',
                  onPressed: onConfirm,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── 관계 버튼 행 ───────────────────────────────────────────────────────────────

class _RelationButtonRow extends StatelessWidget {
  const _RelationButtonRow({
    required this.entries,
    required this.onTap,
  });

  final List<_FamilyEntry> entries;
  final ValueChanged<RelationType> onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RelationBtn(
          icon: Icons.elderly,
          label: '부모',
          color: const Color(0xFF6EC6CA),
          count: entries
              .where((e) => e.relation == RelationType.parent)
              .length,
          onTap: () => onTap(RelationType.parent),
        ),
        const SizedBox(width: AppSpacing.md),
        _RelationBtn(
          icon: Icons.favorite_outline,
          label: '배우자',
          color: const Color(0xFFF4845F),
          count: entries
              .where((e) => e.relation == RelationType.spouse)
              .length,
          onTap: () => onTap(RelationType.spouse),
        ),
        const SizedBox(width: AppSpacing.md),
        _RelationBtn(
          icon: Icons.child_care,
          label: '자녀',
          color: const Color(0xFF52C77A),
          count: entries
              .where((e) => e.relation == RelationType.child)
              .length,
          onTap: () => onTap(RelationType.child),
        ),
      ],
    );
  }
}

class _RelationBtn extends StatelessWidget {
  const _RelationBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.count,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: GlassCard(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withAlpha(30),
                      border: Border.all(color: color.withAlpha(80)),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  if (count > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                        ),
                        child: Center(
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 모델 ───────────────────────────────────────────────────────────────────────

class _FamilyEntry {
  const _FamilyEntry({required this.node, required this.relation});
  final NodeModel node;
  final RelationType relation;
}

// ── 미니 캔버스 페인터 ─────────────────────────────────────────────────────────

class _MiniCanvasPainter extends CustomPainter {
  _MiniCanvasPainter({
    required this.selfName,
    required this.entries,
    required this.lineProgress,
    required this.isDark,
  });

  final String? selfName;
  final List<_FamilyEntry> entries;
  final double lineProgress;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    if (selfName == null) return;

    final center = Offset(size.width / 2, size.height / 2);

    // "나" 노드
    _drawNode(canvas, center, selfName!, const Color(0xFF6EC6CA), isSelf: true);

    // 가족 노드 + 관계선
    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final pos = _nodePos(center, i, entry.relation);
      final isLast = i == entries.length - 1;
      final progress = isLast ? lineProgress : 1.0;

      // Bezier 관계선
      _drawLine(canvas, center, pos, entry.relation, progress);

      // 노드 (선이 30% 이상 진행 후 페이드인)
      if (progress > 0.3) {
        final opacity = ((progress - 0.3) / 0.7).clamp(0.0, 1.0);
        _drawNode(canvas, pos, entry.node.name,
            _colorFor(entry.relation),
            opacity: opacity);
      }
    }
  }

  void _drawNode(
    Canvas canvas,
    Offset pos,
    String name,
    Color color, {
    bool isSelf = false,
    double opacity = 1.0,
  }) {
    final r = isSelf ? 32.0 : 28.0;

    // 글로우
    canvas.drawCircle(
      pos,
      r + 8,
      Paint()
        ..color = color.withAlpha((40 * opacity).toInt())
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    // 원 배경
    final nodeBg = isDark ? const Color(0xFF1E2840) : const Color(0xFFE8ECF0);
    canvas.drawCircle(
      pos,
      r,
      Paint()
        ..color = Color.lerp(nodeBg, color, 0.3)!
            .withAlpha((220 * opacity).toInt()),
    );

    // 테두리
    canvas.drawCircle(
      pos,
      r,
      Paint()
        ..color = color.withAlpha((180 * opacity).toInt())
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // 이름 — 노드 배경이 컬러 블렌드이므로 흰색 유지
    final tp = TextPainter(
      text: TextSpan(
        text: name.length > 4 ? '${name.substring(0, 3)}…' : name,
        style: TextStyle(
          color: Colors.white.withAlpha((230 * opacity).toInt()),
          fontSize: isSelf ? 13 : 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  void _drawLine(Canvas canvas, Offset from, Offset to, RelationType rel,
      double progress) {
    if (progress <= 0) return;

    final color = _colorFor(rel);
    final target = Offset(
      from.dx + (to.dx - from.dx) * progress,
      from.dy + (to.dy - from.dy) * progress,
    );

    final ctrl = Offset(
      (from.dx + target.dx) / 2 +
          (rel == RelationType.spouse ? 0 : 15),
      (from.dy + target.dy) / 2 -
          (rel == RelationType.parent ? 15 : -10),
    );

    final path = Path()
      ..moveTo(from.dx, from.dy)
      ..quadraticBezierTo(ctrl.dx, ctrl.dy, target.dx, target.dy);

    canvas.drawPath(
      path,
      Paint()
        ..color = color.withAlpha((150 * progress).toInt())
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  Offset _nodePos(Offset center, int idx, RelationType rel) {
    // 같은 관계 타입 내 순서 계산
    int typeIdx = 0;
    for (int i = 0; i < idx; i++) {
      if (entries[i].relation == rel) typeIdx++;
    }

    return switch (rel) {
      RelationType.parent => Offset(
          center.dx + (typeIdx == 0 ? -80 : 80),
          center.dy - 110,
        ),
      RelationType.spouse => Offset(center.dx + 110, center.dy),
      RelationType.child => Offset(
          center.dx + typeIdx * 90.0 - 40,
          center.dy + 110,
        ),
      _ => Offset(center.dx + 120, center.dy + 50),
    };
  }

  Color _colorFor(RelationType rel) => switch (rel) {
        RelationType.parent => const Color(0xFF6EC6CA),
        RelationType.spouse => const Color(0xFFF4845F),
        RelationType.child => const Color(0xFF52C77A),
        _ => const Color(0xFF4A9EBF),
      };

  @override
  bool shouldRepaint(covariant _MiniCanvasPainter old) =>
      old.lineProgress != lineProgress ||
      old.entries.length != entries.length ||
      old.selfName != selfName ||
      old.isDark != isDark;
}
