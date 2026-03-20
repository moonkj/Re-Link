import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../shared/models/memory_model.dart';
import '../../../shared/models/node_model.dart';
import '../../../shared/repositories/memory_repository.dart';
import '../../../shared/repositories/node_repository.dart';
import '../services/snapshot_service.dart';
import '../widgets/poster_template.dart';

/// 기억 스냅샷 공유 화면
/// [memoryId]로 기억 + 노드 데이터를 로드하고 포스터 스타일을 선택하여 공유
class SnapshotShareScreen extends ConsumerStatefulWidget {
  const SnapshotShareScreen({super.key, required this.memoryId});

  final String memoryId;

  @override
  ConsumerState<SnapshotShareScreen> createState() =>
      _SnapshotShareScreenState();
}

class _SnapshotShareScreenState extends ConsumerState<SnapshotShareScreen> {
  final _repaintKey = GlobalKey();
  PosterStyle _selectedStyle = PosterStyle.modern;
  bool _isSharing = false;

  MemoryModel? _memory;
  NodeModel? _node;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final memoryRepo = ref.read(memoryRepositoryProvider);
      final nodeRepo = ref.read(nodeRepositoryProvider);

      final memory = await memoryRepo.getById(widget.memoryId);
      if (memory == null) {
        if (mounted) {
          setState(() {
            _error = '기억을 찾을 수 없습니다.';
            _isLoading = false;
          });
        }
        return;
      }

      final node = await nodeRepo.getById(memory.nodeId);

      if (mounted) {
        setState(() {
          _memory = memory;
          _node = node;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '데이터를 불러올 수 없습니다.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _share() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    try {
      await SnapshotService.captureAndShare(
        _repaintKey,
        text: _memory?.title ?? 'Re-Link 기억 공유',
      );
      HapticService.medium();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('공유에 실패했습니다.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '스냅샷 공유',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
                  ),
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final memory = _memory!;
    final nodeName = _node?.name ?? '알 수 없음';

    return Column(
      children: [
        const SizedBox(height: AppSpacing.md),

        // ── 포스터 미리보기 ────────────────────────────────────────────────────
        Expanded(
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x30000000),
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: RepaintBoundary(
                key: _repaintKey,
                child: PosterCard(
                  style: _selectedStyle,
                  title: memory.title ?? memory.type.label,
                  nodeName: nodeName,
                  description: memory.description,
                  photoPath: memory.filePath,
                  dateTaken: memory.dateTaken,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        // ── 스타일 선택기 ──────────────────────────────────────────────────────
        SizedBox(
          height: 72,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            itemCount: PosterStyle.values.length,
            separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final style = PosterStyle.values[index];
              final isSelected = style == _selectedStyle;
              return _StyleChip(
                style: style,
                isSelected: isSelected,
                onTap: () {
                  HapticService.selection();
                  setState(() => _selectedStyle = style);
                },
              );
            },
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        // ── 공유 버튼 ──────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: SizedBox(
            width: double.infinity,
            child: PrimaryGlassButton(
              label: '공유하기',
              icon: const Icon(Icons.share_outlined, color: Colors.white, size: 18),
              isLoading: _isSharing,
              onPressed: _share,
            ),
          ),
        ),

        SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.xxl),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── 스타일 선택 칩 ─────────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _StyleChip extends StatelessWidget {
  const _StyleChip({
    required this.style,
    required this.isSelected,
    required this.onTap,
  });

  final PosterStyle style;
  final bool isSelected;
  final VoidCallback onTap;

  Color _previewColor() => switch (style) {
        PosterStyle.vintage => const Color(0xFFF5E6D3),
        PosterStyle.modern => const Color(0xFFFFFFFF),
        PosterStyle.emotional => const Color(0xFFF8B4C8),
        PosterStyle.minimal => const Color(0xFFFAFAFA),
      };

  Color _previewAccent() => switch (style) {
        PosterStyle.vintage => const Color(0xFFAA8866),
        PosterStyle.modern => const Color(0xFF6EC6CA),
        PosterStyle.emotional => const Color(0xFFD4A5E5),
        PosterStyle.minimal => const Color(0xFF6EC6CA),
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: 72,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.glassBorder,
            width: isSelected ? 2 : 1,
          ),
          color: AppColors.bgSurface,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 미니 프리뷰
            Container(
              width: 36,
              height: 28,
              decoration: BoxDecoration(
                color: _previewColor(),
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: const Color(0x20000000), width: 0.5),
              ),
              child: Center(
                child: Container(
                  width: 12,
                  height: 2,
                  color: _previewAccent(),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              style.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
