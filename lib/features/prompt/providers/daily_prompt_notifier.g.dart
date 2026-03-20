// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_prompt_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dailyPromptNotifierHash() =>
    r'c2aaa31a461fc9413987326c97e867dadf77e29f';

/// 데일리 프롬프트 Notifier
///
/// - 날짜 seed 기반 결정론적 프롬프트 선택 (매일 같은 질문, 매일 다른 질문)
/// - dismiss 시 오늘 날짜를 SettingsRepository에 저장
///
/// Copied from [DailyPromptNotifier].
@ProviderFor(DailyPromptNotifier)
final dailyPromptNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      DailyPromptNotifier,
      DailyPromptState
    >.internal(
      DailyPromptNotifier.new,
      name: r'dailyPromptNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dailyPromptNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DailyPromptNotifier = AutoDisposeAsyncNotifier<DailyPromptState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
