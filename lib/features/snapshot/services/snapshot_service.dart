import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// RepaintBoundary 캡처 → PNG 저장 → OS 공유시트
class SnapshotService {
  const SnapshotService._();

  /// [repaintKey]에 연결된 RepaintBoundary를 3× 해상도 PNG로 캡처하고
  /// share_plus를 통해 공유합니다.
  static Future<void> captureAndShare(
    GlobalKey repaintKey, {
    String? text,
    Rect? shareOrigin,
  }) async {
    final context = repaintKey.currentContext;
    if (context == null) return;

    final boundary = context.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;

    final bytes = byteData.buffer.asUint8List();

    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/memory_snapshot_$timestamp.png');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: text,
      sharePositionOrigin: shareOrigin,
    );
  }
}
