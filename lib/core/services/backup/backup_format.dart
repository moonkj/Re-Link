import 'dart:convert';

/// .rlink 백업 파일 내 manifest.json 형식
class BackupManifest {
  const BackupManifest({
    required this.version,
    required this.createdAt,
    required this.appVersion,
    required this.nodeCount,
    required this.memoryCount,
    required this.totalBytes,
    this.checksum,
    this.senderNodeId,
    this.inviteCode,
  });

  static const int currentVersion = 1;

  final int version;
  final DateTime createdAt;
  final String appVersion;
  final int nodeCount;
  final int memoryCount;
  final int totalBytes;
  final String? checksum;

  /// 백업을 생성한 사용자의 노드 ID (공유 시 발신자 식별)
  final String? senderNodeId;

  /// 가족 초대 코드 (6자리 영숫자, 예: "ABC123")
  final String? inviteCode;

  factory BackupManifest.fromJson(Map<String, dynamic> json) =>
      BackupManifest(
        version: json['version'] as int,
        createdAt: DateTime.parse(json['created_at'] as String),
        appVersion: json['app_version'] as String,
        nodeCount: json['node_count'] as int,
        memoryCount: json['memory_count'] as int,
        totalBytes: json['total_bytes'] as int,
        checksum: json['checksum'] as String?,
        senderNodeId: json['sender_node_id'] as String?,
        inviteCode: json['invite_code'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'app_version': appVersion,
        'node_count': nodeCount,
        'memory_count': memoryCount,
        'total_bytes': totalBytes,
        if (checksum != null) 'checksum': checksum,
        if (senderNodeId != null) 'sender_node_id': senderNodeId,
        if (inviteCode != null) 'invite_code': inviteCode,
      };

  String toJsonString() => jsonEncode(toJson());

  /// 파일명 형식: backup_20260319_143022.rlink
  static String generateFilename(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return 'backup_$y$mo${d}_$h$mi$s.rlink';
  }
}

class BackupInfo {
  const BackupInfo({
    required this.filename,
    required this.createdAt,
    required this.sizeBytes,
    required this.nodeCount,
    required this.memoryCount,
    required this.source,
  });

  final String filename;
  final DateTime createdAt;
  final int sizeBytes;
  final int nodeCount;
  final int memoryCount;

  /// 'icloud' | 'google' | 'local'
  final String source;

  String get formattedSize {
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
