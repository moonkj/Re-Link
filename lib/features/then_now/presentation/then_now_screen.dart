import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../design/motion/app_motion.dart';
import '../../../shared/repositories/memory_repository.dart';
import '../providers/then_now_notifier.dart';
import '../widgets/comparison_slider.dart';
import '../widgets/then_now_card.dart';

/// Then & Now 비교 뷰 전체 화면
/// memoryId1(과거) + memoryId2(현재)를 받아 비교 슬라이더 표시
class ThenNowScreen extends ConsumerStatefulWidget {
  const ThenNowScreen({
    super.key,
    required this.memoryId1,
    required this.memoryId2,
    this.label,
  });

  final String memoryId1;
  final String memoryId2;
  final String? label;

  @override
  ConsumerState<ThenNowScreen> createState() => _ThenNowScreenState();
}

class _ThenNowScreenState extends ConsumerState<ThenNowScreen>
    with SingleTickerProviderStateMixin {
  final _shareCardKey = GlobalKey();
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  bool _isSharing = false;
  bool _isSaved = false;
  String? _label;

  // 메모리 데이터
  String? _beforePath;
  String? _afterPath;
  DateTime? _beforeDate;
  DateTime? _afterDate;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _label = widget.label;
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: AppMotion.slow,
    );
    _fadeAnim = CurvedAnimation(
      parent: _fadeCtrl,
      curve: AppMotion.enter,
    );
    _loadMemories();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMemories() async {
    try {
      final repo = ref.read(memoryRepositoryProvider);
      final m1 = await repo.getById(widget.memoryId1);
      final m2 = await repo.getById(widget.memoryId2);

      if (m1 == null || m2 == null) {
        if (mounted) {
          setState(() {
            _error = '기억을 찾을 수 없습니다.';
            _loading = false;
          });
        }
        return;
      }

      if (m1.filePath == null || m2.filePath == null) {
        if (mounted) {
          setState(() {
            _error = '사진 파일이 존재하지 않습니다.';
            _loading = false;
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          _beforePath = m1.filePath;
          _afterPath = m2.filePath;
          _beforeDate = m1.dateTaken;
          _afterDate = m2.dateTaken;
          _loading = false;
        });
        _fadeCtrl.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '기억을 불러오는데 실패했습니다.';
          _loading = false;
        });
      }
    }
  }

  Future<void> _savePair() async {
    if (_isSaved) return;
    try {
      await ref.read(thenNowNotifierProvider.notifier).createPair(
            memoryId1: widget.memoryId1,
            memoryId2: widget.memoryId2,
            label: _label,
          );
      if (mounted) {
        setState(() => _isSaved = true);
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Then & Now가 저장되었습니다.'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('저장에 실패했습니다.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _shareAsImage() async {
    if (_isSharing || _beforePath == null || _afterPath == null) return;
    setState(() => _isSharing = true);

    try {
      // RepaintBoundary를 이미지로 캡처
      final boundary = _shareCardKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        setState(() => _isSharing = false);
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        setState(() => _isSharing = false);
        return;
      }

      final pngBytes = byteData.buffer.asUint8List();

      // 임시 파일에 저장
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'then_now_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(p.join(tempDir.path, fileName));
      await file.writeAsBytes(pngBytes);

      if (!mounted) return;

      // 공유
      await Share.shareXFiles(
        [XFile(file.path)],
        text: _label != null && _label!.isNotEmpty
            ? '${_label!} - Then & Now | Re-Link'
            : 'Then & Now | Re-Link',
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('공유에 실패했습니다.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  void _editLabel() {
    final controller = TextEditingController(text: _label ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '라벨 편집',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 30,
          style: TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: '예: 우리집 앞, 졸업식',
            hintStyle: TextStyle(color: AppColors.textTertiary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.glassBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('취소', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              setState(() => _label = controller.text.trim().isEmpty
                  ? null
                  : controller.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('확인', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withAlpha(100),
            ),
            child: const Icon(Icons.close, color: Colors.white, size: 22),
          ),
        ),
        title: Text(
          'Then & Now',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 메인 콘텐츠
          if (_loading)
            const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            )
          else if (_error != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 48, color: AppColors.textTertiary),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _error!,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  // 비교 슬라이더 (메인 영역)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top +
                            AppSpacing.appBarHeight,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: ComparisonSlider(
                          beforeImagePath: _beforePath!,
                          afterImagePath: _afterPath!,
                        ),
                      ),
                    ),
                  ),

                  // 하단 바 — 라벨 + 저장 + 공유
                  _BottomBar(
                    label: _label,
                    isSaved: _isSaved,
                    isSharing: _isSharing,
                    onEditLabel: _editLabel,
                    onSave: _savePair,
                    onShare: _shareAsImage,
                  ),
                ],
              ),
            ),

          // 공유용 숨겨진 카드 (화면 밖으로 위치시켜 렌더링은 되지만 안 보임)
          if (_beforePath != null && _afterPath != null)
            Positioned(
              left: -9999,
              top: -9999,
              child: ThenNowCard(
                repaintKey: _shareCardKey,
                beforeImagePath: _beforePath!,
                afterImagePath: _afterPath!,
                label: _label,
                beforeDate: _beforeDate,
                afterDate: _afterDate,
              ),
            ),
        ],
      ),
    );
  }
}

/// 하단 바 (라벨, 저장, 공유 버튼)
class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.label,
    required this.isSaved,
    required this.isSharing,
    required this.onEditLabel,
    required this.onSave,
    required this.onShare,
  });

  final String? label;
  final bool isSaved;
  final bool isSharing;
  final VoidCallback onEditLabel;
  final VoidCallback onSave;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        MediaQuery.of(context).padding.bottom + AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        border: Border(
          top: BorderSide(color: AppColors.glassBorder, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // 라벨 칩
          Expanded(
            child: GestureDetector(
              onTap: onEditLabel,
              child: GlassCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.label_outline,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        label ?? '라벨 추가',
                        style: TextStyle(
                          fontSize: 14,
                          color: label != null
                              ? AppColors.textPrimary
                              : AppColors.textTertiary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // 저장 버튼
          GlassButton(
            onPressed: isSaved ? null : onSave,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSaved ? Icons.check_rounded : Icons.bookmark_add_outlined,
                  size: 18,
                  color: isSaved ? AppColors.success : Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  isSaved ? '저장됨' : '저장',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSaved ? AppColors.success : Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // 공유 버튼
          GlassButton(
            onPressed: isSharing ? null : onShare,
            backgroundColor: AppColors.primary.withAlpha(60),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: isSharing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(
                    Icons.share_outlined,
                    size: 18,
                    color: Colors.white,
                  ),
          ),
        ],
      ),
    );
  }
}
