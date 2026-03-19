import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

/// 내보내기 템플릿
enum ExportTemplate { classic, modern, minimal, festival }

/// 내보내기 해상도
enum ExportResolution {
  sns(1080, 1080, 'SNS'),
  a4(2480, 3508, 'A4'),
  a2(4961, 7016, 'A2');

  const ExportResolution(this.width, this.height, this.label);
  final int width;
  final int height;
  final String label;
}

/// Heritage Export 서비스 — RepaintBoundary → 고해상도 PNG → 저장/공유
class ExportService {
  /// RepaintBoundary key를 PNG로 렌더링하여 임시 파일 저장
  static Future<File?> captureToFile({
    required GlobalKey repaintKey,
    required ExportResolution resolution,
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
      final filename = 'relink_heritage_${DateTime.now().millisecondsSinceEpoch}.png';
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
      subject: 'Re-Link 가족 가계도',
    );
  }
}
