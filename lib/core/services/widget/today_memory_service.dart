import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../database/app_database.dart';
import '../../../shared/repositories/db_provider.dart';

part 'today_memory_service.g.dart';

/// "N년 전 오늘" 기억 데이터
class TodayMemoryData {
  final String memoryId;
  final String nodeId;
  final String? title;
  final String nodeName;
  final String? filePath;
  final String? thumbnailPath;
  final String type;
  final DateTime originalDate;
  final int yearsAgo;

  const TodayMemoryData({
    required this.memoryId,
    required this.nodeId,
    this.title,
    required this.nodeName,
    this.filePath,
    this.thumbnailPath,
    required this.type,
    required this.originalDate,
    required this.yearsAgo,
  });
}

/// 오늘의 기억 서비스 — 같은 월/일의 과거 기억 검색
class TodayMemoryService {
  const TodayMemoryService(this._db);

  final AppDatabase _db;

  /// 과거 같은 날의 기억 목록 (dateTaken 또는 createdAt 기준)
  Future<List<TodayMemoryData>> getTodayMemories() async {
    final now = DateTime.now();
    final allNodes = await _db.getAllNodes();
    final nodeMap = <String, String>{
      for (final n in allNodes) n.id: n.name,
    };

    final results = <TodayMemoryData>[];

    for (final node in allNodes) {
      final memories = await _db.getMemoriesForNode(node.id);
      for (final m in memories) {
        final date = m.dateTaken ?? m.createdAt;
        if (date.month == now.month &&
            date.day == now.day &&
            date.year != now.year) {
          results.add(TodayMemoryData(
            memoryId: m.id,
            nodeId: m.nodeId,
            title: m.title,
            nodeName: nodeMap[m.nodeId] ?? '',
            filePath: m.filePath,
            thumbnailPath: m.thumbnailPath,
            type: m.type,
            originalDate: date,
            yearsAgo: now.year - date.year,
          ));
        }
      }
    }

    // 오래된 기억 우선 (yearsAgo 내림차순)
    results.sort((a, b) => b.yearsAgo.compareTo(a.yearsAgo));
    return results;
  }
}

/// TodayMemoryService 프로바이더
@riverpod
TodayMemoryService todayMemoryService(Ref ref) =>
    TodayMemoryService(ref.watch(appDatabaseProvider));

/// 오늘의 기억 목록 프로바이더
@riverpod
Future<List<TodayMemoryData>> todayMemories(Ref ref) =>
    ref.watch(todayMemoryServiceProvider).getTodayMemories();
