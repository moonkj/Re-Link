import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/utils/haptic_service.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../models/clan_data.dart';

/// 공유용 성씨 카드 — RepaintBoundary 캡처 → PNG → 공유
class ClanShareCard extends StatefulWidget {
  const ClanShareCard({
    super.key,
    required this.clan,
    required this.surname,
  });

  final ClanInfo clan;
  final String surname;

  @override
  State<ClanShareCard> createState() => _ClanShareCardState();
}

class _ClanShareCardState extends State<ClanShareCard> {
  final GlobalKey _repaintKey = GlobalKey();
  bool _sharing = false;

  Future<void> _shareCard() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    HapticService.medium();

    try {
      final boundary = _repaintKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final bytes = byteData.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/clan_card_${widget.surname}_${widget.clan.origin}.png');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: '${widget.surname}(${widget.clan.origin}) 가문 — Re-Link',
      );
    } catch (_) {
      // 공유 실패 시 무시
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 캡처 대상 카드
        RepaintBoundary(
          key: _repaintKey,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxl,
              vertical: AppSpacing.xxxl,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryMint,
                  AppColors.primaryBlue,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 성씨
                Text(
                  widget.surname,
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.1,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                // 본관
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Colors.white.withAlpha(40),
                  ),
                  child: Text(
                    '${widget.clan.origin} ${widget.surname}씨',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                // 시조
                _InfoRow(label: '시조', value: widget.clan.founder),
                if (widget.clan.foundedYearFormatted != null)
                  _InfoRow(
                    label: '설립',
                    value: widget.clan.foundedYearFormatted!,
                  ),
                _InfoRow(
                  label: '인구',
                  value: widget.clan.populationFormatted,
                ),
                const SizedBox(height: AppSpacing.xl),
                // 워터마크
                Text(
                  'Re-Link에서 우리 가족 이야기를 기록하세요',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withAlpha(140),
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.none,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        // 공유 버튼
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _sharing ? null : _shareCard,
            icon: _sharing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.share, size: 20),
            label: Text(_sharing ? '공유 준비 중...' : '카드 공유하기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$label  ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withAlpha(180),
              fontWeight: FontWeight.w400,
              decoration: TextDecoration.none,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}
