import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/clan_data.dart';

/// 아트 카드 스타일 3종
enum ArtCardStyle {
  hanji('한지'),
  modern('모던'),
  inkWash('수묵화');

  const ArtCardStyle(this.label);
  final String label;
}

/// 성씨 아트 카드 CustomPainter — 3가지 스타일 모드
///
/// 각 스타일별 구성:
/// 1. 배경 (background)
/// 2. 장식 패턴 (decorative pattern)
/// 3. 텍스트 정보 (surname, origin, founder, population)
class ClanArtCardPainter extends CustomPainter {
  ClanArtCardPainter({
    required this.clan,
    required this.surname,
    required this.style,
  });

  final ClanInfo clan;
  final String surname;
  final ArtCardStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    switch (style) {
      case ArtCardStyle.hanji:
        _paintHanji(canvas, size);
      case ArtCardStyle.modern:
        _paintModern(canvas, size);
      case ArtCardStyle.inkWash:
        _paintInkWash(canvas, size);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ── 한지 (Hanji) — 따뜻한 크림색, 섬유 질감, 먹글씨, 전통 테두리 ────────────
  // ═══════════════════════════════════════════════════════════════════════════

  void _paintHanji(Canvas canvas, Size size) {
    const bgColor = Color(0xFFF5E6D3);
    const inkColor = Color(0xFF2C1810);
    const borderColor = Color(0xFF8B6914);
    const fiberColor = Color(0x18704020);

    // ── 배경 ─────────────────────────────────────────────────────────────
    final bgPaint = Paint()..color = bgColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // ── 섬유 질감 선 ─────────────────────────────────────────────────────
    final fiberPaint = Paint()
      ..color = fiberColor
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final rng = math.Random(42);
    for (var i = 0; i < 40; i++) {
      final y = rng.nextDouble() * size.height;
      final startX = rng.nextDouble() * size.width * 0.3;
      final endX = startX + rng.nextDouble() * size.width * 0.5 + 20;
      canvas.drawLine(
        Offset(startX, y + rng.nextDouble() * 3),
        Offset(endX, y + rng.nextDouble() * 3),
        fiberPaint,
      );
    }

    // ── 전통 테두리 (이중선) ─────────────────────────────────────────────
    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final outerRect = Rect.fromLTWH(12, 12, size.width - 24, size.height - 24);
    canvas.drawRect(outerRect, borderPaint);

    final innerPaint = Paint()
      ..color = borderColor.withAlpha(100)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    final innerRect = Rect.fromLTWH(18, 18, size.width - 36, size.height - 36);
    canvas.drawRect(innerRect, innerPaint);

    // ── 모서리 장식 ──────────────────────────────────────────────────────
    final cornerPaint = Paint()
      ..color = borderColor.withAlpha(140)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // 좌상
    canvas.drawLine(const Offset(12, 32), const Offset(32, 12), cornerPaint);
    // 우상
    canvas.drawLine(
        Offset(size.width - 12, 32), Offset(size.width - 32, 12), cornerPaint);
    // 좌하
    canvas.drawLine(
        Offset(12, size.height - 32), Offset(32, size.height - 12), cornerPaint);
    // 우하
    canvas.drawLine(Offset(size.width - 12, size.height - 32),
        Offset(size.width - 32, size.height - 12), cornerPaint);

    // ── 성씨 (대형 먹글씨 스타일) ───────────────────────────────────────
    _drawText(
      canvas,
      surname,
      offset: Offset(size.width / 2, size.height * 0.22),
      fontSize: 64,
      fontWeight: FontWeight.w900,
      color: inkColor,
      align: TextAlign.center,
      maxWidth: size.width - 60,
    );

    // ── 구분선 ───────────────────────────────────────────────────────────
    final dividerPaint = Paint()
      ..color = borderColor.withAlpha(120)
      ..strokeWidth = 1.0;
    canvas.drawLine(
      Offset(size.width * 0.3, size.height * 0.38),
      Offset(size.width * 0.7, size.height * 0.38),
      dividerPaint,
    );

    // ── 본관 ─────────────────────────────────────────────────────────────
    _drawText(
      canvas,
      '${clan.origin} $surname씨',
      offset: Offset(size.width / 2, size.height * 0.44),
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: inkColor.withAlpha(200),
      align: TextAlign.center,
      maxWidth: size.width - 60,
    );

    // ── 시조 ─────────────────────────────────────────────────────────────
    _drawText(
      canvas,
      '시조  ${clan.founder}',
      offset: Offset(size.width / 2, size.height * 0.54),
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: inkColor.withAlpha(180),
      align: TextAlign.center,
      maxWidth: size.width - 60,
    );

    // ── 설립 연도 ────────────────────────────────────────────────────────
    if (clan.foundedYearFormatted != null) {
      _drawText(
        canvas,
        clan.foundedYearFormatted!,
        offset: Offset(size.width / 2, size.height * 0.60),
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: inkColor.withAlpha(140),
        align: TextAlign.center,
        maxWidth: size.width - 60,
      );
    }

    // ── 인구 ─────────────────────────────────────────────────────────────
    _drawText(
      canvas,
      '인구  ${clan.populationFormatted}',
      offset: Offset(size.width / 2, size.height * 0.68),
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: inkColor.withAlpha(160),
      align: TextAlign.center,
      maxWidth: size.width - 60,
    );

    // ── 워터마크 ─────────────────────────────────────────────────────────
    _drawText(
      canvas,
      'Re-Link에서 우리 가족 이야기를 기록하세요',
      offset: Offset(size.width / 2, size.height * 0.90),
      fontSize: 9,
      fontWeight: FontWeight.w300,
      color: inkColor.withAlpha(80),
      align: TextAlign.center,
      maxWidth: size.width - 60,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ── 모던 (Modern) — Mint→Blue 그라디언트, 그리드 패턴, 원형 엠블럼 ──────────
  // ═══════════════════════════════════════════════════════════════════════════

  void _paintModern(Canvas canvas, Size size) {
    const mintColor = Color(0xFF6EC6CA);
    const blueColor = Color(0xFF4A9EBF);
    const textColor = Color(0xFFFFFFFF);

    // ── 그라디언트 배경 ──────────────────────────────────────────────────
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [mintColor, blueColor],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // ── 그리드 패턴 ──────────────────────────────────────────────────────
    final gridPaint = Paint()
      ..color = const Color(0x12FFFFFF)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    const gridStep = 24.0;
    for (var x = 0.0; x < size.width; x += gridStep) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (var y = 0.0; y < size.height; y += gridStep) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // ── 원형 엠블럼 ──────────────────────────────────────────────────────
    final circleCx = size.width / 2;
    final circleCy = size.height * 0.28;
    const circleRadius = 52.0;

    final circleOutlinePaint = Paint()
      ..color = const Color(0x40FFFFFF)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(circleCx, circleCy), circleRadius, circleOutlinePaint);

    final circleInnerPaint = Paint()
      ..color = const Color(0x15FFFFFF)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(circleCx, circleCy), circleRadius - 4, circleInnerPaint);

    // ── 성씨 (엠블럼 내부) ──────────────────────────────────────────────
    _drawText(
      canvas,
      surname,
      offset: Offset(circleCx, circleCy),
      fontSize: 42,
      fontWeight: FontWeight.w700,
      color: textColor,
      align: TextAlign.center,
      maxWidth: circleRadius * 2,
    );

    // ── 본관 ─────────────────────────────────────────────────────────────
    // 배지 배경
    final badgeCy = size.height * 0.48;
    final badgeText = '${clan.origin} $surname씨';
    final badgeTP = _makeTextPainter(
      badgeText,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: textColor,
      maxWidth: size.width - 60,
    );
    final badgeWidth = badgeTP.width + 32;
    final badgeHeight = badgeTP.height + 12;
    final badgeRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset(size.width / 2, badgeCy),
          width: badgeWidth,
          height: badgeHeight),
      const Radius.circular(100),
    );
    final badgePaint = Paint()..color = const Color(0x30FFFFFF);
    canvas.drawRRect(badgeRect, badgePaint);
    badgeTP.paint(
      canvas,
      Offset(size.width / 2 - badgeTP.width / 2, badgeCy - badgeTP.height / 2),
    );

    // ── 시조 ─────────────────────────────────────────────────────────────
    _drawText(
      canvas,
      '시조  ${clan.founder}',
      offset: Offset(size.width / 2, size.height * 0.58),
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: textColor.withAlpha(220),
      align: TextAlign.center,
      maxWidth: size.width - 60,
    );

    // ── 설립 연도 ────────────────────────────────────────────────────────
    if (clan.foundedYearFormatted != null) {
      _drawText(
        canvas,
        clan.foundedYearFormatted!,
        offset: Offset(size.width / 2, size.height * 0.64),
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: textColor.withAlpha(180),
        align: TextAlign.center,
        maxWidth: size.width - 60,
      );
    }

    // ── 인구 ─────────────────────────────────────────────────────────────
    _drawText(
      canvas,
      '인구  ${clan.populationFormatted}',
      offset: Offset(size.width / 2, size.height * 0.70),
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: textColor.withAlpha(200),
      align: TextAlign.center,
      maxWidth: size.width - 60,
    );

    // ── 하단 악센트 라인 ─────────────────────────────────────────────────
    final linePaint = Paint()
      ..color = const Color(0x40FFFFFF)
      ..strokeWidth = 1.0;
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.80),
      Offset(size.width * 0.75, size.height * 0.80),
      linePaint,
    );

    // ── 워터마크 ─────────────────────────────────────────────────────────
    _drawText(
      canvas,
      'Re-Link에서 우리 가족 이야기를 기록하세요',
      offset: Offset(size.width / 2, size.height * 0.90),
      fontSize: 9,
      fontWeight: FontWeight.w300,
      color: textColor.withAlpha(120),
      align: TextAlign.center,
      maxWidth: size.width - 60,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ── 수묵화 (Ink Wash) — 흰/회 배경, 먹 번짐, 산 실루엣, 먹 텍스트 ──────────
  // ═══════════════════════════════════════════════════════════════════════════

  void _paintInkWash(Canvas canvas, Size size) {
    const bgColor = Color(0xFFF8F6F2);
    const inkColor = Color(0xFF1A1A1A);

    // ── 배경 ─────────────────────────────────────────────────────────────
    final bgPaint = Paint()..color = bgColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // ── 먹 번짐 효과 (상단 좌측) ────────────────────────────────────────
    final inkWashPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width * 0.15, size.height * 0.12),
        size.width * 0.35,
        [
          const Color(0x0E1A1A1A),
          const Color(0x001A1A1A),
        ],
      );
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), inkWashPaint);

    // ── 먹 번짐 효과 (하단 우측) ────────────────────────────────────────
    final inkWash2Paint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width * 0.85, size.height * 0.75),
        size.width * 0.4,
        [
          const Color(0x0A1A1A1A),
          const Color(0x001A1A1A),
        ],
      );
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), inkWash2Paint);

    // ── 산 실루엣 (베지에 곡선) ──────────────────────────────────────────
    final mountainPaint = Paint()
      ..color = const Color(0x0D1A1A1A)
      ..style = PaintingStyle.fill;

    final mountainPath = Path()
      ..moveTo(0, size.height * 0.78)
      ..cubicTo(
        size.width * 0.15,
        size.height * 0.60,
        size.width * 0.25,
        size.height * 0.55,
        size.width * 0.35,
        size.height * 0.65,
      )
      ..cubicTo(
        size.width * 0.42,
        size.height * 0.72,
        size.width * 0.48,
        size.height * 0.50,
        size.width * 0.58,
        size.height * 0.48,
      )
      ..cubicTo(
        size.width * 0.68,
        size.height * 0.46,
        size.width * 0.75,
        size.height * 0.58,
        size.width * 0.85,
        size.height * 0.52,
      )
      ..cubicTo(
        size.width * 0.92,
        size.height * 0.48,
        size.width * 0.97,
        size.height * 0.55,
        size.width,
        size.height * 0.60,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(mountainPath, mountainPaint);

    // ── 두 번째 산 (더 연한 뒤쪽 산) ────────────────────────────────────
    final mountain2Paint = Paint()
      ..color = const Color(0x08505050)
      ..style = PaintingStyle.fill;

    final mountain2Path = Path()
      ..moveTo(0, size.height * 0.85)
      ..cubicTo(
        size.width * 0.20,
        size.height * 0.70,
        size.width * 0.35,
        size.height * 0.62,
        size.width * 0.50,
        size.height * 0.72,
      )
      ..cubicTo(
        size.width * 0.65,
        size.height * 0.80,
        size.width * 0.80,
        size.height * 0.65,
        size.width,
        size.height * 0.70,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(mountain2Path, mountain2Paint);

    // ── 가로 먹 선 (수묵 느낌) ──────────────────────────────────────────
    final strokePaint = Paint()
      ..color = const Color(0x12000000)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(size.width * 0.08, size.height * 0.15),
      Offset(size.width * 0.40, size.height * 0.15),
      strokePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.60, size.height * 0.85),
      Offset(size.width * 0.92, size.height * 0.85),
      strokePaint,
    );

    // ── 성씨 (대형 먹글씨) ──────────────────────────────────────────────
    _drawText(
      canvas,
      surname,
      offset: Offset(size.width / 2, size.height * 0.25),
      fontSize: 60,
      fontWeight: FontWeight.w900,
      color: inkColor.withAlpha(220),
      align: TextAlign.center,
      maxWidth: size.width - 40,
    );

    // ── 구분점 ───────────────────────────────────────────────────────────
    final dotPaint = Paint()
      ..color = inkColor.withAlpha(60)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, size.height * 0.40), 3, dotPaint);

    // ── 본관 ─────────────────────────────────────────────────────────────
    _drawText(
      canvas,
      '${clan.origin} $surname씨',
      offset: Offset(size.width / 2, size.height * 0.46),
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: inkColor.withAlpha(190),
      align: TextAlign.center,
      maxWidth: size.width - 60,
    );

    // ── 시조 ─────────────────────────────────────────────────────────────
    _drawText(
      canvas,
      '시조  ${clan.founder}',
      offset: Offset(size.width / 2, size.height * 0.55),
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: inkColor.withAlpha(150),
      align: TextAlign.center,
      maxWidth: size.width - 60,
    );

    // ── 설립 연도 ────────────────────────────────────────────────────────
    if (clan.foundedYearFormatted != null) {
      _drawText(
        canvas,
        clan.foundedYearFormatted!,
        offset: Offset(size.width / 2, size.height * 0.61),
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: inkColor.withAlpha(120),
        align: TextAlign.center,
        maxWidth: size.width - 60,
      );
    }

    // ── 인구 ─────────────────────────────────────────────────────────────
    _drawText(
      canvas,
      '인구  ${clan.populationFormatted}',
      offset: Offset(size.width / 2, size.height * 0.67),
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: inkColor.withAlpha(140),
      align: TextAlign.center,
      maxWidth: size.width - 60,
    );

    // ── 워터마크 ─────────────────────────────────────────────────────────
    _drawText(
      canvas,
      'Re-Link에서 우리 가족 이야기를 기록하세요',
      offset: Offset(size.width / 2, size.height * 0.92),
      fontSize: 9,
      fontWeight: FontWeight.w300,
      color: inkColor.withAlpha(60),
      align: TextAlign.center,
      maxWidth: size.width - 60,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ── TextPainter 헬퍼 ──────────────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════════════

  /// TextPainter를 생성하고 layout을 수행한 뒤 반환
  TextPainter _makeTextPainter(
    String text, {
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    required double maxWidth,
    TextAlign align = TextAlign.center,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          height: 1.3,
        ),
      ),
      textAlign: align,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
    return tp;
  }

  /// 텍스트를 offset 중심에 그리기
  void _drawText(
    Canvas canvas,
    String text, {
    required Offset offset,
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    required TextAlign align,
    required double maxWidth,
  }) {
    final tp = _makeTextPainter(
      text,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      maxWidth: maxWidth,
      align: align,
    );
    tp.paint(
      canvas,
      Offset(offset.dx - tp.width / 2, offset.dy - tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant ClanArtCardPainter oldDelegate) {
    return oldDelegate.style != style ||
        oldDelegate.surname != surname ||
        oldDelegate.clan != clan;
  }
}
