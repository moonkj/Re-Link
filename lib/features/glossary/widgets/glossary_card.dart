import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_radius.dart';
import '../../../design/tokens/app_spacing.dart';

/// 단어장 카드 위젯 — 탭하면 확장 토글, 음성 재생 지원
class GlossaryCard extends StatefulWidget {
  const GlossaryCard({
    super.key,
    required this.entry,
    this.nodeName,
    required this.onDelete,
  });

  final GlossaryTableData entry;
  final String? nodeName;
  final VoidCallback onDelete;

  @override
  State<GlossaryCard> createState() => _GlossaryCardState();
}

class _GlossaryCardState extends State<GlossaryCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  // ── 음성 재생 ─────────────────────────────────────────────────────────────
  PlayerController? _playerCtrl;
  bool _isPlaying = false;

  void _toggleExpand() {
    HapticService.light();
    setState(() => _expanded = !_expanded);
  }

  @override
  void dispose() {
    _playerCtrl?.stopPlayer();
    _playerCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;

    return GlassCard(
      onTap: _toggleExpand,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 단어 (큰 폰트) + 음성 버튼 ──────────────────────────
          Row(
            children: [
              Expanded(
                child: Text(
                  entry.word,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              // 음성 재생 버튼 (voicePath 있을 때)
              if (entry.voicePath != null &&
                  entry.voicePath!.isNotEmpty)
                GestureDetector(
                  onTap: _toggleVoicePlayback,
                  child: Container(
                    width: 30,
                    height: 30,
                    margin: const EdgeInsets.only(right: AppSpacing.xs),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isPlaying
                          ? AppColors.primary.withAlpha(30)
                          : AppColors.glassSurface,
                      border: Border.all(
                        color: _isPlaying
                            ? AppColors.primary.withAlpha(80)
                            : AppColors.glassBorder,
                        width: 0.5,
                      ),
                    ),
                    child: Icon(
                      _isPlaying
                          ? Icons.stop_rounded
                          : Icons.play_arrow_rounded,
                      size: 16,
                      color: _isPlaying
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              // 연결된 노드 뱃지
              if (widget.nodeName != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(25),
                    borderRadius: AppRadius.radiusSm,
                    border: Border.all(
                      color: AppColors.primary.withAlpha(60),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    widget.nodeName!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),

          // ── 뜻 ───────────────────────────────────────────────
          Text(
            entry.meaning,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),

          // ── 확장 영역 (예문 + 삭제) ──────────────────────────
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildExpandedContent(entry),
            crossFadeState:
                _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(GlossaryTableData entry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 예문
        if (entry.example != null && entry.example!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.glassSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '"${entry.example!}"',
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],

        const SizedBox(height: AppSpacing.md),

        // 등록 날짜 + 삭제 버튼
        Row(
          children: [
            Icon(Icons.access_time, size: 12, color: AppColors.textTertiary),
            const SizedBox(width: 4),
            Text(
              _formatDate(entry.createdAt),
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                HapticService.medium();
                _showDeleteConfirm(context);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete_outline,
                        size: 14, color: AppColors.error.withAlpha(180)),
                    const SizedBox(width: 4),
                    Text(
                      '삭제',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.error.withAlpha(180),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── 음성 재생 제어 ──────────────────────────────────────────────────────────

  Future<void> _toggleVoicePlayback() async {
    final voicePath = widget.entry.voicePath;
    if (voicePath == null || voicePath.isEmpty) return;

    HapticService.selection();

    if (_isPlaying) {
      await _playerCtrl?.stopPlayer();
      if (mounted) setState(() => _isPlaying = false);
      return;
    }

    // 처음 재생이거나 playerCtrl 없으면 초기화
    if (_playerCtrl == null) {
      _playerCtrl = PlayerController();
      await _playerCtrl!.preparePlayer(path: voicePath);
      _playerCtrl!.onPlayerStateChanged.listen((state) {
        if (!mounted) return;
        if (state == PlayerState.stopped || state == PlayerState.paused) {
          setState(() => _isPlaying = false);
        }
      });
      _playerCtrl!.onCompletion.listen((_) {
        if (mounted) setState(() => _isPlaying = false);
      });
    }

    await _playerCtrl!.startPlayer();
    if (mounted) setState(() => _isPlaying = true);
  }

  void _showDeleteConfirm(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('단어 삭제'),
        content:
            Text('"${widget.entry.word}"을(를) 단어장에서 삭제할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(true);
              widget.onDelete();
            },
            child: Text('삭제', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
}
