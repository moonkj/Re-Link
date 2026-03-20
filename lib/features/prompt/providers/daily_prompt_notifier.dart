import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/data/family_prompts.dart';
import '../../../core/database/tables/settings_table.dart';
import '../../../shared/repositories/settings_repository.dart';

part 'daily_prompt_notifier.g.dart';

/// 데일리 프롬프트 상태
class DailyPromptState {
  const DailyPromptState({
    required this.currentPrompt,
    required this.isDismissed,
    required this.lastShownDate,
  });

  final FamilyPrompt currentPrompt;
  final bool isDismissed;
  final String lastShownDate; // YYYY-MM-DD

  DailyPromptState copyWith({
    FamilyPrompt? currentPrompt,
    bool? isDismissed,
    String? lastShownDate,
  }) {
    return DailyPromptState(
      currentPrompt: currentPrompt ?? this.currentPrompt,
      isDismissed: isDismissed ?? this.isDismissed,
      lastShownDate: lastShownDate ?? this.lastShownDate,
    );
  }
}

/// 데일리 프롬프트 Notifier
///
/// - 날짜 seed 기반 결정론적 프롬프트 선택 (매일 같은 질문, 매일 다른 질문)
/// - dismiss 시 오늘 날짜를 SettingsRepository에 저장
@riverpod
class DailyPromptNotifier extends _$DailyPromptNotifier {
  @override
  Future<DailyPromptState> build() async {
    final repo = ref.read(settingsRepositoryProvider);
    final today = _todayString();
    final dismissedDate =
        await repo.get(SettingsKey.dailyPromptDismissedDate);
    final isDismissed = dismissedDate == today;
    final prompt = _getTodayPrompt();

    return DailyPromptState(
      currentPrompt: prompt,
      isDismissed: isDismissed,
      lastShownDate: today,
    );
  }

  /// 날짜 기반 결정론적 프롬프트 선택
  /// seed = year * 10000 + month * 100 + day
  /// index = seed % prompts.length
  FamilyPrompt _getTodayPrompt() {
    final now = DateTime.now();
    final seed = now.year * 10000 + now.month * 100 + now.day;
    final index = seed % familyPrompts.length;
    return familyPrompts[index];
  }

  /// 오늘의 날짜 문자열 (YYYY-MM-DD)
  String _todayString() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// 오늘 프롬프트 닫기 (SettingsRepository에 날짜 저장)
  Future<void> dismiss() async {
    final repo = ref.read(settingsRepositoryProvider);
    final today = _todayString();
    await repo.set(SettingsKey.dailyPromptDismissedDate, today);

    final prev = state.valueOrNull;
    if (prev != null) {
      state = AsyncData(prev.copyWith(isDismissed: true));
    }
  }
}
