import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/repositories/db_provider.dart';

part 'birthday_notifier.g.dart';

/// 생일 항목 데이터 모델
class BirthdayEntry {
  final String nodeId;
  final String nodeName;
  final String? photoPath;
  final DateTime birthDate;
  final DateTime nextBirthday;
  final int daysUntil;
  final int turningAge;
  final bool isToday;

  const BirthdayEntry({
    required this.nodeId,
    required this.nodeName,
    this.photoPath,
    required this.birthDate,
    required this.nextBirthday,
    required this.daysUntil,
    required this.turningAge,
    required this.isToday,
  });
}

/// 가족 생일 목록 프로바이더 — 다음 생일 기준 정렬
@riverpod
class BirthdayNotifier extends _$BirthdayNotifier {
  @override
  Future<List<BirthdayEntry>> build() async {
    final db = ref.watch(appDatabaseProvider);
    final nodes = await db.getAllNodes();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final entries = <BirthdayEntry>[];
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
      final turningAge = nextBday.year - birth.year;

      entries.add(BirthdayEntry(
        nodeId: node.id,
        nodeName: node.name,
        photoPath: node.photoPath,
        birthDate: birth,
        nextBirthday: nextBday,
        daysUntil: daysUntil,
        turningAge: turningAge,
        isToday: daysUntil == 0,
      ));
    }

    entries.sort((a, b) => a.daysUntil.compareTo(b.daysUntil));
    return entries;
  }

  /// 강제 새로고침
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }
}
