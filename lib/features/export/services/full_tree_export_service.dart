import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

/// 전체 족보 내보내기 서비스 — 캔버스 전체를 고해상도 PNG로 캡처
class FullTreeExportService {
  /// RepaintBoundary key를 PNG로 렌더링하여 임시 파일 저장
  static Future<File?> captureToFile({
    required GlobalKey repaintKey,
    double pixelRatio = 2.0,
  }) async {
    try {
      final boundary = repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      final bytes = byteData.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final filename =
          'relink_family_tree_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(p.join(dir.path, filename));
      await file.writeAsBytes(bytes);
      return file;
    } catch (_) {
      return null;
    }
  }

  /// 파일을 OS 공유시트로 공유
  static Future<void> share(File file) async {
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'image/png')],
      subject: 'Re-Link 전체 가족 트리',
    );
  }

  /// iPad 지원 공유 (context에서 위치 추출)
  static Future<void> shareWithContext(
    File file,
    BuildContext context,
  ) async {
    final box = context.findRenderObject() as RenderBox?;
    final sharePositionOrigin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : null;

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'image/png')],
      subject: 'Re-Link 전체 가족 트리',
      sharePositionOrigin: sharePositionOrigin,
    );
  }

  /// 노드 위치 기반으로 실제 콘텐츠 영역 계산 (여백 포함)
  /// 빈 캔버스면 null 반환
  static Rect? computeContentBounds({
    required List<Offset> nodePositions,
    required double nodeWidth,
    required double nodeHeight,
    double padding = 80.0,
  }) {
    if (nodePositions.isEmpty) return null;

    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final pos in nodePositions) {
      minX = math.min(minX, pos.dx);
      minY = math.min(minY, pos.dy);
      maxX = math.max(maxX, pos.dx + nodeWidth);
      maxY = math.max(maxY, pos.dy + nodeHeight);
    }

    return Rect.fromLTRB(
      minX - padding,
      minY - padding,
      maxX + padding,
      maxY + padding,
    );
  }
}
