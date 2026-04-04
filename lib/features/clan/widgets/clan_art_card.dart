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
import 'art_card_style_selector.dart';
import 'clan_art_card_painter.dart';

/// 성씨 아트 카드 — CustomPainter 기반 3스타일 카드 + 공유
///
/// RepaintBoundary → PNG 캡처 → share_plus 공유 패턴 사용.
/// [ClanShareCard]의 캡처/공유 패턴을 재사용.
class ClanArtCard extends StatefulWidget {
  const ClanArtCard({
    super.key,
    required this.clan,
    required this.surname,
  });

  final ClanInfo clan;
  final String surname;

  @override
  State<ClanArtCard> createState() => _ClanArtCardState();
}

class _ClanArtCardState extends State<ClanArtCard> {
  final GlobalKey _repaintKey = GlobalKey();
  ArtCardStyle _selectedStyle = ArtCardStyle.hanji;
  bool _sharing = false;

  // ── 캡처 & 공유 ─────────────────────────────────────────────────────────

  Future<void> _shareCard() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    HapticService.medium();

    try {
      final ctx = _repaintKey.currentContext;
      if (ctx == null) return;
      final boundary = ctx.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final bytes = byteData.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File(
        '${dir.path}/clan_art_${widget.surname}_${widget.clan.origin}_$timestamp.png',
      );
      await file.writeAsBytes(bytes);

      final box = _repaintKey.currentContext?.findRenderObject() as RenderBox?;
      await Share.shareXFiles(
        [XFile(file.path)],
        text: '${widget.surname}(${widget.clan.origin}) 가문 아트 카드 — Re-Link',
        sharePositionOrigin: box != null
            ? box.localToGlobal(Offset.zero) & box.size
            : null,
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
        // ── 카드 미리보기 (캡처 대상) ────────────────────────────────────
        Container(
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: RepaintBoundary(
              key: _repaintKey,
              child: CustomPaint(
                size: const Size(360, 450), // 360pt -> 캡처 시 3x = 1080px
                painter: ClanArtCardPainter(
                  clan: widget.clan,
                  surname: widget.surname,
                  style: _selectedStyle,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        // ── 스타일 선택기 ────────────────────────────────────────────────
        ArtCardStyleSelector(
          selectedStyle: _selectedStyle,
          onStyleChanged: (style) {
            setState(() => _selectedStyle = style);
          },
        ),

        const SizedBox(height: AppSpacing.xl),

        // ── 공유 버튼 ────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: SizedBox(
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
              label: Text(_sharing ? '공유 준비 중...' : '아트 카드 공유하기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
