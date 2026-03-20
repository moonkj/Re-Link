import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../design/tokens/app_colors.dart';
import '../providers/family_map_notifier.dart';

/// 한국 지도 좌표 범위 (위도/경도)
class KoreaMapBounds {
  /// 위도: 33.0 (제주 남쪽) ~ 38.6 (북쪽)
  static const double latMin = 33.0;
  static const double latMax = 38.6;

  /// 경도: 124.5 (서쪽) ~ 131.0 (동쪽)
  static const double lngMin = 124.5;
  static const double lngMax = 131.0;

  /// 위도/경도를 Canvas 좌표로 변환
  static Offset toCanvas(double lat, double lng, Size size) {
    final padding = size.width * 0.08;
    final drawW = size.width - padding * 2;
    final drawH = size.height - padding * 2;

    final x = padding + ((lng - lngMin) / (lngMax - lngMin)) * drawW;
    // 위도는 남→북이 아래→위이므로 반전
    final y = padding + ((latMax - lat) / (latMax - latMin)) * drawH;
    return Offset(x, y);
  }
}

/// 한국 지도 윤곽 + 지역명 + 핀 표시 CustomPainter
class KoreaMapPainter extends CustomPainter {
  const KoreaMapPainter({
    required this.pins,
    required this.isDark,
    this.selectedPinId,
    this.yearFilter,
  });

  final List<MapPin> pins;
  final bool isDark;
  final String? selectedPinId;
  final int? yearFilter;

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawGridLines(canvas, size);
    _drawKoreaOutline(canvas, size);
    _drawRegionLabels(canvas, size);
    _drawPins(canvas, size);
  }

  /// 배경 그라데이션
  void _drawBackground(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width * 0.5, size.height * 0.4),
        size.width * 0.8,
        isDark
            ? [const Color(0xFF1A2A3A), const Color(0xFF0D1117)]
            : [const Color(0xFFE8F4F8), const Color(0xFFD0E8EF)],
      );
    canvas.drawRect(rect, paint);
  }

  /// 위경도 그리드 라인
  void _drawGridLines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark
          ? const Color(0x15FFFFFF)
          : const Color(0x12000000)
      ..strokeWidth = 0.5;

    // 위도 그리드 (34~38)
    for (var lat = 34.0; lat <= 38.0; lat += 1.0) {
      final start = KoreaMapBounds.toCanvas(lat, KoreaMapBounds.lngMin, size);
      final end = KoreaMapBounds.toCanvas(lat, KoreaMapBounds.lngMax, size);
      canvas.drawLine(start, end, paint);
    }
    // 경도 그리드 (125~130)
    for (var lng = 125.0; lng <= 130.0; lng += 1.0) {
      final start = KoreaMapBounds.toCanvas(KoreaMapBounds.latMin, lng, size);
      final end = KoreaMapBounds.toCanvas(KoreaMapBounds.latMax, lng, size);
      canvas.drawLine(start, end, paint);
    }
  }

  /// 간략화된 한국 지도 윤곽선 (주요 해안선 포인트)
  void _drawKoreaOutline(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark
          ? const Color(0x40FFFFFF)
          : const Color(0x30000000)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 한반도 본토 윤곽 (간략화)
    final mainlandPoints = <List<double>>[
      [38.5, 128.3],  // 강원 북동
      [38.3, 128.6],
      [37.8, 128.9],  // 강원 동해안
      [37.5, 129.1],
      [37.0, 129.4],  // 울진
      [36.5, 129.5],  // 포항
      [36.0, 129.5],  // 경주
      [35.8, 129.4],
      [35.5, 129.3],  // 울산
      [35.2, 129.1],  // 부산
      [35.1, 129.0],
      [35.0, 128.7],
      [34.8, 128.4],  // 남해
      [34.7, 128.0],
      [34.8, 127.5],  // 여수
      [34.6, 127.2],
      [34.4, 126.5],  // 진도
      [34.7, 126.3],  // 목포
      [34.9, 126.4],
      [35.2, 126.5],
      [35.4, 126.5],  // 광주 서쪽
      [35.6, 126.4],
      [35.8, 126.5],
      [36.0, 126.5],  // 군산
      [36.4, 126.5],
      [36.7, 126.3],  // 서산
      [36.8, 126.1],
      [37.0, 126.4],
      [37.2, 126.6],  // 인천
      [37.5, 126.6],
      [37.7, 126.5],
      [37.9, 126.7],  // 개성 부근
      [38.0, 126.9],
      [38.3, 127.5],  // 북쪽
      [38.5, 128.3],  // 시작점으로 연결
    ];

    final path = Path();
    for (var i = 0; i < mainlandPoints.length; i++) {
      final pt = KoreaMapBounds.toCanvas(
        mainlandPoints[i][0],
        mainlandPoints[i][1],
        size,
      );
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    path.close();

    // 반투명 내부 채우기
    final fillPaint = Paint()
      ..color = isDark
          ? const Color(0x0AFFFFFF)
          : const Color(0x08000000)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, paint);

    // 제주도
    final jejuPoints = <List<double>>[
      [33.5, 126.2],
      [33.3, 126.4],
      [33.2, 126.6],
      [33.3, 126.8],
      [33.5, 126.9],
      [33.6, 126.6],
      [33.5, 126.2],
    ];

    final jejuPath = Path();
    for (var i = 0; i < jejuPoints.length; i++) {
      final pt = KoreaMapBounds.toCanvas(
        jejuPoints[i][0],
        jejuPoints[i][1],
        size,
      );
      if (i == 0) {
        jejuPath.moveTo(pt.dx, pt.dy);
      } else {
        jejuPath.lineTo(pt.dx, pt.dy);
      }
    }
    jejuPath.close();
    canvas.drawPath(jejuPath, fillPaint);
    canvas.drawPath(jejuPath, paint);
  }

  /// 주요 도시 레이블
  void _drawRegionLabels(Canvas canvas, Size size) {
    final labels = <String, List<double>>{
      '서울': [37.5665, 126.9780],
      '부산': [35.1796, 129.0756],
      '대구': [35.8714, 128.6014],
      '광주': [35.1595, 126.8526],
      '대전': [36.3504, 127.3845],
      '제주': [33.4996, 126.5312],
    };

    for (final entry in labels.entries) {
      final pos = KoreaMapBounds.toCanvas(
        entry.value[0],
        entry.value[1],
        size,
      );
      final textPainter = TextPainter(
        text: TextSpan(
          text: entry.key,
          style: TextStyle(
            fontSize: 9,
            color: isDark
                ? const Color(0x60FFFFFF)
                : const Color(0x50000000),
            fontWeight: FontWeight.w400,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(pos.dx - textPainter.width / 2, pos.dy + 8),
      );
    }
  }

  /// 핀 그리기
  void _drawPins(Canvas canvas, Size size) {
    final filteredPins = yearFilter == null
        ? pins
        : pins.where((p) {
            if (p.startYear != null && p.startYear! > yearFilter!) return false;
            if (p.endYear != null && p.endYear! < yearFilter!) return false;
            return true;
          }).toList();

    for (final pin in filteredPins) {
      final pos = KoreaMapBounds.toCanvas(pin.lat, pin.lng, size);
      final isSelected = pin.id == selectedPinId;
      final radius = isSelected ? 14.0 : 10.0;

      // 글로우 효과
      final glowPaint = Paint()
        ..color = AppColors.primaryMint.withAlpha(isSelected ? 80 : 40)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(pos, radius + 4, glowPaint);

      // 핀 원 배경
      final bgPaint = Paint()
        ..color = isSelected
            ? AppColors.primaryMint
            : (isDark ? const Color(0xFF2D4A5A) : const Color(0xFFD0E8EF))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, radius, bgPaint);

      // 핀 테두리
      final borderPaint = Paint()
        ..color = isSelected
            ? AppColors.primaryBlue
            : AppColors.primaryMint
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(pos, radius, borderPaint);

      // 이니셜
      final initial = pin.nodeName.isNotEmpty ? pin.nodeName[0] : '?';
      final textPainter = TextPainter(
        text: TextSpan(
          text: initial,
          style: TextStyle(
            fontSize: isSelected ? 12 : 10,
            fontWeight: FontWeight.w700,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white : AppColors.primaryBlue),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(pos.dx - textPainter.width / 2, pos.dy - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant KoreaMapPainter old) =>
      old.pins != pins ||
      old.isDark != isDark ||
      old.selectedPinId != selectedPinId ||
      old.yearFilter != yearFilter;

  /// 핀 히트 테스트
  static MapPin? hitTestPin(
    Offset localPosition,
    List<MapPin> pins,
    Size size, {
    int? yearFilter,
  }) {
    final filteredPins = yearFilter == null
        ? pins
        : pins.where((p) {
            if (p.startYear != null && p.startYear! > yearFilter) return false;
            if (p.endYear != null && p.endYear! < yearFilter) return false;
            return true;
          }).toList();

    for (final pin in filteredPins.reversed) {
      final pos = KoreaMapBounds.toCanvas(pin.lat, pin.lng, size);
      final dist = (localPosition - pos).distance;
      if (dist <= 18) return pin;
    }
    return null;
  }
}
