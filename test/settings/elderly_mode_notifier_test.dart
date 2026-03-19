import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/core/database/app_database.dart';
import 'package:re_link/features/settings/providers/elderly_mode_notifier.dart';
import 'package:re_link/shared/repositories/db_provider.dart';
import 'package:re_link/shared/repositories/settings_repository.dart';

/// ProviderContainer with in-memory DB
ProviderContainer _makeContainer() {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  return ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      settingsRepositoryProvider.overrideWith((_) => SettingsRepository(db)),
    ],
  );
}

void main() {
  group('ElderlyModeNotifier', () {
    test('초기 상태 — false', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      final notifier = container.read(elderlyModeNotifierProvider.notifier);
      final result = await container.read(elderlyModeNotifierProvider.future);
      expect(result, isFalse);
      // notifier 참조가 유효한지 확인
      expect(notifier, isNotNull);
    });

    test('setEnabled(true) → state = true', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      await container.read(elderlyModeNotifierProvider.notifier).setEnabled(true);
      final result = container.read(elderlyModeNotifierProvider).valueOrNull;
      expect(result, isTrue);
    });

    test('setEnabled(false) → state = false (토글)', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      final notifier = container.read(elderlyModeNotifierProvider.notifier);
      await notifier.setEnabled(true);
      await notifier.setEnabled(false);
      final result = container.read(elderlyModeNotifierProvider).valueOrNull;
      expect(result, isFalse);
    });

    test('setEnabled(true) → DB에도 저장됨', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final repo = SettingsRepository(db);
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          settingsRepositoryProvider.overrideWith((_) => repo),
        ],
      );
      addTearDown(container.dispose);
      addTearDown(db.close);

      await container.read(elderlyModeNotifierProvider.notifier).setEnabled(true);
      // DB에서 직접 읽어서 영속성 검증
      final dbValue = await repo.isElderlyMode();
      expect(dbValue, isTrue);
    });

    test('여러 번 setEnabled 호출 — 마지막 값 유지', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      final notifier = container.read(elderlyModeNotifierProvider.notifier);
      await notifier.setEnabled(true);
      await notifier.setEnabled(true);
      await notifier.setEnabled(false);
      final result = container.read(elderlyModeNotifierProvider).valueOrNull;
      expect(result, isFalse);
    });
  });
}
