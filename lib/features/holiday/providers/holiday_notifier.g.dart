// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'holiday_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$holidayNotifierHash() => r'7e5860b6c9db0b12ac2cba6ae73ba515c1c28b38';

/// 명절/기념일 감지 Notifier
///
/// - 오늘 명절이면 축하 메시지 표시
/// - 7일 이내 명절이면 D-day 카운트다운 표시
/// - dismiss 시 해당 명절 ID + 날짜를 settings에 저장하여 같은 기간 재표시 방지
///
/// Copied from [HolidayNotifier].
@ProviderFor(HolidayNotifier)
final holidayNotifierProvider =
    AutoDisposeAsyncNotifierProvider<HolidayNotifier, HolidayState>.internal(
      HolidayNotifier.new,
      name: r'holidayNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$holidayNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$HolidayNotifier = AutoDisposeAsyncNotifier<HolidayState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
