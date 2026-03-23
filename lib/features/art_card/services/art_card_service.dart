import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

/// 아트 카드 서비스 — RepaintBoundary → PNG → OS 공유시트
class ArtCardService {
  /// RepaintBoundary를 PNG로 캡처하여 임시 파일 저장
  static Future<File?> captureToFile({
    required GlobalKey repaintKey,
    double pixelRatio = 3.0,
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
      final filename = 'relink_artcard_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(p.join(dir.path, filename));
      await file.writeAsBytes(bytes);
      return file;
    } catch (_) {
      return null;
    }
  }

  /// OS 공유시트로 공유
  static Future<void> share(File file) async {
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'image/png')],
      subject: 'Re-Link 가족 아트 카드',
    );
  }

  /// OS 공유시트로 공유 (iPad 지원 — context에서 위치 추출)
  static Future<void> shareWithContext(File file, BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    final sharePositionOrigin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : null;

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'image/png')],
      subject: 'Re-Link 가족 아트 카드',
      sharePositionOrigin: sharePositionOrigin,
    );
  }
}
