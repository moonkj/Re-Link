import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../database/app_database.dart';
import '../../../shared/repositories/db_provider.dart';
import 'today_memory_service.dart';

part 'home_widget_service.g.dart';

/// HomeWidget 데이터 동기화 서비스
/// Drift DB → UserDefaults/SharedPreferences → Native Widget
class HomeWidgetService {
  const HomeWidgetService(this._db);
  final AppDatabase _db;

  static const _appGroupId = 'group.com.relink.reLink';
  static const _iOSWidgetName = 'ReLinkWidget';
  static const _androidWidgetName = 'ReLinkWidgetProvider';

  /// 초기화 — App Group 설정
  Future<void> init() async {
    await HomeWidget.setAppGroupId(_appGroupId);
  }

  /// 모든 위젯 데이터 업데이트
  Future<void> updateAll() async {
    await _updateAnniversary();
    await _updateTodayMemory();
    await _updateFamilyStats();
    await HomeWidget.updateWidget(
      iOSName: _iOSWidgetName,
      androidName: _androidWidgetName,
    );
  }

  /// Widget C: 다가오는 기념일 (생일 + 가족 일정)
  Future<void> _updateAnniversary() async {
    final nodes = await _db.getAllNodes();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final upcoming = <Map<String, dynamic>>[];

    // 1) 생일 계산
    for (final node in nodes) {
      if (node.birthDate == null || node.isGhost || node.deathDate != null) {
        continue;
      }
      final birth = node.birthDate!;
      var nextBday = DateTime(now.year, birth.month, birth.day);
      if (nextBday.isBefore(today)) {
        nextBday = DateTime(now.year + 1, birth.month, birth.day);
      }
      final daysUntil = nextBday.difference(today).inDays;
      upcoming.add({
        'name': node.name,
        'daysUntil': daysUntil,
        'turningAge': nextBday.year - birth.year,
        'date': '${birth.month}/${birth.day}',
        'isToday': daysUntil == 0,
      });
    }

    // 2) 가족 일정
    final events = await _db.getAllFamilyEvents();
    for (final event in events) {
      final eventDate = event.eventDate;

      if (event.isYearly) {
        // 매년 반복 일정 — 다음 발생일 계산
        var nextOccurrence = DateTime(now.year, eventDate.month, eventDate.day);
        if (nextOccurrence.isBefore(today)) {
          nextOccurrence =
              DateTime(now.year + 1, eventDate.month, eventDate.day);
        }
        final daysUntil = nextOccurrence.difference(today).inDays;
        upcoming.add({
          'name': event.title,
          'daysUntil': daysUntil,
          'turningAge': 0,
          'date': '${eventDate.month}/${eventDate.day}',
          'isToday': daysUntil == 0,
        });
      } else {
        // 1회성 일정 — 미래 일정만
        final eventDay =
            DateTime(eventDate.year, eventDate.month, eventDate.day);
        if (!eventDay.isBefore(today)) {
          final daysUntil = eventDay.difference(today).inDays;
          upcoming.add({
            'name': event.title,
            'daysUntil': daysUntil,
            'turningAge': 0,
            'date': '${eventDate.month}/${eventDate.day}',
            'isToday': daysUntil == 0,
          });
        }
      }
    }

    // daysUntil 오름차순 정렬
    upcoming.sort(
      (a, b) => (a['daysUntil'] as int).compareTo(b['daysUntil'] as int),
    );

    // 상위 5건
    final top5 = upcoming.take(5).toList();

    await HomeWidget.saveWidgetData('anniversary_list', jsonEncode(top5));
    await HomeWidget.saveWidgetData('anniversary_count', upcoming.length);
    if (top5.isNotEmpty) {
      await HomeWidget.saveWidgetData(
        'anniversary_next_name',
        top5.first['name'],
      );
      await HomeWidget.saveWidgetData(
        'anniversary_next_days',
        top5.first['daysUntil'],
      );
    }
  }

  /// Widget A: 오늘의 기억
  Future<void> _updateTodayMemory() async {
    final svc = TodayMemoryService(_db);
    final memories = await svc.getTodayMemories();

    if (memories.isEmpty) {
      await HomeWidget.saveWidgetData('today_memory_exists', false);
      await HomeWidget.saveWidgetData('today_memory_title', '');
      await HomeWidget.saveWidgetData('today_memory_node', '');
      await HomeWidget.saveWidgetData('today_memory_years', 0);
    } else {
      final first = memories.first;
      await HomeWidget.saveWidgetData('today_memory_exists', true);
      await HomeWidget.saveWidgetData('today_memory_title', first.title ?? '');
      await HomeWidget.saveWidgetData('today_memory_node', first.nodeName);
      await HomeWidget.saveWidgetData('today_memory_years', first.yearsAgo);
      await HomeWidget.saveWidgetData('today_memory_type', first.type);
      await HomeWidget.saveWidgetData('today_memory_count', memories.length);
    }
  }

  /// Widget B: 가족 트리 미니
  Future<void> _updateFamilyStats() async {
    final stats = await _db.getStats();
    await HomeWidget.saveWidgetData('family_node_count', stats['nodes'] ?? 0);
    await HomeWidget.saveWidgetData(
      'family_memory_count',
      stats['memories'] ?? 0,
    );
  }
}

/// HomeWidgetService 프로바이더
@riverpod
HomeWidgetService homeWidgetService(Ref ref) =>
    HomeWidgetService(ref.watch(appDatabaseProvider));
